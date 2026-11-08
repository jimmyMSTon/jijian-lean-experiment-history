# 极简 Lean：Stitch UI 完整化与 macOS 交付

2026-10-07。当前 15 张 Stitch 界面/状态已接入共用数学稿纸；最终 Mac App 已重新构建、启动并展示真实 Kernel 验证记录。没有新增模型、全局离线 Gate、注册/付费条件、自动补前提或发布审核规则。此轮只完成客户端和构建/QA，后端及 Lean 模块逐文件 SHA256 与开始时稳定基线一致。

## 交付位置

- App：`/[LOCAL_USER]/Documents/ChatGPT/极简lean 2/dist/极简 Lean.app`
- 界面盘点与全部 Stitch → App 对应：项目根 `UI_INVENTORY.md`
- 逐屏视觉 QA：项目根 `design-qa.md`
- 实现：`client/stitch-app.ts`、`ui/desktop.css`、`scripts/build_stitch_current.py`；15 个来源 ID 在 `ui/stitch-screen-map.json`
- 原设计：`../stitch-current`；旧导出和原包保留。11 HTML 下载，4 受保护 HTML 从实际已登录 Stitch 渲染 srcdoc 取出；出处/校验单独保存，登录页没有冒充代码。
- 真实 App 截图：本目录 `screenshots/native-welcome.png`、`native-result.png`、`native-step-detail.png`、`native-formal-details.png`、`native-dependencies.png`。

## 已完成 UI 与绑定

欢迎/文字/LaTeX 稿纸、图片/PDF 文件选择与拖入、识别文本对照修订、手写画布、实际相机设备/预览、简洁进度与取消、四类失败、歧义候选修正、原步骤结果与详情、同一稿件编辑重验、历史、导出、偏好、Lean/MathIR/依赖折叠入口均已实现。没有尚缺的本轮指定页面/状态。每项接口和操作证据详见 inventory。

默认数学内容与验证结果；技术代码/JSON/诊断/检索日志不常驻。输入查看和预览无 AI；用户明确验证时才 POST jobs。识别后保存记录并用 recognitionId 继续，不为后续每阶段重复发送图片。校对用已有修订接口，Unicode 位置转换保留。来源只展示步骤精度，文本使用 textContent 或 trust=false 的本地 KaTeX。

成功判断必须同时读取 `kernelVerified/status`，并显示原意/歧义说明与逐步状态。HTTP 200 和 job completed 不代表证明通过。历史读取已有 artifacts，feedback(explain=false) 不调用 AI。发生 SSE 断流时保留同一任务 ID，GET 当前进度/结果，不重新 POST 证明。

## 一次真实数学 E2E

只提交既有三题中的代数原证明一次：实数 x,y，证明 `(x+y)² ≤ 2(x²+y²)`，沿用展开/配方/平方非负。没有增加模型样本。此轮 fresh MathIR 是 3 个推理步骤和最终目标，共 4 个片段。

任务：`63a1cc35-f89d-4292-906c-7868237f6764`；最终 verification：`3ffe60d6-1ead-4373-a811-40e3fa33f129`。当前实际 DeepSeek 模型为已配置 `deepseek-flash`。本机 Lean 4.34.0 + Mathlib 在 macOS 隔离进程真实编译并独立导出证明表达式/数据式 Kernel 重放，最终 4/4 步骤成立，整体 `formal_verified`、`kernelVerified=true`，无 unresolved ambiguity。

首次生成是 **0/4**：模型返回 tactic body 漏 `by`，引起 Term parsing failed / Unknown identifier exact。使用新 Lean diagnostics 后，一轮 workflow 对四个失败片段分别作一次真实 repair；最终 4/4 与 aggregate Kernel 通过。逐片段原因、原 proof、修复 proof 见 `live-repair-reasons.json`。此轮没有为 UI 改后端/prompt；没有宣称首次一次成功。

| 阶段 | 真实 DeepSeek 请求数 | 原因 |
|---|---:|---|
| recognition | 0 | 文本输入，无视觉上传 |
| mathir | 1 | SemanticMathIR |
| formalization | 1 | ProofBodies |
| repair | 4 | 每个失败片段的实际 Lean 诊断 |
| feedback | 0 | 结果说明使用已有数据 |
| other | 2 | 初次及修复时的 LibraryPlan |
| 总计 | **8** | 8 次响应已实际收到 |

retry 0，重复 input_hash 0；输入 token 98271，输出 token 52005（按 Provider usage）。Statement Hash `f2911e25bfe8dbd2f51d02b97d70240e10f14f21ab38b28cc7ed6e349ea706da`，Statement/Binder Drift 均 false。自然语言忠实性由原文/解释对照；Kernel 核验锁定的形式命题，UI 已明确这个范围。

第一 UI 构建的 WK 事件流连接中断，但后台任务继续完成。修复客户端后，最终 App 从历史读取**同一份**真实证书并显示结果、步骤、Lean 与依赖，没有再发一次付费验证。新断流恢复和双击去重用明确 fixture 测试：POST jobs=1、GET jobs=2，恢复成功；未声称最终 UI 版本另执行第二条 live 链。全轮审计最终仍为 8 started / 8 finished。

原始结果/请求/证书：`live-result.json`、`live-smoke.json`、`live-smoke-start.json`、`live-repair-reasons.json`。本轮 8 请求与前一轮三题修复的 12 请求为不同测试范围，未合并或重跑三题。

## 本地 UI 与工程检查

- 15 状态逐屏源代码重渲染与实现配对；所有必查字体、布局、颜色、图像、文案在 design-qa.md 有证据。
- 宽度 600/800/1280、长稿 17913px、原生窗口正常/放大；无文档横向溢出。
- 修改使旧结果失效；同一稿纸提交；识别 PATCH 校对；折叠原稿导出逐字相等（190/190 字符）；依赖节点/来源资产/数学预览正常。
- TypeScript 类型检查通过。35 项本地 API/workflow/Statement Lock 测试通过；显式 stub/fixture，不算真实模型或 Kernel。1 条第三方弃用告警。`local-tests.log`。
- 故意 SSE 断开恢复和重复点击只在独立 UI fixture 服务运行，未实例化 Provider。前端正常 App 没有自动 fixture 替换，也没有 live/offline 开关 Gate。
- 后端/Lean SHA256 基线比较无变化；既有 Statement Lock、Binder Map、Retriever、repair 去重、cache、single-flight、请求审计和独立 Kernel 原样保留。`final-integrity.json`。

本轮图片识别/中文手写识别 **未再次真实调用**；图片/PDF/手写输入和状态只做 UI fixture QA，不计真实 OCR/视觉能力通过。Mac FaceTime 相机实际预览成功，可用设备列表出现 iPhone 连续互通相机，但未拍摄/上传画面；未宣称完成 iPhone 视觉链。拖入已绑定真实 DOM drop/input-bridge，但未另跑真实视觉拖入 E2E。

## macOS 构建与安全检查

最终构建日志 `macos-final-build.log` 成功；打包先编译当前 UI，PyInstaller 后端 + Cocoa/WKWebView 壳；原构建按 UUID 留存 `../build/app-backups`。已退出旧进程并启动最新包，当前 App 保持数学验证结果页。

`codesign --verify --deep --strict` 通过；签名详情 `codesign-details.log` 为 ad-hoc，本机 arm64 开发构建，无 Apple Developer Team/公证。使用此 Mac 已准备的外部 Lean/Mathlib 固定路径（App `runtime.json`），不声称是可搬到任意 Mac 的自包含 Mathlib 发行包。这是现有构建实际范围，不新增发布 Gate。

实际配置密钥只在服务端 `~/Library/Application Support/JijianLean/server.env`。扫描最终 App：实际密钥不存在、无 server.env/.env、无 fixture 预览服务脚本。`bundle-secret-check.json` 不含密钥值。没有要求用户终端操作。

## 产品逻辑变更核对

没有新增未经确认的产品规则。改动包括呈现层、用户已要求的输入/结果/编辑状态、只读进度恢复、重复提交 guard、字号/排版本地偏好与构建取最新 UI；没有重写稳定后端、切换 Provider、添加 AI 重试策略或证明前提。技术面板收起遵循本轮指令，数据依赖图仍由真实 MathIR 渲染。
