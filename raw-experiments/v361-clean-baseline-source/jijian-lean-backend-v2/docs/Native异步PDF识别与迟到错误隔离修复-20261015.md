# 极简 Lean Native｜真实异步 PDF 轮询、旧图片错误和启动探针修复

## 问题和复现

用户委托全面验收原生输入→校对→验证、原稿切换、取消、历史恢复，不让过时任务污染 App。本轮只用实际 Swift NativeStore + localhost 延迟 HTTP fixture，不发送任何 DeepSeek、视觉 Provider 或 Lean 请求，不访问用户 App Support 数据。

发现两个确定性竞态：
1. PDF 识别后端返回 status=submitted 后，NativeStore.recognize 无条件 while true 轮询 /api/recognition/pdf/{id}。中途用户执行 newProof/editDraft 时，只有循环最后才检查 documentRevision；旧 PDF 仍继续轮询，最终迟到的失败还可以覆盖新原稿界面。
2. 单张图片识别的 HTTP 请求如果在用户新建证明后返回失败，recognize.catch 和 importImage.catch 均调用 fail(error)，将新稿 screen 切至 systemError。多个并行导入的旧 defer 还可能错误清除新的 isImporting/isRecognizing 状态。
3. Native BackendRuntime.start 原先虽然有 45s 启动窗口，但健康检查使用 BackendClient 默认 300s HTTP request timeout；一个接受连接后无响应的 /health 可拖延整体启动；HTTP 非 2xx 也应退避防止高速请求。

### 失败基线留证

在正式代码修改前，用 tests/native_stale_visual_jobs.swift 与 tests/run_native_stale_visual_jobs.py 编译真实 NativeStore，不链接 UI_FIXTURE；本地 mock PDF 提交后返回 processing，用户第一轮轮询后建立新稿。原实现实际累积 **6 次** PDF poll，随后 Swift assert 因 screen 错误而失败；测试服务共 0 真实模型请求。没有把失败测试冒充模型或 Kernel 验收。

## 通用修复

- 所有普通导入/图片/手写识别任务绑定 documentRevision。每次 await 返回后检查版本及 Task cancellation，旧版本不得更新 draft、recognition、inputFailure、screen 或其他当前来源状态。
- PDF 异步任务对每次 HTTP poll 做版本检查，停止对过时任务的轮询。若服务没有返回 PDF task ID，返回明确系统错误；recognition failed/error/interrupted/cancelled 不允许无限等待。不增加数学证明、AI 识别或 Provider 全局请求时长 Gate。
- isImporting 与 isRecognizing 的状态变更通过 importingRevision/recognizingRevision 归属，不允许过时请求的 defer 清空新请求 busy 状态。newProof/editDraft/笔画更新会取消旧识别的 UI 归属；不涉及后台 Provider 取消 API 的情况下，不虚称已取消 Provider 原任务。
- Native Runtime 启动健康检查采用独立 URLSession，每个 /health 请求与资源等待上限 2s，原有 45s 总启动期限可实际起效；HTTP 503 退避 300ms，避免 hot spin。启动子进程本身失败时安全关闭文件句柄。普通 Proof/Lean/DeepSeek 的 BackendClient 仍沿用现有请求策略。

## 通过的测试

- 原样重跑之前失败的 Swift+localhost 契约：旧 PDF poll 从失败基线 6 次降低为 **1 次**，旧图片网络失败不影响新原稿。
- 补充正常情形：第二份 PDF 先 processing 再 completed，产生保存识别记录/原稿，App 进入 recognition；正常图片也成功，isImporting/isRecognizing 最终正确。mock 统计 old PDF poll=1、image recognitions=2、uploads=4。全流程没有真实 DeepSeek、Mathpix、Lean 请求。
- 完整非 live/非 live_ai/非 lean_local Python pytest：**607 passed, 40 deselected, 0 failed**（第三方 Starlette/AnyIO DeprecationWarning）。
- tests/run_native_job_lifecycle.py：真实 Swift NativeStore 接受延迟 HTTP 后 1 POST + 1 cancel，Error.details 与失效编辑状态保留。PASS。
- tests/run_native_history_integrity.py：隔离 2 条完整历史与 2 条破损关联，旧历史加载不会污染新显示。PASS。
- tests/run_native_mixed_source_recovery.py：真实打包后端/SQLite + Swift：多段照片/手写来源、校对不可变修订、rollback、混合来源历史恢复、asset 下载、重复/缺失 SourceRefs、旧手写识别响应与新笔画、校对对照，全部通过；1 笔隔离 stroke mock 响应，0 不期望的证明 job，0 LLM。
- 这份变更只涉及 NativeStore.swift、BackendRuntime.swift 和两个隔离 QA 测试文件，不触碰 Codex 正在使用的 MathIR、Lean、Provider、用户数据库或旧原稿历史。

## 确认边界

本轮验收是真实原生模型和隔离后端 HTTP 链路，而不是用户真实图片经 DeepSeek V4.1 Flash → MathIR → Kernel 的新鲜 E2E。旧 PDF 停止的是此 Native 客户端轮询；并不声称能取消已经在外部 OCR 服务端运行的 PDF 转录任务。Mac GUI 手动点击与新签名包需另行实测，未经验证不能报告通过。

## 实际签名 App / GUI QA 补充（2026-10-15 00:15）

- 从 clean commit `21b46fe` 完整编译 SwiftUI 并签名隔离 App：`/[LOCAL_USER]/Documents/ChatGPT/极简lean-native-input-races/dist/极简 Lean.app`，Info.plist SourceCommit 与 commit 完全一致。Python/Lean 源码自 c7aea2d 未变，隔离构建使用已验证同版 PyInstaller 后端 APFS clone，未复用过时后台；codesign --verify --deep --strict PASS。
- 真实启动 QA 签名包的独立后端，并使用全新临时数据、空 Provider env：`leanReady=true`、`runtimeIntegrity=true`、Runtime attestation 存在；V2 jobs、Pipeline、Recognition 路由齐全；历史为空，进程干净退出。证据：`/[LOCAL_USER]/Documents/ChatGPT/极简lean-review/native-stale-input-qa-runtime-20261015.json`。
- 另直接启动 QA 签名 App 的真实 `JijianLean` SwiftUI 二进制，设置独立 `CFFIXED_USER_HOME`、`HOME`、`JJ_ENV_FILE=/dev/null`。实际前台创建了名称为「极简 Lean」、逻辑尺寸 1280×900 的窗口，截图：`/[LOCAL_USER]/Documents/ChatGPT/极简lean-native-input-races/build/gui-smoke/window-initial.png`；能看到真实首页、工作区导航、三种输入路径、本机后端已启动状态。QA 隔离数据库 `PRAGMA quick_check=ok`、历史 artifacts=[]、jobs=0、ai-audit.jsonl 不存在；未访问正式 `~/Applications` 或用户 App Support。
- macOS System Events 的直接按钮 AX name 为空；试图用 `click at` 做自动化输入时该 AppleScript 长时间不返回。为防止误操作，明确中止进一步自动点击，不绕过系统权限。**因此只证明 GUI 实际启动及可视首屏正常，没有完成 GUI 人工点击的输入→错误页→历史多屏操作，不得宣称 GUI 全链路通过。**
- 独立测试产生的 `JijianLean`、子 `jijian-backend` 和超时 AppleScript 由 PID 精准终止，逐个核对全部 STOPPED。Mac 上没有残留 QA Lean、Provider 或后台识别进程；未中断其他 Codex 或用户进程。
- 当前主线开发分支上 Codex 的 `backend/flash_recognition.py`、`backend/providers/vision.py`、`tests/test_transcription_evidence.py` 尚未提交，故没有在 Codex 正修改的 worktree 中 cherry-pick 本 Native-only commit。已经共享交接，待双方安全汇合后需要从正式新 HEAD 重新构建安装版。
