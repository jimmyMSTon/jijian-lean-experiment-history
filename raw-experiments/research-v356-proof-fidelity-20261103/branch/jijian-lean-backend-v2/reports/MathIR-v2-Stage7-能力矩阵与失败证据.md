# MathIR v2 Stage 7：能力矩阵与失败证据

基线 `2cec1a3`。这是隔离研究旁路；没有修改正式 v1 App、Mathlib A、Statement Lock、Repair 或 Kernel 可信边界。模型为 DeepSeek Flash，case 输入只来自 `cases.json`；期望标签与 witness 只在本地汇总阶段读取，没有发给模型。

## 实测范围与 API 账本

15 个数学文本样本产生 26 次 DeepSeek 请求尝试；25 次收到响应，1 次以失败结束。成功响应合计输入 107,125、输出 510,416 tokens。阶段分布：recognition 0, mathir 18, formalization 6, repair 2, feedback 0, other 0. 所有 retry_index 为 0；没有 provider retry。
重复 input_hash 有三组：C03 的 MathIR 相同输入调用三次（包括检查点修复后的复现），C03 的 FormalProofs 相同输入调用两次（第一次结果未写入检查点），C04 的 MathIR 相同输入有一次取消和一次恢复请求。开发缓存未命中（审计均为 miss），本轮没有 single-flight 并发请求。
审计字段保存在最终 JSON，不包含 API Key 或请求正文。C04 取消请求没有返回 usage，不能断言供应商未计费。

## C01–C15 盲测矩阵

| Case | 题型 / 预期原稿 | MathIR / 最早阻塞 | DeepSeek stages | Lean 固定命题 Kernel | 原路线 Kernel | 输入/输出 token |
|---|---|---|---|---:|---:|---:|
| C01 | `true` / correct | The theorem goal must be in the root scope | mathir | 未进入 Lean | 未进入 Lean | 3,973 / 18,870 |
| C02 | `true` / incorrect | and expects 2 arguments | mathir | 未进入 Lean | 未进入 Lean | 3,913 / 12,362 |
| C03 | `true` / correct | 最新 MathIR 已解析，但确定性类型检查拒绝 Nat/Real；此前形式化运行 RSS 失控，Kernel 未知 | mathir, formalization | 最新尝试未进入 Lean；此前 Kernel 未知 | 最新尝试未进入 Lean；此前 Kernel 未知 | 24,804 / 100,283 |
| C04 | `true` / correct | Induction variable must be the quantified variable in the locked goal | mathir | 未进入 Lean | 未进入 Lean | 4,075 / 28,532 |
| C05 | `true` / incorrect | Induction variable must be the quantified variable in the locked goal | mathir | 未进入 Lean | 未进入 Lean | 3,946 / 21,713 |
| C06 | `true` / correct | 模型输出不符合数学数据结构 | mathir | 未进入 Lean | 未进入 Lean | 4,045 / 39,590 |
| C07 | `true` / correct | ascribe has type Nat, expected Prop | mathir | 未进入 Lean | 未进入 Lean | 4,023 / 44,707 |
| C08 | `true` / correct | add expects 2 arguments | mathir | 未进入 Lean | 未进入 Lean | 3,979 / 17,349 |
| C09 | `true` / correct | 模型输出不符合数学数据结构 | mathir | 未进入 Lean | 未进入 Lean | 4,083 / 26,375 |
| C10 | `true` / 甲 correct；乙 incorrect | literal has type Real, expected Polynomial[Real] | mathir | 未进入 Lean | 未进入 Lean | 3,995 / 17,914 |
| C11 | `false` / invalid_cancellation | MathIR v2 generated and compiled | mathir, formalization, repair | False | False | 9,910 / 36,249 |
| C12 | `false` / quantifier_order_error | ascribe has type Real, expected Prop | mathir | 未进入 Lean | 未进入 Lean | 3,864 / 20,622 |
| C13 | `true` / circular | MathIR v2 generated and compiled | mathir, formalization | False | False | 6,666 / 26,051 |
| C14 | `true` / correct | MathIR v2 generated and compiled | mathir, formalization, repair | False | False | 20,820 / 88,322 |
| C15 | `false` / square_root_sign_error | MathIR v2 generated and compiled | mathir, formalization | False | False | 5,029 / 11,477 |

详细 MathIR、锁定 statement、proof patch、逐步 source mapping、Lean diagnostics、证书、过程 RSS/CPU/footprint 与每个 request hash 保存在同目录的 `mathir-v2-stage7-final-evidence.json`。

## 关键真实结果

- C11：输入命题有 `x=1,y=0` 反例。模型生成了步骤 proof，Lean 对 `h_pr_user_n_assume_eq`、`h_pr_user_n_step2` 等局部名称报 Unknown identifier；repair 后固定命题与原路线 Kernel 均未通过。没有把 Lean 未通过宣传为反例证书。
- C13：四个原步骤片段分别通过 Lean+独立 Kernel；路线组合状态为 `unsupported`，原因是 `n_step1_assume` 不是 theorem 明示前提。固定命题 kernel false、原路线 kernel false。这正体现独立片段/固定命题证明不等于用户原推导路线成立。
- C14：形式化与 repair 后仍报 `Unknown constant Nat.Coprime.mul_dvd`；固定命题与原路线 kernel 均未通过。
- C15：false theorem 样本，模型没有给出可用证明片段，路线报告 incomplete/missing_proof；无 Kernel 反例证书。
- C04/C05：真实归纳结构都被 `V2_INDUCTION_BINDER` 拒绝，变量 binder 没有对应锁定目标的量化变量。C06/C09 结构对象不能通过 Pydantic MathIR v2 contract；旧 runner 只保存通用异常文案，没有保留 provider `details.fields`，具体失败字段未知。runner 现已把无敏感内容的校验 details 一并写入之后的研究记录。
- 没有任何 C01–C15 样本获得 `originalRouteKernelPassed=true`。这只是该固定样本组的实测结果，不是总体成功率。C03 最新结构复现停在确定性类型检查，早先的 Kernel 阶段因资源中断而未知；两者都不能被记作路线成功或数学反例。

## 本阶段修复和离线验证

- Repair diagnostics 现以 `diagnosticCatalog` / `diagnosticMessages` 和每项的有序 `diagnosticRefs` 表示。全部 16 个 diagnostics occurrence、stepId、位置、来源及完整 message 可逐字重建；historical payload 170,965 bytes 降到 21,008 bytes（87.71%）。
- 同一 Stage6 历史记录中，旧请求 71,399 输入 tokens；本轮紧凑布局实际请求 9,671 输入、10,027 输出 tokens，节省输入 61,728 tokens（86.45%）。这是不同 prompt 版本的历史对照，不是严格同条件 A/B；真实 Lean 因生成 proof 引用不存在局部名称而未通过。该单次请求的历史审计被旧分类器记作 `formalization`；分类器现已覆盖 `diagnosticCatalog/repairs` 并有本地测试，历史事件没有改写。
- 普通离线测试：353 passed, 1 skipped, 6 deselected。Lean route/kernel 实测：3 passed, 2 deselected，432.95 秒；包括一个错 route 与一个正确 route、断裂/无关步骤、从 1 归纳与有限和证据。
- C03 出现研究运行器资源异常：第一次 formalization 输出已收到但没有持久化，随后相同 input_hash 的 FormalProofs 再次请求；Python 研究进程在 proof 响应后的验证/结果处理阶段约 4 分钟升至约 12 GiB RSS 且持续单核运行，最终人工停止。没有保存 proof patch 或 Lean/Kernel 结果。恢复时相同 MathIR input_hash 一次返回 schema-invalid。检查点和流式结果处理修复后又复现同一请求：响应可解析为 6 个原稿节点且 sourceTextMatches=true，但确定性 MathIR 类型检查因 `literal has type Nat, expected Real` 拒绝，未调用 formalization 或 Lean。这个错误来自 MathIR 中 literal 的类型标注与其 Real 上下文不一致；当前没有足够证据判定应由模型改标、编译器插入 coercion，还是 contract 规定标量 literal 的类型，故不静默修正。C13/C14 原始 JSON 分别达到 1.7 GB/990 MB；证书物化/序列化膨胀可能相关，但 C03 因缺少检查点无法确认因果。两份完整原始数据已无损 gzip，SHA-256 与解压内容校验一致；C03 最新捕获在 `reports/mathir-v2-stage7-live-cases/C03-captured.json.gz`。运行器现已在 MathIR、proof、首次 Lean 阶段逐步写检查点，并支持按 case/报告路径独立运行。

## 工程缺陷与契约决策分开

确定的工程问题：C03 的阶段结果曾未保存，导致完全相同 proof 输入重复；修复后的 runner 逐阶段 checkpoint、每 case 独立进程运行。针对 Lean 输出处理是否导致 RSS 膨胀仍未定位，不能声称已修复。回归测试证明既有 route connectivity 和 kernel separation 在本地 Lean 仍通过。

需要契约决策：one-based induction 的 `variableId` 如何与 theorem binder 保持同一身份；MathIR 二元算子如何承接多项展开；多项式声明在求值时的系数域与标量 coercion；原稿的数量词/类型标注如何映射为 Proposition 节点；schema-invalid 响应是否可由确定性本地正规化处理。当前批次只记录拒绝原因，没有补假设、删步骤、改语义或拓展 contract。

## 生产接入建议

暂不接入正式 v1 App。先处理 binder/Expr/Polynomial/Proposition contract 的明确决策，并诊断 C03 早先验证处理阶段的 RSS 膨胀；再用相同盲样本做结构回归，随后评估 MathIR v2 proof-only 旁路。固定 statement Kernel 与完整原路线 Kernel 必须继续分列展示；C13 证明任何仅看单步 Lean 通过或固定命题可证的上线判据都不够。

完整逐请求和逐样本证据：[`mathir-v2-stage7-final-evidence.json`](mathir-v2-stage7-final-evidence.json)。诊断去重单次实测记录：[`mathir-v2-stage7-repair-dedup-ab.json`](mathir-v2-stage7-repair-dedup-ab.json)。
