# DeepSeek 请求失控排查与修复

## 本次重新核查（2026-10-07）

已按最新指令中断三题文本 live 专项并暂停对应能力测试目标，不再继续功能或完整 live 链。中断前该专项实际已经发生10次请求：代数3（MathIR1、formalization2），归纳3（MathIR1、formalization2），三角多项式4（MathIR1、formalization2、repair1）。均无图片、无传输retry；这些是明确开启的能力测试请求，不属于普通离线回归。第三题中断发生在本地验证阶段，不能报告其最终Kernel结果已完成。

重新扫描历史库仍为253个保存响应；开发观察日志当前累计35次真实网络尝试：recognition23、mathir4、formalization6、repair1、feedback0、other1。同input_hash重复0、retry事件0。统一Provider审计安装后11次：三题10次加既有数学smoke1次。开发日志与Provider日志记录同一调用，不能相加。

本次实际重新运行 scripts/check_offline.py：275 passed、7 skipped、1 warning；TypeScript检查通过；8种UI fixture状态通过。新增回归前后审计差值报告 request-control-offline-current-counts.json，实际真实请求总数0：recognition0、mathir0、formalization0、repair0、feedback0、other0；重复hash清单为空。回归入口以后自动输出此报告，并在观察到真实请求时失败。并发的其他live流程也会计入差值，所以本次先停止live再运行。跳过项不视为真实AI或Lean通过。

本次没有新增live请求；保留并采用之前实际成功的单次smoke证据 request-control-single-live-smoke.json：other1、input190/output262、retry0。它证明该次真实Provider连接和结构化返回成功，不证明当前余额、完整生产链或Kernel成功。

单份证明的已保存实测：代数文本 mathir1/formalization2/其余0，Kernel通过但有新增可证明前提，不能称原证明无偏转化成功；归纳文本 mathir1/formalization2/其余0，真实Kernel通过。第三题 mathir1/formalization2/repair1，最终本地复核被本次指令中断。历史手写链计数及其Kernel失败见下文，不将文本3次推广为所有图片固定次数。

默认 unit/UI/regression/MathIR/diagnostics/Mathlib/Lean机制测试用stub、fixture或recorded response；真实Lean另行显式启用，它自身不需要DeepSeek。live AI需 LIVE_AI_TESTS=1 且测试标记live_ai，完整E2E另需 FULL_E2E_LIVE=1。旧 JJ_RUN_LIVE 不能单独打开AI。fixture不会在缺记录时偷偷回退网络。缓存和single-flight仅开发入口安装，正式Provider与用户UI不启用开发缓存；重复相同Lean状态检测不增加次数上限。

功能目标已按用户要求暂停；本轮没有再跑图片完整 live 链。以实际本地 datastore、开发日志和当前源码为依据，不将累计响应冒充单次回归，也不将缺失的历史 hash/retry/workflow 字段伪造出来。

## 200+ 请求来源

当前手写专项库有 **253 个不同的已保存真实响应**。逐条 responseId、首次保存 artifactId/kind、时间、JSON 路径和 token 见 deepseek-request-control-audit.json。按记录来源推断：recognition 216、mathir 21、formalization 3、repair 1、feedback 0、other 12。该推断不是新增的请求级日志；HTTP 400/402 等没有成功响应的尝试不在此总数内，不能当作零成本。

最大的三个首次保存来源为：crop_transcription 113；transcription_evidence 49（44 个一致性检查、5 个裁切批次）；image_transcription 25。余下来自结构化、能力实验、检索与形式化等。单个历史 V7 图片→MathIR 实际51：整页首读1、父裁切1、全局核对1、逐局部43、区域核对4、MathIR1。另一复核65：父裁切1、全局核对1、逐局部58、区域核对5。多版本专项与自动续轮不断新增显式 live 请求，是累计费用主要来源。

没有证据能将253归属为一次普通 pytest；原普通 pytest 默认跳过live，但旧联调脚本缺开关、UI live脚本可上传并提交完整验证，属于开发误调用风险。主要责任是我将反复真实视觉专项作为开发验证，并在缺少缓存的旧流程反复运行。代码有开关并不能防止助手自行反复开启。

## 重复与 retry

旧库没有完整请求 fingerprint；同原图重新首读、复核和重新结构化确实发生，但不能精确列出旧请求同hash清单。当前开发日志25次网络尝试：recognition23、mathir1、other1；完全重复input_hash为0，清单在JSON。这不证明旧链没有语义重复，也不等于供应商账单。旧裁切请求重建assetId会改变精确key，此次明确只对CropTranscriptions排除无语义的assetId，图像hash/regionId/几何、prompt/schema/model/thinking仍纳入key；不排除MathIR节点/来源ID。

没有SDK：使用httpx单次post。没有网络层/Provider层传输retry，HTTP 400/402/429、超时、格式/schema失败都不自动重发；retry-after仅是错误信息。开发层没有retry。workflow里的Lean诊断修复是新业务阶段而非传输retry；之前没有检查重复信息，可能反复检索规划和修复。同一输入重复专项也不是retry，却一样收费。

## 实际修复

1. 正式DeepSeek Provider在唯一HTTP出口记录started/finished审计，request_id相同的两行只计1请求。workflow通过ContextVar从API请求传播到后台job；直接脚本可明确设置workflow。记录stage/reason/model/input_hash/image_hashes/prompt_version/retry_index/cache/input/output tokens、时间和状态；不记录Key、正文、图片或私有reasoning。失败没有usage保持null。Mock/ASGI transport明确real_request_attempted=false。
2. 开发入口与Provider共用稳定fingerprint。精确成功响应缓存仅开发使用；默认live开关关闭，缓存miss不能回退供应商。不同prompt/schema/model/thinking/内容/图像/MathIR版本不会误用。旧响应缺指纹只能明确fixture回放，不编造缓存key。
3. 文件锁single-flight覆盖Provider实例与OS进程；相同请求等待共享成功结果，并发失败也共享失败而不二次发送。失败通知只用于已在等待的并发请求，不作为长期成功缓存；后续新的明确请求可重试，但没有自动重试策略。跨进程和失败共享均用stub实际验证。
4. 正式RepairWorkflow记录已评估的命题/MathIR/type锁、proof原文、真实diagnostics、检索内容；相同状态再次出现返回unchanged_repair_input，保留未验证证据，不再请求模型。忽略检索规划provenance和query元数据，不把相同内容误作新信息。没有轮数/收费上限，没有改命题或Kernel规则。
5. 默认pytest remote网络封锁、recorded integration无网络fallback、UI fixture/tsc离线、Lean独立开关保留。未设置LIVE_AI_TESTS不得调用真实AI；完整链还需FULL_E2E_LIVE。check_offline.py主动清除live开关。

审计日志：服务数据目录ai-audit.jsonl；开发缓存与观察日志.dev-ai/cache和.dev-ai/calls.jsonl。两套日志观察同一次请求，不相加计费。统一JSON报告折叠started/finished request_id，并排除Mock/ASGI。

## 图片和 UI

正常上传识别保存recognition evidence，验证使用recognitionId复用首读。formalization只发MathIR/义务/库内容；feedback不含图片。当前MathIR阶段仍发原图+忠实转录，是之前明确确认的技术链，并未假称移除；识别全局/区域核对与Lean失败视觉核对也会发原图或裁切。没有每个阶段都重新OCR。

UI打开、重绘、tab/导航、恢复历史、查看结果/Lean详情、返回、事件/状态轮询只渲染或GET，不提交AI任务；上传/相机/画布提交、用户重新识别、明确验证/修订才发业务POST/PATCH。现有production UI源码未改，无新增自动触发、次数限制或Gate。

## 实际验证与每证明调用数

最后全套默认离线：275 passed、7 skipped、1 warning；TypeScript通过，八种UI fixture Chromium通过。真实DeepSeek **0次**，每个stage均0；跳过不计AI/Lean成功。统一审计无密钥/正文/私有reasoning、并发实例/进程、并发失败、资产UUID缓存、重复修复和可取消的新proof循环由fixture/stub验证。

唯一新增live smoke为数学恒等式a+a=2*a的小型结构化请求，stage other **1次**、cache miss/retry0、input190/output262，统一出口真实请求审计已实际核对。没有图片、MathIR或完整修复链；不把它称完整E2E/Kernel成功。用户暂停前已发出的单次一致性请求后来结束，它不是本轮新增smoke，仍计入历史开发日志。无后续功能调用。

一份历史真实手写proof链有9个保存响应：recognition3（上游首读/核对2+失败图核对1）、mathir1、formalization2（类型/proof）、repair1、feedback0、other2（初次/修复检索规划）。其中上游2为复用，chain脚本当次不能计9新请求。首次/最终kernelVerified均false；不能提供一个“当前完整Kernel成功链”的实测数。Lean编译和Kernel自身不调用DeepSeek。不同图片的局部识别数、修复是否需要检索规划决定实际数量，不能将9或51定为产品固定次数。

Mac App已实际重新构建/签名检查，包含统一审计与unchanged_repair_input，旧App保留；开发工具与server.env未打包。原生首页smoke凭据禁用，不能称完整AI链。
