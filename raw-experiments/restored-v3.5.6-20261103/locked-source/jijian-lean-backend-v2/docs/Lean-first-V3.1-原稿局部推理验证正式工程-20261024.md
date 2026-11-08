# Lean-first V3.1：原稿局部推理验证（正式工程）

## 用户确认
2026-10-24 用户明确要求“开始全线制作”，确认从原来「一次性翻译完整证明」转为「沿原稿逐步定位、局部形式化、独立 Lean Kernel 检查、依赖及反馈」。这是对既有 Lean-first 技术路线的改造，不恢复 MathIR，也不新增题型规则、人工审批、次数阈值或模型重写证明功能。

## 真正数学权限
- AI：抽取原文已写步骤、给出每步 Lean 闭合命题与原稿所用推理的形式表达，允许使用 Mathlib 运算和 Lean tactics，禁止自行补写其他证明路线。
- Lean/Mathlib：独立检查该局部翻译后的命题及 proof term，仅 Kernel 证书 checked、statementMatched、additionalAxioms=[] 时记为局部形式通过。
- 来源文本：原文位置通过 Unicode 精确等值校对。模型给错起止位置，仅当引文在原文唯一出现时程序可重定位；歧义或无引文不可定源。
- 原始证明：自然语言与 Lean 的严格语义等价，不由 Kernel 证书自动判定；每个步骤的 originalInferenceVerified=false，整篇 originalProofCertified=false。
- 前提：原题已知条件按来源保存，非数学结论的 Kernel 证明；未经验证的先前推导不被视为已认证前提。即使后来形式命题通过，也要记录 unresolved dependencies。
- Lean 失败 ≠ 数学命题被 Lean 反证；非完整形式化 ≠ 原作者犯数学错误。

## 技术流程
1. 正式 /api/v3/jobs 由原有 recognition.resolve 取得图片、手写或键入的数学文字。
2. SourceOutline 使用 DeepSeek 逐字定位原稿 given、inference、claim，携带原文锚点和显式来源依赖；没有预置固定步数。
3. 每一来源步骤独立构造 LocalLeanTranslation；模型不完整或者该步骤文本位置不可靠，都只记录该项未完成。
4. 完整局部翻译送 LeanRunner，真实独立证书、诊断、模型用量及具体源码区间全部保留，其他步骤继续检查。
5. 已完成的局部检查不因后续局部失败被抹除。正式历史种类继续是 lean_first_run。
6. 原生 UI 对显示区域按真实源码锚点关联、呈现 Kernel 局部状态，但不宣传整篇原证明已认证；导出记录保留原稿。

## 旧版兼容和数据
- 旧版 MathIR 仍按原归档标签保存。
- 旧版 V3.0 记录可按 legacy sourceSteps/proofTerm 正常展示；V3.1 以 kind=lean_first_local 读取 local steps。
- 原有签名 App 与用户数据均不删除；正式 build 与安装遵守已有 main 工作树、签名、备份及唯一入口约定。
- 原完整 Lean-first 实验函数仍存在，作为历史隔离对照工具；正式任务改为 verify_original_steps。

## 审计中仍需如实揭示的能力边界
局部命题能由 Lean 成立，不保证模型形式化的假设、量词、含义完全等价于作者原文；模型对原文的 proofTerm 也可能有不同的技术编码。当前既不自动生成独立新证明冒充作者原路线，也不能将“无 Kernel 证书”直接等同于用户错误。除非有独立 Lean 反证，否则不给出“命题为假”的裁决。

这是工程能力说明，不附带新增数学审核 Gate 或发布规则。

## 本轮真实测试与工程交付实录

- 开发主线与稳定 `main`：`39437b71e990d2dc46f7c2b5b2a8ad6c99b5ee35`。
- V3.1 专项自动测试：15 passed。原生 Swift 全量文件 `swiftc -typecheck` 通过。
- 真实全新整除原证明样本：6 个原文步骤（1 条原题给定、5 条推理/结论），后 5 条由真实 DeepSeek 翻译并分别得到 Lean4 v4.34.0 / Mathlib Kernel 证书，实际使用 DeepSeek 6 次、输入 3,979 token、输出 18,843 token、耗时 332.70 秒；**没有据此冒充原稿语义获得独立认证**。原始详细审计：`~/Documents/ChatGPT/极简lean-review/v31-local-smoke-real-20261024/report.json`。
- 全库 pytest：979 passed / 6 failed / 72 skipped（总耗时121.25秒）。6 个失败均位于旧 V1 `/api/pipeline` 或旧 V2 `/api/v2/jobs` 预期仍使用 MathIR 的历史测试，与用户明确要求封存旧主体、正式入口改走 V3.1 冲突；**没有修改旧 API 行为来迎合测试，也未把失败偷偷 xfail/skip**。另外 72 个按现有测试环境条件跳过的旧 Lean 相关测试不能当通过。完整原始日志：`~/Documents/ChatGPT/极简lean-review/v31-full-pytest-20261024.log`。
- 已从同步后的稳定 main 完整重建、签名并安装 `~/Applications/极简 Lean.app`，Info.plist 3.1.0，源码提交 `39437b7`，签名与二进制 SHA-256 对照均通过；安装前 App 自动备份于 `~/Documents/ChatGPT/极简lean-ui-loader-release/build/app-backups/user-installed/20261024-174200-75ecfb39/极简 Lean.app`。
- 正式安装包后端独立启动能力检查：`mockFallback=false`、Lean ready=true，真实 DeepSeek 模型配置可读取；进程已正常退出、没有遗留自建服务。审计文件：`~/Documents/ChatGPT/极简lean-review/v31-signed-package-20261024/capabilities.json`。

## 中断恢复：局部证据实时存档

- 每项数学来源步骤验证或形式化失败之后，都存入一个内容不可变的 `lean_first_checkpoint` Artifact，包含迄今的来源文字、步骤、证书及模型记录。与 `lean_first_run` 最终产物通过 `runTraceId` 关联，取消、崩溃或 Lean 中断前已完成的部分可恢复；不会据此自动继续调用 AI。
- Mac 历史页面按 trace 去重：完整记录存在时以最终结果为准；仅中断记录有保存时显示该 trace 最新一条 checkpoint；历史旧 V3.0 记录仍可读取。不修改旧证明数据库、钥匙或归档数据。
- 此工作只解决工程持久化，不对用户证明增加需要逐步确认的审批或门槛。
