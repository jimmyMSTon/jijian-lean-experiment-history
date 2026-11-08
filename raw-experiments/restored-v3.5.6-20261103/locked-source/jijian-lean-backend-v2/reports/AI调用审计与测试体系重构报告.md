# AI 调用审计与测试体系重构报告

2026-10-06。本轮没有新增 DeepSeek 请求，优先使用既有响应和本地 fixture。正式 backend、client 与 Lean 源码 35 个文件哈希与本轮修改前一致；未新增产品 Gate、配额、重试、登录、发布条件或 UI 规则。开发工具不会被打包进 Mac App。本轮没有重新构建 Mac App，也没有声称新的图片识别或真实 AI repair 成功。

## 1. 修改前实际调用数量

不能把不同流程统称“一次测试”。普通 pytest 原来默认就跳过真实集成，调用为 0；昂贵的是独立 live 专项与完整链脚本。

| 历史实际流程 | 去重响应数 | 来源拆分 |
| --- | ---: | --- |
| V7 原图一次识别 → MathIR（首次完成样例） | 51 | 初次原图转录 1、父区域批次转录 1、全局一致性 1、逐局部片段 43、区域核对 4、MathIR 1 |
| V7 对既有识别做一次专项复核 | 65 | 父区域批次转录 1、全局一致性 1、逐局部片段 58、区域核对 5 |
| 较早的一次手写结构化/形式化/一次修复链 | 9 | 识别及一致性 2、MathIR 1、初次检索计划 1、类型 1、proof 1、失败原图复核 1、修复检索计划 1、repair proof 1 |

9 次的链包含上游已保存识别的 2 个响应，不能当成该 chain 脚本当次新 HTTP 请求次数。
这是保存成功响应的计数，不是账户完整请求账单；HTTP 400/402 等失败若没 usage，不按零成本计算。样例源报告及每个 responseId/保存路径见 api-call-path-audit.json。
手写专项 datastore 已保存 229 个不同响应，input token 1,842,067，output token 1,484,742（其中 reasoning 1,309,647 是 output 的子集，不能再相加），详见 handwriting-recorded-api-usage.json。

## 2. 所有请求入口与 UI 触发

唯一正式 HTTP AI 出口是 backend/providers/deepseek.py 的 raw_structured → _call → /chat/completions，固定使用当前配置，没有传输重试、供应商升级或 Gateway 回退。

| 模块/阶段 | 发请求的条件 | 原图上传 |
| --- | --- | --- |
| providers/vision.py / flash_recognition.py | 图片、画布笔迹、PDF 页面转录；父区域、全局/局部一致性；失败视觉复核 | 是，原图或局部图；逐局部循环一次一请求 |
| mathir.py / Services.structure | 数学原文转结构化；已有 recognitionId 可复用转录 | 图片来源会发送原图+转录，这是此前已确认的产品要求 |
| library.py MathlibRetriever.context | 模型规划检索关键词/声明；之后本地查源码、真实 #check | 无；本地 search/lookup/#check 本身不调用模型 |
| formalization.py | FormalTypes、FormalProofs；repair 前检索计划及带真实诊断的 FormalProofs | 无，仅 MathIR、义务、诊断和 Mathlib JSON |
| feedback.py | explain=True 时生成 Narrative；默认 False | 无 |
| services.py / workflow.py | pipeline/jobs 串联以上阶段，失败可能进入原图复核和 proof repair | 只在相应视觉分支上传 |
| api.py 历史 internal/ai/structured 路由 | 仅 role=gateway 时可暴露同一 Provider，第一版当前并不使用该模式 | 依请求，不是当前第一版依赖 |

UI 上传文件、粘贴/拖入图片、摄像头捕获、提交手写画布、重新识别会启动 recognition；“验证”会 POST jobs。正常识别页 → 验证使用 recognitionId，复用已有转录，不再次执行初次 OCR。用户再次上传同一文件/点重新识别仍会产生新的正式处理；本轮没有改变这个产品行为。
导航、布局预览、恢复历史、放大/旋转、展开 Lean、App 启动、health、capabilities 都不会自行调用 DeepSeek。历史 feedback 的 explain 默认 False。事件订阅与 PDF 状态轮询是读取状态，不是收费任务重新提交。启动时恢复任务只标记中断，不重启收费任务。

## 3. 实际过量原因与不必要请求

主要责任在我新增/反复执行的视觉专项：许多自然像素片段（含普通中文与标记）逐个真实调用，每次重复跑专项又重新调用，没有 record-replay。43/58 次局部调用占绝大多数；这是成本热点，不是普通 pytest 混入了真实模型。
13 个直接使用 Services 的 Python 联调脚本原来无 live opt-in；脚本文件名带 live 并不是保护。check_flash_ui_live.cjs 实际执行上传和完整验证；旧 check_stitch_live.cjs 也会 POST jobs，只有当时测试服务器缺少密钥才没有产生付费请求，换成已配置服务器存在误调用风险。
同图三次/六例的识别专项被多次运行，各版本重新识别；部分 chain 脚本在已经有有效 MathIR 时仍重新 structure。为了看 UI 重跑这些真实链、或者没有改输入就重跑视觉专项，都是不必要的开发请求。现在可分别选 fixture 回归、复用既有 MathIR 参数和精确开发缓存。
检索计划每次正式 formalize/repair 会各有一次模型调用，本地检索并非整段都无 AI。曾有一次类型请求输入达 514,943 token，说明超大 Mathlib context 也是成本来源；它不等同“请求次数重复”。本轮遵照范围没有修改正式 Retriever。

## 4. 默认完全离线的测试

Unit / 后端契约 / MathIR / Statement Lock / diagnostics / Mathlib / Lean Runner 与 Kernel 协议 / Repair Loop / 取消测试继续使用 fixture、MockTransport、ASGITransport 或 stub。新的 autouse fixture 在真实 HTTP transport 和 remote socket 层阻止普通测试外网；即使真实密钥已配置，也无法意外访问。
Recorded integration 验证已保存的模型输出、MathIR、锁定命题、proof、真实历史诊断、当前 compiler；缺 fixture 不回退网络。六种 Stitch 状态只用临时静态服务器和固定响应渲染，实际生产页面源码未改。
check_offline.py 清除所有 live 开关，执行 pytest、tsc、六状态 UI。原 check_stitch_live.cjs 已委托 fixture 回归。纯本机 Lean scripts 不创建 AI Provider。

## 5. 哪些仍需要真实 API

只有显式模型能力测试（结构化 JSON、视觉识别）以及确需验证整个生产链时需要。pytest 中只有 live_ai 标记并且 LIVE_AI_TESTS=1 才放行；Lean 测试有独立 LIVE_LEAN_TESTS=1。
完整链脚本和真实 UI 还需 FULL_E2E_LIVE=1。真实 UI 上传前必须确认目标服务器是 dev_live_backend.py 提供的监测开发实例，不再随意对普通已配置服务器运行。普通生产用户操作不受这些开发开关约束。
为了独立验证模型，可额外 LIVE_AI_FRESH=1 绕过开发缓存；不能把缓存命中说成新真实 API 成功。本轮没有启用任何 live 开关。

## 6. fixture / record-replay / cache

tests/fixtures/deepseek 保存手写、印刷、形式化、失败修复、成功修复的既有记录。头部注明原报告和“offline replay”，不包含图像 base64、真实密钥或私有 reasoning_content。成功 repair 记录保留原测试错误注入信息；手写原证明的最终未完成结果仍是未完成。
RecordedProvider 是明确的顺序/schema 回放适配器，模型类型校验失败或记录耗尽直接报错。它不是生产 Provider 或兜底 Mock。
精确开发缓存只供 devtools 入口使用；hash 包含模型、thinking、prompt 完整 hash/version、schema、stage、完整 payload/文本/MathIR/repair diagnostics 与 proof、图片字节 hash、MathIR version。变化即 miss。旧记录缺完整历史请求 fingerprint，不能臆造 key 自动导入精确缓存；这些旧记录用于显式 fixture，未来明确 live 调用才生成精确 cache。
同进程并发相同 key 共用锁；缓存文件 0600，目录 0700，失败不缓存，没有网络自动 retry。缓存命中不计新调用/token。开发 workflow 重复完全相同 repair 请求直接停止并说明重复，正式 RepairWorkflow 未改。

## 7. 每次真实调用可观察性

开发入口写 .dev-ai/calls.jsonl：request_id、workflow_id、stage、受控 reason、model、input_hash、image_hashes、retry_index、token_usage、cache、network_attempted、成功 responseId 或失败 requestId。日志不记录 Key、请求正文、图片、数学原文或私有 reasoning。
单脚本以开发运行为 workflow；开发后端按任务请求/真实 UI 的开发 workflow header 分组，后台 job 继承上下文。不同 workflow 共用精确 cache，但统计分别保留。标准输出及报告附 developmentAIExecution 给调用次数、token、缓存、retry、阶段原因；dev_live_backend 提供开发专用统计端点，正式产品无此端点/界面。
旧记录只能追溯已保存 responseId、usage 与来源路径，缺失的历史 request hash、retry index 不会伪造。DeepSeek 的 provider prompt-cache token 命中仍发生 HTTP 请求，与本地开发响应缓存不同。

## 8. retry、重复图片与修复闭环结论

没有发现 DeepSeek HTTP 自动 retry；provider/_call 是一次 post，超时/错误直接返回。没有 Flash 自检→解释→重写的自动 proof 代替 Lean 链；正式 proof repair 接收真正的 Lean diagnostics。
发现重复视觉处理/专项重跑；同一张原图也用于初次转录、全局一致性、MathIR 和失败视觉复核，局部阶段还上传 crop。并不是 recognition / MathIR / formalization / feedback 每一步都上传整图：formalization 和 feedback 没有图片参数。
正式 RepairWorkflow 无“完全相同 diagnostics + repair 输入”防重复检查，可能持续发起修复及检索规划；旧记录没有完整请求 hash，不能宣称历史出现了多少次完全相同 repair。开发层现已拦截，正式流程保持原样。

## 本轮实际执行证据

- 全套 pytest：最终全套执行 211 passed、7 skipped；跳过项均未计入真实 AI/Lean 成功。架构专项 19 项也实际通过（已包含在全套内）。
- TypeScript 编译：实际通过。
- 六种 UI fixture：实际 Chromium 渲染通过，真实 AI 0；三项外链静态资产被阻止，没有触网。
- 15 个 live 入口：未设置开关时实际拒绝，早于读取凭据和请求。
- check_examples.py：本机真实数学等式证明，Lean 编译及独立 data-only Kernel replay 通过；AI 0。
- check_recorded_lean.py：历史 Flash 修复 proof → 当前 compiler → 本机真实 Lean → 独立 Kernel replay 通过；本轮 AI 0。完整新 AI repair 闭环未执行，不能据此说“本次 Flash repair 成功”。
- 正式 product 35 文件哈希不变。macOS App 本轮未重新构建，因为变更只在未打包的开发测试工具。

相关证据：api-call-path-audit.json、handwriting-recorded-api-usage.json、live-opt-in-guard-checks.json、ui-fixture-regression.json、recorded-lean-regression.json、test-architecture-product-invariants.json。使用与开关说明见 docs/开发测试与AI调用控制.md。

## 后续离线回归更新

2026-10-06：最新全套默认 pytest 实际执行为 220 passed、7 skipped，未启用 live 开关，本次新增真实 AI 请求为 0。后续手写专项的少量显式能力调用及 vision 提示词调整单独记录在《手写识别专项实测报告》，不属于本报告开头“架构改动保持 35 文件不变”的历史执行范围，不能把两轮范围混为一谈。

新增纸页聚焦实验只在 devtools/scripts/tests 中使用已保存布局框，保留完整高度和原像素；两项几何测试通过。人工查看确认题首、公式和批注保留；未执行该聚焦图的 AI 识别，未接入正式流程，不能据此宣称识别稳定或 Kernel 成功。详情见 page-focus-offline-validation.json。

## 本次测试架构最终核验

2026-10-06：实际运行 `scripts/check_offline.py`，246 passed、7 skipped；TypeScript 检查通过，七种 Stitch UI fixture 实际 Chromium 渲染通过。脚本主动清除 live 开关；本次真实 DeepSeek 请求为 0。UI 报告明确 realLeanExecuted=false；未把 fixture 成功或跳过项记为新 AI、Kernel、图片识别或 repair 成功。未执行新的完整 E2E、模型能力测试或 macOS 构建。

本报告开头的 35 文件不变只描述原测试架构改动当时的范围。后来识别专项的源码和显式能力实验另见专项报告，不能把该历史描述当作当前整个工作区状态。当前默认开发回归仍不依赖真实 AI。

## 当前默认离线回归收尾

实际执行 scripts/check_offline.py：264 passed、7 skipped、1 warning；TypeScript 编译通过，八种 Stitch fixture 实际 Chromium 渲染通过。真实 DeepSeek 请求 0；本轮未执行真实 Lean、全链 AI repair 或 macOS 重新构建。七个跳过项不计成功。执行日志 test-architecture-final-offline.log。

开发统计已将缺失 usage 记为 unknown_usage_calls，不能把失败请求记为免费。已知 token 小计单独保留。最新识别来源契约修复另见专项报告，不属于最初测试架构 35 文件保持不变的历史范围；当前 App 未包含最后来源契约改动。
