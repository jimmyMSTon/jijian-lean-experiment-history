> **2026-10-19 正式主线替代说明：** V2 已封存，`316ad4f` 是可恢复历史基线；本项目现在只维护 Source-First Proof Core 重构为正式开发主体。先阅读 [正式开发主线与 V2 封存](docs/正式开发主线与V2封存-20261019.md) 及 [验证主体重构记录](docs/验证主体重构计划与执行记录-20261019.md)。下方 V1/V2 合并补丁指南仅作为历史记录，不再是当前工程任务要求。未经用户确认不要恢复 V2 或另立平行验证主体。

[Reading 42 lines from start (total: 42 lines, 0 remaining)]

> 2026-10-07 更新：已移除全局离线模式和 live AI 开关限制。正式 App 与真实 AI 测试正常访问 DeepSeek；fixture 由具体测试显式选择。参见开发测试说明及 reports/statement-lock-three/DeepSeekFlash三题结构锁与Lean能力报告.md。

> 2026-10-06 本机整合接续：用户最新第一版仅用 DeepSeek，覆盖下文历史网关安排；真实 API / Kernel 联调已执行。当前配置与边界见 [第一版实际配置与实测入口](docs/第一版实际配置与实测入口.md)，最终执行证据见 [真实联调报告](reports/DeepSeek真实联调报告.md)。

# 给 Codex：在 V1 上合并 V2 补丁，不重建产品

## 任务

用户会同时提供原后端 `jijian-lean-backend-v1.0.zip`、本补丁，以及其 Stitch UI 导出或 MCP 设计上下文。先合并补丁再接 UI，不让用户手工改 Python 文件或执行终端命令。

本补丁有可直接覆盖的 `overlay/`、统一差异文件和非破坏合并脚本；具体使用方式以补丁根目录 `CODEX_APPLY_PATCH.md` 为准。如果这些文件已经合并进仓库，勿重复套用或恢复 V1。

## 用户已经确认的产品事实

Lean 是最终判定者。AI 只识别、结构化、翻译和解释；验证用户原证明，不用另外一条证明冒充其原推理通过。默认界面显示人类数学，Lean 代码仅在用户主动查看形式化细节时显示。Stitch 是视觉来源，不替换、重画或扩充界面。

本轮确认使用 DeepSeek V4.1 Flash 做图片识别、数学结构化和 Lean 转化，第一版不依赖 Mathpix/PaddleOCR，不恢复 Luna/Sol/Pro 的自动模型路由。`deepseek-flash` 为本轮核对的官方接口名，当前对应 V4.1 Flash。网页上的模型标签不等于 API 模型名，也不要把测试时是否开启深度思考误设成用户永久配置。

保留：原输入 → MathIR → 用户步骤/依赖 → 形式化义务 → Lean 诊断 → 人类数学反馈。
新增/接通：当前 Mathlib 检索 → `#check` 真实类型 → Flash 生成 → Lean 报错 → 同一个 Flash 修 proof → 再核验。

修复不得改用户数学、已翻译的类型、前提、目标、作用域或依赖。`statementFingerprint`、`mathIRHash`、`typesHash` 由后端计算；不是模型自报。Kernel 只能检查形式命题，不能证明 OCR 和自然语言翻译绝无失真。

## 合并后的接续

1. 保留原持久化与数据契约，读取 `docs/V2补丁说明.md`、本轮验证报告及原始 V1 报告。不要把未执行的真实测试标成通过。
2. 在实际 Mac 工程使用服务端 `~/Library/Application Support/JijianLean/server.env` 配置 DeepSeek；当前第一版不使用 Mathpix、OpenAI 或第三方 Gateway。发行方密钥不进入源码/Git/提示词/Mac 安装包。开发用户的真实 Key 应从其安全配置渠道读取，不能编造。
3. 使用当前固定 Lean/Mathlib 运行环境执行 `#check`、命题探测和原来的证明导出/独立复核。检索返回源码候选不代表定理已在当前环境核验。真实环境不兼容时修实现并保留原数学。
4. 将原 Stitch 操作绑定 `client/backend-client.ts`；长操作延用 jobs/events/cancel。`repairing`、`mathlib_retrieved` 等是进度事件，不要求新增页面或审批。
5. 用真实供应商输出和 Lean diagnostics 记录联调结果。Lean 失败/未完成不等于用户数学错误；HTTP 200/任务完成/模型自检都不是证明通过证据。

## 不自动增加的内容

没有新增登录、付费、注册门槛、证明数量/文件页数限制、题型白名单、准确率阈值、人工审核步骤、模型升级规则、发布条件、停止策略或“必须完成增强项才能继续”的条件。

本轮已确认自动数学形式化修复；仍未确认轮数上限或费用阈值。本代码没有自设这些数值，没有网络错误自动重试，也不在服务重启后恢复收费任务。长时间未收敛的任务可以用现有取消接口结束；不得自行把它改成若干次后宣布证明为假。

声明自身未能形式化、没有原证明片段、引擎/供应商错误时，保留真实的未完成状态和诊断，不通过改题或伪造 proof 来继续。源码检索缺数据也会如实标注，不新增用户必须点击确认才能进入下一步的流程。

旧 OpenAI/Mathpix 模块保留在源树仅用于历史回归，实际 `Services` 只连接 DeepSeek。不要为了让旧测试的供应商名不变，把生产路由改回旧服务。

当前形式化：类型化 MathIR → 代码生成 canonical specification、binder map 与 statement_hash → 固定 Lean statement → Flash proof-only。repair 响应只含 proof，不返回类型/前提/声明；全部阶段保持 statement_hash。源码声明 AST、真实导出类型与独立 Kernel 复核共同检查；STATEMENT_DRIFT/BINDER_DRIFT 不作为成功，也不进入改题式修复。历史 MathIR 无 typed AST 时不能冒充新版固定 statement。三题实测包含失败，见上述报告；不能把 Kernel 通过当自然语言语义一致性的证明。

[executed on device: MacdeMacBook-Pro-5.local (7811c2bc-8b8e-4c24-a946-8a7cffebc01b)]