# MathIR v2 数学验证引擎系统收敛报告

研究基线为 `3804bae`。使用已保存 MathIR、proof terms、Lean 诊断和 Kernel wire；没有重新识别图片或重建相同 MathIR，也没有修改正式 v1 App、Mathlib A、Statement Lock 或 Kernel 可信边界。Stage 8/9 的请求记录和证据仍是本报告的来源文件，本报告不把历史结果说成本轮新跑。

C01–C15 跨阶段的原稿、结构、步骤、Kernel、Repair、请求、token 和资源记录已汇入可机读 [system capability matrix](mathir-v2-system-capability-matrix.json)，可用 [build script](../scripts/build_mathir_v2_system_matrix.py) 与 [fresh-capture merge](../scripts/merge_mathir_v2_current_structure_captures.py) 重建。历史 13 份已保存结构成功编译；当前证据中 C01、C07、C08 三条完整原路线通过。C07 使用已保存 proof terms 在当前编译器下完成了本机 Lean/Kernel 复核，没有 Provider 请求。余额恢复后，C06/C09 各进行了一次新 MathIR 结构请求；两份响应已保存，但均未成为可信证明输入，具体失败见文末续跑记录和验收矩阵。缺失字段继续留空，不从汇总推测。

## 结论

当前架构已在真实 Lean 与独立 Kernel 上完成三条完整、忠实的多步原证明路线：C01 多步实数不等式、C07 自然数立方和归纳，以及 C08 有理数有限和。C07 使用此前保存的真实 Flash proof terms，在当前编译器下重新组合并完成 Lean/Kernel replay，本次新增 Provider 请求为零。C08 是复用已保存的 Flash proof 后，Lean 明确诊断尾部多余 tactic 并由确定性 cleanup 修复，新增 DeepSeek 请求为零。C01 使用一次真实 Flash repair 后固定命题和完整原路线均通过。

参数归纳、错误归纳稿、多项式双路线和量词样本仍未形成完整原路线证书。局部节点通过、固定命题可单独证明、对错误命题找到反例，都分别保留为各自证据，不替代用户原路线。13 份历史结构可确定性编译；本次 C06 新响应只在离线 scope/metadata 整理后可编译，但生成的锁定命题有重复 `n` 绑定，故标记为不忠实且未进入 Lean；C09 新响应未通过 MathIR 结构契约。

隔离的语义步骤解析在 C05、C10、C12 三个审阅片段上 3/3 保持原稿语义并 lower 成与直接 Typed MathIR 完全相同的 AST；statement hash 和路线状态也完全一致。它修复不了 proof term 或依赖组合，因而现有证据不支持替换 Typed MathIR v2。可保留为受限、可审计的局部前端研究。

## 已编译结构和原文保真

历史 15 项审计见 [Stage 8 fidelity audit](mathir-v2-stage8-fidelity-audit.json)。C01–C05、C07–C08、C10–C15 的历史保存结构均成功编译，原文及规范化原文匹配，所有已记录 SourceRef 都落在来源范围内。其后恢复的 C06/C09 真实输出不符合可忠实编译要求，分别见本报告末尾的单次续跑记录。以下容易被“修正”的结构保持原样：

- C05 归纳稿继续包含错误新增项 `n+m`；未改成数学上应有的项。
- C10 保持 `Q(X)=P(X)(X−1)`，route_A 和 route_B 独立；route_B 的额外 `(X−2)` 未删除，也没有借 route_A 证明 route_B。
- C12 固定命题保持 `∃ M, ∀ x, x<M`，未交换量词。
- C13 的循环假设仍没有原始证明。其他独立步骤的 Kernel 证书没有被当作循环推导的证书。

## 当前源码契约审计

以下是源码中实际运行的职责边界，不把 Python 结构检查或模型评估当作 Kernel 结论：

| 链路 | 实际责任与契约 | 核验证据 / 当前边界 |
|---|---|---|
| MathIR v2 输入与校验 | `backend/v2/models.py` 给出带作用域、类型、来源、路线和归纳结构的严格数据模型；`typecheck.py` 做符号绑定规范化、类型预检、量词/归纳结构约束和引用边界检查。 | 确定性预检不是 Lean 的替代物，也不证明模型语义忠实；声明、目标和 proof 仍进入 Lean Elaborator。 |
| Typed MathIR → 固定命题和 obligations | `compiler.py` 共享 `ScopeContext` 组织 theorem/local declarations、assumptions 和 dependsOn，并生成 statement、逐步 obligation、route composition。 | `verify.py` 对全部 obligation 用 `probe_statements` 批量 elaboration，再将可 elaboration 的 proof jobs 交 `check_many`；批处理没有取消每项独立 Kernel 重放。 |
| Proof-only 生成 / Repair | `proof_only.py` 只接受 `{nodeId, proofTerm}` patch；`ProofLock` 对 statement hash、结构 hash、来源和依赖图做锁定。缺 proof 由 generation 处理；当前 Lean diagnostics 或 `declared_dependency_unused` 会形成定向 repair payload。 | patch 后必须重新验证完整 routes；`No goals to be solved` 有基于新 Lean diagnostics 的确定性 cleanup。C08 完整 route replay 通过，C01 本轮实时请求因 HTTP 402 未进入生成后修复。 |
| Kernel 与依赖审计 | `lean-runtime/Jijian/Audit.lean` 从独立 proof wire 重建声明，检查 theorem type 与锁定目标 definitional equality，添加 theorem 触发 Lean kernel checker 并收集 axioms；对 `jjdep_*` binder 做表达式使用审计。 | Lean 候选 proof code 在隔离 Lean 进程运行；Kernel auditor 不导入候选模块、不执行候选 tactic，批内候选环境隔离。完整路线还要求所有 claims 通过、目标 Kernel、目标依赖闭包、每条声明依赖真实使用和 composition 状态可接受。 |
| 来源语义一致性 | compiler 保留 sourceRefs 并在 MathIR 约束范围内确定性 lower；识别/结构化模型输出是来源解释。 | `verify.py` 明确返回 `semanticAlignmentKernelProven: false`。当前 Kernel 证明的是锁定 Typed MathIR 命题，不能单独证明中文/手写原稿与该命题同义；应把该风险保留在能力声明中。 |
| 产品入口 | `Services.pipeline` 和 `backend/api.py` 当前仍调用 v1 `MathIR`、v1 formalization/verification/repair；检索没有发现它们调用 `backend.v2.workflow.complete_and_verify_proof_routes` 的 API 接线。 | C01–C15 的 v2 结果证明研究侧 v2 工作流能力，不是当前 SwiftUI 正式 App 已经使用 v2 的端到端证据。保持现有 App 稳定期间，本轮未擅自改 API/UI 产品契约。 |

因此目前可确定的工程状态是：v2 的 proof 生成、Lean diagnostics repair、Kernel 依赖使用审计和整路线判定已在同一研究工作流函数中串接。2026-10-11 收尾回归运行 `pytest -q -m 'not live and not live_ai and not lean_local'`，409 项通过、1 项失败、19 项因标记未运行；失败为 `test_induction_obligations_close_root_definition_binders_without_promoting_sum_index`，确定性校验返回 `V2_INDUCTION_BASE`，尚未进入 Lean。本轮按暂停要求保留该失败而未继续修题。仍不能宣称 v2 已接管当前产品入口，也不能把 Kernel 对 Typed MathIR 的证明外推成原稿语义等价证明。

## 真实 Lean / Kernel 能力矩阵

“固定命题”表示锁定 Lean statement 自身有独立 Kernel 证书；“原路线”要求原稿节点、依赖闭包和路线组合都成立。`未证明` 不表示数学命题为假。

| 样本 | 原文 / 结构核验 | 首次可复核阻塞或结果 | 固定命题 Kernel | 原路线 Kernel |
|---|---|---|---:|---:|
| C01 多步实数不等式 | faithful；9 个源步骤 | 初次每个步骤均有局部 Kernel 证书，但依赖组合缺少一个实际使用的前提；一次 Flash repair 后完整闭包成立 | 通过 | 通过 |
| C02 平方和步骤 | faithful；10 个 SourceRef | 对 `n3` 原式的反例 `a=b=c=1` 由 Lean/Kernel 验证，说明原步骤等式本身错误 | 非固定命题结果 | 未通过 |
| C03 不等式乘积 | faithful MathIR 可编译；6 节点 / 12 个 sourceRefs | 新增一次保存结构 proof-only 尝试，但 provider 返回 HTTP 402，尚未取得 proof response；Lean 未启动。旧内存事件也无可恢复 proof | 未执行 | 未执行 |
| C04 从 1 开始的有限和归纳 | faithful；Statement Lock 保持；15 个原路线节点 | 当前完整 proof workflow 重放第一份保存的真实 Flash 响应（11 个 patch）；12 个 proof obligations 均未 Kernel 通过。`base_conclusion` 缺 proof；`step_conclusion` 首个 Lean 阻塞是 rewrite 目标与当前依赖上下文不匹配；其余 10 项首诊断为 `dsimp made no progress`。另一次不同 proof-wire replay 中 `step_sum` 与 `step_double_chain` 局部通过，但两次的 fixed theorem 与原路线都未通过。第二个基例请求只保存了 provider 失败记录，没有响应。 | 未通过 | 未通过 |
| C05 含错误项的参数归纳 | faithful；`n+m` 原样保留 | `base_conclusion` 和 `step3` 缺 proof，`step4_conclusion` Lean 失败；可用局部证明也不能建立原稿错误关系 | 未通过 | 未通过 |
| C07 立方和归纳 | faithful MathIR 可编译 | 本轮没有保存 proof-only/Kernel 路线运行 | 未执行 | 未执行 |
| C08 有理数有限和 | faithful；8 个 SourceRef | 经通用 proof workflow 重放保存的 Flash patch；Lean 对 `n1` 报 `No goals to be solved` 后，workflow 的确定性 cleanup 仅移除该尾部 tactic，再完整复核整条原路线 | 通过 | 通过 |
| C10 多项式双路线 | faithful；定义及两路线分开 | 当前 compiler replay：两条 route DAG 均连通；7/7 obligation 未通过，`nA1` 首个 Lean failure 为 `dsimp made no progress`，`nB2` 缺 proof；两条路线分别未闭合 | 未通过 | 两条均未通过 |
| C11 除法恒等式 | faithful MathIR 可编译 | 固定命题否定以 `x=1,y=0` 的显式见证通过 Lean/Kernel；原路线仍因未解析的局部引用和缺 proof 而未通过 | 反例 Kernel 通过 | 未通过 |
| C12 有界实数全称命题 | faithful；量词顺序不变 | `n3` statement 未 elaboration，缺 proof / proof 错误；固定命题的否定（对任意 M 取 `x=M+1`）由 Kernel 验证 | 固定命题被反例否定 | 未通过 |
| C13 循环论证 | faithful；循环假设无 proof | 4/4 个实际步骤各自有 Kernel 证书，但组合器拒绝把 `n_step1_assume` 当作 theorem 前提；5 条依赖边中 2 条未使用。循环节点不能靠单步证书获得路线通过 | 未通过 | 未通过 |
| C14 整除见证 | faithful MathIR 可编译；9 个源节点 | 真实 Lean 报告 `Nat.Coprime.mul_dvd` 为 Unknown constant；额外 `#check` 验证候选 `Nat.Coprime.mul_dvd_of_dvd_of_dvd` 存在且给出真实签名，但没有改 proof 或把候选名冒充为已修复证明；`c_goal` 仍缺 proof。组合状态 incomplete，原因是缺原稿 proofTerm | 未通过 | 未通过 |
| C15 平方相等推出相等 | faithful MathIR 可编译 | 固定命题缺少符号限制；`x=1,y=−1` 对其否定由 Kernel 验证 | 固定命题被反例否定 | 未通过 |

计数上，当前已保存结果中三条完整原路线 Kernel 通过（C01、C07、C08）；另有局部 proof/kernel 证书，但没有闭合其路线（C04/C05/C10/C12/C13/C14）。C02、C11、C12、C15 的反例证书是关于原稿或固定命题错误的证据，不是用户正向路线通过。

在 2026-10-11 的一次新 C01 真实自动工作流中，使用未填 proofTerm 的已保存 MathIR，没有重新识别或重建 MathIR。当前账户余额不足，Mathlib `LibraryPlan` 和 proof-only `FormalProofs` 两个独立请求均以 HTTP 402 失败（各 retry_index=0、token usage 未返回），因此本次运行没有进入 Lean。此前 C01 完整路线通过仍是已保存真实 Flash patch 的 record replay + 当前 Lean/Kernel 复核，不能当成本次实时自动生成/修复成功。请求与资源记录见 [C01 live attempt](mathir-v2-proof-loop-C01-20261011-102552.json)。本轮 `pytest -q` 为 399 passed、1 skipped、2 deselected（15:07）；`scripts/check_examples.py` 的示例 Lean/Kernel 证书也通过。默认 pytest 排除了两项显式 `live_ai` 测试，因此这些结果不构成真实 DeepSeek 成功证据。

证据分列见 [Stage 8 machine evidence](mathir-v2-stage8-evidence.json)、[Stage 9 automatic repair](mathir-v2-stage9-automatic-repair.json)、[Stage 9 C04 route evidence](mathir-v2-stage9-C04-route-evidence.json)、[Stage 9 C05/C10/C12 replay](mathir-v2-stage9-postfix-C05-C10-C12.json)、[C02 step counterexample](mathir-v2-C02-n3-counterexample.json)、[fixed statement counterexamples](mathir-v2-fixed-statement-counterexamples.json)。C04 的 patch 遗失证据及其限制详见 [Stage 9 report](mathir-v2-stage9-automatic-repair-results.md)。

## DeepSeek 请求和执行资源

本轮 proof-only 尝试只使用保存 MathIR：C02、C05、C03 各一次真实 `deepseek-flash` 请求，均 `retry_index=0`、缓存未命中、输入 hash 各异，没有图片上传，也没有重复 MathIR 生成。C05 和 C03 provider 均返回 HTTP 402 `Insufficient Balance`；C02 的首版脚本只保留了 `AI_PROVIDER_ERROR` 和 496.235 ms，没保留 HTTP 状态和 provider 文本，因此不能推测它也是 402。三次都没有可用 token 或 proof response，也没有重试。C03 本轮完整工作流在 provider 阶段停止，未启动 Lean；原题、MathIR、statement hash 与来源映射仍已保存，新增调用审计见 [C03 proof-loop record](mathir-v2-proof-loop-C03-current.json)。其余失败调用详见 [provider failure ledger](mathir-v2-proof-loop-provider-failures.json)。

已保存的 Stage 8/9 live 记录覆盖 17 次真实请求尝试：Stage 8 为 11 次（其中 1 次中断请求无 token usage），Stage 9 为 6 次；详见各阶段 request ledger 和报告。所有历史请求、token、hash、耗时、retry/cache 字段见 [Stage 8 ledger](mathir-v2-stage8-request-ledger.json)、[Stage 9 result bundle](mathir-v2-stage9-results.json) 和上述失败账本。不要把这些历史调用计入本轮新增调用。

关键耗时 / 资源：Stage 8 C01 约 110.5 秒，Python 峰值约 1.57 GiB、回收子进程峰值约 5.93 GiB；Stage 9 C05/C10/C12 的本地重放分别约 119.49/133.593/53.323 秒；C04 可恢复 proof 重放约 218.481 秒，Lean 峰值约 0.934 GiB；C13/C14 旧 proof 重放分别约 42.2/42.9 秒，Lean 峰值约 1.03/1.12 GiB。复杂证明仍应串行运行，wire 证据使用 SHA-256 gzip 独立文件保存。

本轮发现并修复一项 Lean runner 证据归属缺陷：批量 proof-export 宏错误有时都报告在 Lean 行 1，按行号会把一个步骤的错误附到另一个步骤。runner 现在按 Lean 输出事件顺序和 nonce 记录归属，并将无候选边界的错误作为 batch/global 诊断。kernel replay 也应用相同方法。合成回归和两候选真实 Lean/Kernel 回归均通过，避免失败位置污染路线报告。该修复不改变 statement、proof 或 Kernel 判定。

另补齐了 v2 workflow 的异常证据保全：初始 Mathlib retrieval 与诊断 repair Provider 抛出 `AppError` 时，返回当前 Lean/Kernel 结果、验证历史、失败阶段和 repair input hash；失败 provenance 不足时 `provider_called` 标记为未知，由 request audit 统计实际请求。新增两项回归；`tests/v2/test_workflow.py tests/v2/test_mathir_v2.py tests/v2/test_v2_kernel.py -m 'not lean_local'` 当前为 55 passed、9 deselected。v1 API 与产品路径未改。源码调用图与字段责任见 [workflow contract map](mathir-v2-workflow-contract-map.md)。

C13/C14 的当前 exact-route replay 现在保留 composition status/error、每步 dependsOn、dependency usage、failure class 和诊断，而不是只留通过数。新组合规则只允许将与当前目标无关、无约束的路线局部变量实例化为类型的封闭默认项（Nat/Int/Rat/Real 的零）；目标自由变量不在锁定 theorem context 时仍会拒绝，局部假设仍必须映射为锁定 theorem 中显式假设。3 项定向回归通过，其中 1 项真实 Lean/Kernel 验证了局部变量下的依赖组合。该规则未使 C14 路线通过，因为它仍有 Lean 常量错误和缺失的最终 proof。

对现有 C01 真实 repair 记录做了本地 payload 重建：当前 `diagnostic_repair_payload` 仍选择真实记录中的两个步骤（`n_step4_intermediate`、`n_final`），未使用依赖 ID 相同。新加入的依赖审计状态字段使当前 `diagnosticHash` 与历史 patch hash 不同；原始历史 request body 未保存，故不把重建 hash 冒充历史 hash。历史真实请求为 8,324 输入 / 22,035 输出 tokens，约 71.889 秒，retry 0；修复后固定命题和完整原路线 Kernel 都通过。证据见 [C01 repair payload reconstruction](mathir-v2-C01-repair-payload-reconstruction.json)。

为确认更新后的共同编排器能执行这一契约，另将 C01 的原始 Stage 8 Flash proofTerms 和 Stage 9 的真实 Flash 修复 patch 经 provenance/statement hash 校验后输入当前 `complete_and_verify_proof_routes`，并使用本地 record-replay provider 重放那次实际响应。当前 Lean 首轮再次检测 `n_step4_intermediate` 未用 `n_step3a/n_step3b`、`n_final` 未用 `n_pos2`；workflow 自动选中相同两步，repair payload 明确携带这些 ID、命题和 Kernel 使用证据。回放返回已保存的真实模型 patch 后，完整原路线及固定 theorem Kernel 均通过，statement hash 不变。该集成回放新增 live DeepSeek 请求为 0；它验证编排与 Lean 接线，不替代当年一次真实 Flash 请求，也不宣称本轮模型新生成了 proof。总耗时 757.329 秒，42 个 Lean 子进程阶段串行，峰值并发 1。详见 [C01 common workflow replay](mathir-v2-C01-common-workflow-replay.json) 和 [replay harness](../scripts/replay_c01_saved_flash_patch_through_workflow.py)。

对当前通用 workflow 的再次源码审计还发现，初版 `_terms()` 把 MathIR 中所有已有 proofTerm 当作本轮生成项，可能允许 repair 覆盖预存证明。现已改成仅把本次 `proof_only_generation` 返回的 patch 记入可修复集合；预存 proofTerm 继续受 ProofLock 保护。新增回归测试覆盖失败的预存 proof 不进入 repair，且已有 repair-loop 测试确认后续轮次只允许替换当前 workflow 的生成项。该保护修复尚未在真实 DeepSeek 调用中运行，因为本轮 C05 的 live 请求已返回 402。

C08 使用保存的真实 Lean diagnostics 和 Flash patch，通过通用 `complete_and_verify_proof_routes` 完整重放：workflow 依据原始 MathIR 全空 proofTerm 记录及相同 statement hash 校验保存 patch 的 AI 来源，再将这些 term 传入自动 repair；Lean 对 `n1` 报 `No goals to be solved` 后，cleanup 仅移除该尾部 tactic，候选自身通过真实 Lean/独立 Kernel 检查，再完整复核整条原路线。固定命题 Kernel 和原路线 Kernel 均通过，DeepSeek 请求为 0，耗时 366.338 秒；共 27 个 Lean 子进程阶段串行执行，峰值并发为 1。两轮验证、workflow 事件、wire 哈希和每步状态见 [C08 current workflow rerun](mathir-v2-C08-current-workflow-rerun.json)；可复跑脚本为 [replay_stage9_c08_deterministic_workflow.py](../scripts/replay_stage9_c08_deterministic_workflow.py)。

Repair 审计还补上了 `dependency_usage_not_audited` 分支。过去路线会保持 incomplete，但 payload 可能因 Lean proof 已通过而跳过该节点；现在分别列出 `unusedDependencyIds` 和 `unauditedDependencyIds`，未知审计状态不会被伪装成已证实未使用。新增测试确认该节点会进入 Repair 输入，且 `unusedDependencyIds` 仍为空。

## 语义步骤表示对照

隔离 parser 只覆盖已审阅的三个片段：C05 的 `n+m`、C10 的 `Q(X)=P(X)(X−1)`、C12 的存在/全称量词句。它使用确定性语法、局部类型约束及符号绑定，再 lower 回现有 `Expr`：3/3 与原 Typed MathIR 子树规范化后完全相等；编译均成功且 statement hash 相同；C05 错项、C10 因子和 C12 量词次序均保留。耗时约 0.078 秒，Python 峰值约 2.07 MB，0 token、0 Lean 调用。详情见 [roundtrip evidence](mathir-v2-stage8-semantic-roundtrip.json) 和 [isolated parser](../devtools/research/mathir_v2_stage8/semantic_roundtrip.py)。

因为 lowering 是 AST 恒等变换，Lean 编译输入、proof obligation 和 proof term 也完全相同；所以在同一保存 proof 下，Kernel 能力不会因表示层恒等重排而改变。Stage 9 直接 Typed MathIR 的 Kernel 结果已经展示了实际能力：C05/C10/C12 都未闭合。这个结论是由输出 AST/hash 恒等和现有 Lean 结果支持的，不是跨模型调用的严格 A/B，也不声称通用识别正确率提升。新表示值得保留为局部 parser 的输入形式，但没有证据要求在当前架构前再插入一层通用翻译器。

## 当前 v2 模块调用与数据契约

本研究调用链实际为“保存原稿 / 保存 MathIR v2 → `compile_v2` → 生成缺失 obligations → proof-only provider → ProofLock 校验 patch → `verify_v2` → 依赖和路线审计 → 诊断 Repair → 再次全路线验证”。`scripts/run_mathir_v2_saved_proof_loop.py` 仅从保存结构启动，不会再次识别图片；原始输入结构与 proof patch 分别以 JSON 和内容哈希 wire 保存。

- 语义 AST、Binder、Scope 和 Definition 的结构检查由 `backend/v2/models.py`、`typecheck.py` 完成。`compile_v2` 先做符号引用规范化、可证明语义保持的结构规范化及 `validate_v2`，再由 `V2Compiler` 渲染 theorem 和 proof obligations。该前置检查负责拒绝不一致的 Typed MathIR；它不是 Lean 的替代品。`verify_v2` 批量 probe 预期类型，并把每项 proof 交给隔离 Lean/Kernel，最终 `localVerified` 只接受 Kernel 证书。
- 变量与量词不会由一个未知字符串上下文隐式重推：MathIR `symbolId` / `binderId` 和 `scopeId` 是结构来源；编译器根据同一 AST 构造 theorem/local context，Lean Elaborator 检查构造出的类型。这里有刻意分层的结构类型检查与 Lean 检查，前者不签发证明，后者不证明 MathIR 忠实对应原稿。
- `ProofLock.statement_hash` 锁定 Lean theorem，`structural_hash` 锁定除 proofTerm 外的 MathIR、SourceRef 和依赖图。`FormalProofs` 只允许 `{nodeId, proofTerm}`；补丁通过锁后仍需全路线 Kernel 检查。Repair 只纳入本轮生成的 proof 或带来源记录、且与当前锁定项完全匹配的先前生成 proof；用户预存 proof 默认不进入可修改集合。
- `verify_v2` 把 statement probe 和有效 proof checks 批量送给 runner，runner 对每个候选单独导出和独立 Kernel replay。步骤通过、依赖 binder-use、目标依赖闭包、结构归纳组合及固定 theorem Kernel 是独立判定项；只有这些条件齐全才令 `anyRouteKernelPassed` 为真。循环的局部假设不能冒充 theorem 外部假设。
- Repair payload保留当前 Lean diagnostics 实例、源片段、目标、上下文、依赖节点及 `unused` / `not_audited` 证据。repair 仅替换授权 proofTerm，Statement Lock 和 MathIR 结构在接受及重验时再次核对。完全相同的 repair input 不重复提交；Lean 无新诊断就不会产生新的 Flash 修复依据。
- 当前 v2 workflow 是独立研究模块，由保存样本脚本调用，尚未挂接至正式 v1 `/api/pipeline` 或 SwiftUI 客户端；本轮也没有把它伪装成 v1 生产能力。Mathlib Retriever 已作为可选协作者接入研究脚本：失败被保留为 retrieval 证据而不是改变 statement 或绕过 Kernel；其模型计划调用需真实 provider，故本轮没有使用 live 证据宣称 prompt 效果。

重要的语义边界仍未解决：原稿字符串、SourceRef 范围正确以及 MathIR 成功编译，并不能由 Lean 证明其数学含义完全等价；`sourceAssessment=supported` 和 `semanticAlignment` 也不是 Kernel 证书。若 MathIR 把原稿读错，Statement Lock 会忠实锁定错误翻译后的 theorem。现有报告只在有可复核字符来源或保留错误结构的题目上记录忠实性，不将编译通过写成原稿语义正确。

## 归纳依赖与组合契约修复

源码审计发现归纳步骤曾被统一标记为 `local_context_kernel_checked`，从而绕过 `Jijian.Audit` 对声明依赖 binder 的实际使用审计。真实 Lean 反例确认：对 `n + 0 = n`，步骤能单独通过 Kernel、固定定理也能通过，但 proof 可被 `simp` 独立完成而不使用 IH；旧逻辑仍可能把这条原路线当作成立。现在编译器给 IH 和显式步条件生成 `jjdep_<nodeId>` binder，复用独立 Kernel 的 binder-use 审计；未使用依赖会成为 `declared_dependency_unused`，并进入只修改生成 proofTerm 的 Repair payload。移除了 `local_context_kernel_checked` 对验证和 Repair 的豁免。

同一真实验证还暴露普通 `Nat.rec` 组合器的两个确定性错误：motive 使用未绑定名字，以及把已是函数型的 step proof 再包一层 lambda。现已用显式 motive binder，并直接传入已闭合的 step proof；只有 `NatLowerBoundInduction` 会引入下界证明。它们不改变锁定命题或 Kernel 检查。

本机真实 Lean/独立 Kernel 回归：幂恒等式 `2^n · 2^n = 4^n` 的归纳 proof 实际使用 IH，固定定理与完整原路线均通过，binder audit 为 `ih: used=true`；对恒真但不需要 IH 的 `n+0=n`，固定定理 Kernel 通过、局部 step Kernel 通过、`ih: used=false`，路线保持 incomplete，且 Repair payload 精确列出 `unusedDependencyIds=[ih]`。两项总计约 81.661 秒、串行、DeepSeek 0 次，Lean 子进程与 RSS 分项见 [induction dependency audit evidence](mathir-v2-induction-dependency-audit-fix.json)。定向本地回归为 51 passed、8 个 Lean-local 项 deselected；三个选择性真实 Lean 回归（成功归纳、漏用 IH 反例、旧 Kernel 矩阵）已各自通过。

C04/C05 的已有报告含旧的 `local_context_kernel_checked` 标签；这些历史 Kernel 结果没有依赖使用证明，不能沿用作当前归纳路线通过证据。C04 已用当前编译器重放；C05 的当前编译器与依赖审计回放见下方记录。两题都未报告为原路线通过。

## 后续单样本 proof-only 尝试（C07）

为补测尚无 proof 记录的立方和归纳样本，使用已保存并可编译的 C07 MathIR 启动一次 proof workflow；没有重识别图片或再生成 MathIR。脚本初次默认读项目 `.env`，未配置 Provider，因此那次启动在发请求前退出（0 请求）。随后显式指定 Mac App 的 `server.env` 重跑，实际审计产生 2 个真实请求：`LibraryPlan`（stage=other）和 `FormalProofs`（stage=formalization），均 `retry_index=0`、缓存 miss、使用不同 input hash，分别耗时 528.943 ms 与 436.545 ms。两者均因上游 HTTP 402 `Insufficient Balance` 失败，输入/输出 token 均未知，没有 proof 响应；Lean 没有启动，故本样本的固定命题 Kernel 与原路线 Kernel 仍为未执行。没有重复输入、重试或视觉调用。完整字段见 [C07 proof-loop record](mathir-v2-proof-loop-C07-20261011-062226.json)；汇总已加入 [system capability matrix](mathir-v2-system-capability-matrix.json)。

该尝试能确认流程在构造 proof-only 请求前会先调用 Mathlib `LibraryPlan`；这是当前工作流的真实额外模型阶段，不能把两次请求说成一次 proof-only 调用，也不能在余额错误时推断 Flash 的证明能力。它没有证据支持更改模型路由、检索契约或生产逻辑；要取得 C07 的数学能力证据，需要 Provider 返回 proof 后再让现有 Lean/Kernel 检查。

## 验证记录和接入建议

- 真实 Lean 批量诊断归属回归：`test_real_lean_batch_keeps_failed_candidate_diagnostics_scoped`，通过，25.13 秒；检查 `by rfl` 对 `1=2` 和未知标识符只落在各自候选。
- 诊断事件顺序单元回归：通过。
- 早期本地回归曾为 48 passed；最终新增 Mathlib 检索契约测试后为 49 passed，6 个 Lean 标记测试未在该命令执行，Lean 标记回归另行执行。
- 历史 Lean-local 回归记录曾为 4 passed、3 deselected（480.23 秒）。归纳编译器和依赖上下文调整后，本轮重新执行 `tests/v2/test_v2_kernel.py -m lean_local -q`：7 passed、3 deselected，599.98 秒；全部运行项使用真实 Lean/独立 Kernel，DeepSeek 请求为 0。
- 路线局部 binder 组合回归：3 passed、39.59 秒，其中 1 项真实 Lean/Kernel 验证，0 DeepSeek 请求。记录见 [local-context composition regression](mathir-v2-local-context-composition-regression.json)。
- C14 Mathlib 名称核查：真实本机 Lean/Mathlib `#check` 显示旧名不存在、候选签名存在；这只定位了名称错误，未修改原证明。记录见 [C14 name check](mathir-v2-C14-mathlib-name-check.json)，可用 [复核脚本](../scripts/check_c14_mathlib_names.py) 重跑。
- 本轮最终普通回归命令 `tests/v2/test_workflow.py tests/v2/test_mathir_v2.py tests/v2/test_v2_kernel.py -m 'not lean_local'`：51 passed、6 个 Lean 标记测试被排除；单独的 `tests/v2/test_workflow.py` 为 6 passed。workflow 可接收有外部来源记录、且与锁定 MathIR 当前 term 完全一致的先前生成 proof；默认仍不修预存 proof。检索接线仅对有缺失 obligation 或可修复 diagnostics 的阶段执行，并把完整检索对象交给 proof prompt。C08 通过此共同 workflow 的真实 Lean 回放，无 provider 请求。
- 完整默认测试套件 `.venv/bin/python -m pytest -q` 最终结果：386 passed、1 skipped、2 deselected，806.11 秒。首次全跑发现两个过期断言：Lean 资源断言未区分 Lean 子进程与线材质化记录；diagnosticHash 断言未包含依赖审计和 failureClass。各自修正后定向回归为 3 passed，第二次全套通过。唯一 skip 是显式 macOS live 环境要求；两个 deselected 为 pytest 配置排除的 `live_ai` 测试。普通全量测试没有 DeepSeek 请求。
- 此前报告所统计的新增 proof-loop 请求为 3 次（C02/C05/C03）；本轮后续 C07 又实际尝试 2 次：LibraryPlan 与 FormalProofs 各一次，均因 HTTP 402 失败、token usage 不可用、retry 0。两次 input hash 不同；没有相同请求重发或 Lean 执行。除这一次有边界的 C07 尝试外，没有运行大规模 live 矩阵。

建议保持 Typed MathIR v2 为当前翻译契约。若后续接入语义解析，只对表达式、声明定义和量词作用域明确的片段启用；lower 前保留原文 span、binder/type 证据，要求输出 AST 与约束核验可复核，冲突时报告未确定。这个建议没有接入正式 App。本轮新增的 proof-only 编排和 runner 诊断归属修复仅位于 v2/研究代码，不更改生产 v1 数学流程。


## C05 当前验证器依赖审计回放

使用保存的 C05 MathIR 和原 proof wire，在本机 Lean 4.34.0 / 独立 Kernel 上串行重放；没有 DeepSeek 请求。statement hash 与 Stage 8 锁一致，原始文本匹配，16 个 SourceRef 均处在原文范围内；错误的 `n+m` 新增项仍在 `step3` 表达式中，没有被改正。

重放共 9 个 Lean 进程阶段，约 119.305 秒，最多并发 1。`step4` 的局部证明通过 Lean/Kernel，binder-use 审计确认它实际使用了 `induction_hypothesis` 和 `step3` 两条依赖。这个证书只证明该节点在所声明前提下成立。`base_conclusion` 没有 proofTerm，`step3` 没有 proofTerm；`step4_conclusion` 的现存 proofTerm 在编译时失败，Lean 报告其重写目标落入 `ih` 标识符而不是归纳步的目标。固定 theorem 和原路线 Kernel 均未通过。

因此，本次修复消除了“归纳步骤可绕过 IH 仍算路线通过”的审计漏洞，但没有解决把 source dependency DAG 组合进归纳基例/步证明的编译问题，也没有补出缺失 proof。不能将 `step4` 的局部 Kernel 证书记为固定命题或原路线通过。完整诊断、dependencyUsage、Statement Lock、Lean 资源记录见 [C05 dependency-audit replay](mathir-v2-C05-dependency-audit-replay.json)；逐节点汇总已写入 [system capability matrix](mathir-v2-system-capability-matrix.json)。


### C05 最新编译器重放结果（取代前一份当前版本读数）

修复归纳 motive、step proof 重复 lambda 和实际依赖 binder 后，再次串行重放 C05：statement Lock 保持，原文一致，16 个 SourceRef 有效，`n+m` 错误项仍保留；0 次 Provider 请求。9 个 Lean 进程阶段耗时 122.879 秒。`base_calc_1` 与 `base_calc_2`、`step4` 通过；其中 `step4` 两条声明依赖（归纳假设及 `step3`）均由 Kernel 表达式审计确认使用。`base_conclusion` 与 `step3` 仍缺 proofTerm。`step4_conclusion` 有一个指向 `step4` 的声明边，但模型 proof 在 Lean 编译失败，因而没有依赖使用审计。固定 theorem Kernel 和原路线 Kernel 都未通过。

在后续批量 runner 和作用域修正之后，又用当前工作区对保存 C05 结构及 proof wires 做了合批重放。原文、Statement Lock 与 `n+m` 错项保持，DeepSeek 请求为 0；耗时 38.9 秒、3 个 Lean 阶段、串行并发 1。六个当前 proof obligations 中 `base_calc_1`、`base_calc_2`、`step4` 通过 Kernel；`base_conclusion` 和 `step3` 缺 proof，`step4_conclusion` 仍有 Lean rewrite 失败且 dependency audit 为 `dependency_usage_not_audited`。固定 statement 和原路线均未通过。该当前结果覆盖前段 9 阶段重放，详情见 [C05 current compiler route replay](mathir-v2-C05-current-compiler-route-replay-20261011.json) 与矩阵。

两个真实归纳回归（真实 Lean + 独立 Kernel）现在通过：幂恒等式路线实际使用 IH 后完成 Kernel；`n+0=n` 的证明忽略其声明 IH 时，固定 theorem 通过而路线被拒绝。回归共 82.01 秒、DeepSeek 0 次。定向 Python 回归为 51 passed、8 deselected（MathIR、workflow 和 Kernel 的非 Lean-local 测试）。详细结果见 [C05 final route audit](mathir-v2-C05-final-route-audit.json) 和依赖审计测试代码。


### 当前 v2 Lean 回归与 C05 证据状态

本轮最终验证：`tests/v2/test_v2_kernel.py -m lean_local -q` 为 7 passed、3 deselected（599.98 秒），`tests/v2/test_v2_kernel.py -m 'not lean_local' tests/v2/test_mathir_v2.py tests/v2/test_workflow.py -q` 为 51 passed、8 deselected；两者均没有 DeepSeek 请求。Lean-local 集合运行时 `lean_parallelism=1`，但 pytest 汇总没有输出完整进程资源表，因此不推断该集合的峰值内存。C05 单题串行回放有独立阶段计量：122.879 秒、9 个 Lean 进程阶段，详见 [C05 final route audit](mathir-v2-C05-final-route-audit.json)。

历史 C04/C05 `local_context_kernel_checked` 标签均不再视作依赖使用证明。C05 已有当前编译器回放：step4 的两个依赖审计通过，但基例结论与 step3 缺 proofTerm，step4_conclusion 编译失败，固定 theorem 与原路线 Kernel 都未通过。C04 的最新批量 saved-route replay 见下一节；两题完整原路线都没有 Kernel 通过结果。


### C04 当前依赖审计回放

用当前编译器串行重放保存的 C04 MathIR 与 11 个已有 proof/repair proofTerm；不调用 Provider，也不把这次重放称为新模型生成。statement hash 保持。原路线共 15 个节点，其中 12 个可检查 proof obligation；2 个 Lean/Kernel 通过、10 个未通过。首个路线阻塞是 `base_conclusion` 缺少 proofTerm。`step_sum` 与 `step_double_chain` 有 Kernel 证书；后者审计确认实际使用 `step_double_expand`、`step_substitute`、`ih_eq` 三个声明依赖。其余 Lean 失败主要为 `dsimp made no progress`，归纳 `step_conclusion` 的 rewrite 目标与实际上下文不匹配。固定 statement 与完整原路线均未通过。最新合批回放耗时 38.28 秒、3 个 Lean 进程阶段、串行并发 1；Lean 最大 macOS footprint 943,108,160 bytes、子进程组 RSS 6,066,552,832 bytes，Python 峰值 RSS 82,755,584 bytes。两个通过步骤的完整 Kernel wires 分别为 309,028 和 463,893 bytes，按 SHA-256 gzip 外置保存。逐阶段与资源证据见 [C04 current compiler route replay](mathir-v2-C04-current-compiler-route-replay-20261011.json)。

历史单节点回放曾耗时约 199 秒、15 个 Lean 进程阶段；当前批量回放把 proof 检查和 Kernel replay 合并为 3 个 Lean 进程阶段，耗时 38.28 秒。前一组资源记录仍保留在 [C04 final route audit](mathir-v2-C04-final-route-audit.json)，当前资源记录见上方回放与 [system capability matrix](mathir-v2-system-capability-matrix.json)。

对 C04 另做了一个确定性 tactic 清理探针：从上述已保存诊断中筛出 8 个含 `` `dsimp` made no progress `` 的步骤，移除各自唯一独立的 `dsimp` 行，然后用当前 Lean 和 Kernel/依赖使用审计逐项检查。8 个候选均未通过接受条件，没有 proof patch，因此没有执行修改后的整路线验证；0 Provider 请求，串行耗时 215.827 秒。结论是这些失败不能靠删掉这条 no-op tactic 解决，主要障碍仍在缺失 proof 与后续证明/依赖要求。该探针不留作自动 repair 路径，避免未来对每次相同诊断都额外启动昂贵 Lean 检查。逐候选证据见 [C04 dsimp cleanup candidate check](mathir-v2-C04-dsimp-candidate-check.json)。

## 本轮保存结构到 Lean/Kernel 的追加重放

2026-10-11 使用 Stage 8 已保存的 proof-only MathIR 对 C05、C10、C12 逐题重放 `verify_v2`。Provider/DeepSeek 请求为 0；不重新识别、不重建 MathIR，也不改 proof wire。Lean 串行、最大并发 1，20 个 Lean 子进程阶段；逐题耗时 C05 41.142 秒、C10 54.824 秒、C12 40.813 秒。各题 Statement Lock hash 均与保存值一致。完整逐节点诊断、proof evidence hash 与 Lean 资源记录见 [saved proof Kernel replay](mathir-v2-stage10-saved-proof-kernel-replay-20261011.json)。

| 样本 | 首个路线阻塞 | 其他已确认节点 | 固定命题 Kernel | 原路线 Kernel |
|---|---|---|---:|---:|
| C05 错误参数归纳 | `base_conclusion` 没有 proof；`step4_conclusion` 的 Lean rewrite 没找到目标中的归纳步求和式 | 本轮重放 `n+m` 原样保留；局部 `base_calc_1`、`base_calc_2`、`step4` 通过。错误新增项不能由正确算术替换 | 未通过 | 未通过 |
| C10 多项式双路线 | route_A 的 `nA1` 首先报 ``dsimp made no progress``；route_B 的 `nB1` 同诊断 | route_A 的四个已存 proof 都未通过；route_B 的 `nB2` 缺 proof，`nB3` 也有同类 Lean 失败。Q 定义、额外 `(X−2)` 和两条路线边界保持；A 不作为 B 的证明 | 未通过 | 两条都未通过 |
| C12 量词顺序 | `n2` 缺 proof | `n3/n4/n5` 的局部 proof/kernel 检查通过，`n6` 缺 proof；n5 的依赖使用状态见既有 scoped replay。锁定命题保持 `∃ M, ∀ x, x<M`，其否定有 Kernel 反例证书 | 固定命题被反例否定 | 未通过 |

此前已经保存并复核的 C01 多步不等式、C08 有理数有限和完整原路线仍分别通过。C04 当前证据仍是 base proof 缺失、归纳步 rewrite mismatch 和多个 no-op `dsimp`；C03 proof-only 请求曾以余额不足 HTTP 402 结束，没有 Lean proof term 可验证；C07 有已保存结构但尚无本轮 proof-only 响应；C13 的局部证书不能跨越循环路线假设。上表把缺 proof、Lean elaboration 失败、固定命题反例和完整原路线证书分开计，不用固定命题单独成功替代路线成功。

在 workflow 异常保全改动后，又用 C08 已保存的真实 Flash proof 与真实 Lean diagnostics 重放通用工作流：自动 patch 仍只作用于 `n1` 的 `No goals to be solved` 尾部 tactic；Lean 候选检查、独立 Kernel 与全路线复核通过。Statement Lock 保持、Provider 请求 0、耗时 127.202 秒。证据见 [C08 automatic cleanup replay](mathir-v2-C08-automatic-cleanup-replay.json)，能力矩阵已使用这次 common-workflow replay 作为 C08 最新路线结果。

## 语义步骤旁路扩展结果

隔离研究脚本 [semantic roundtrip](../devtools/research/mathir_v2_stage8/semantic_roundtrip.py) 现覆盖 C04/C05/C08/C10/C12 五个片段，仍只在研究目录运行。确定性语义步骤经绑定和类型约束后 lower 到现有 Typed MathIR；逐结构相等意味着未改变传入 compiler 的表达式。所有五个片段 lower equality、schema validation、编译均成功，C05 的 `n+m` 错误项、C10 route_B 原式、C12 量词顺序未被“修复”。最新运行耗时 0.429 秒、Python `tracemalloc` 峰值 4,225,970 bytes，模型 token 0、Lean runs 0；各样本的编译 statement hash 和 route status 均与直接 Typed MathIR 相同。

| 样本 | 轻语义步骤 | 类型/绑定结果 | lower 与原 Typed MathIR | 对原路线 Kernel 的证据 |
|---|---|---|---|---|
| C04 | 有限和 successor 规则：上界 `n+1` 的和等于上界 `n` 的和加新项 | `n,k,m : Nat`；sum bounds / summand 为 Nat | 完全相等；statement hash 与直接编译相同，路线编译状态也相同 | 现有 Lean replay 仍因基例缺 proof 和 induction rewrite mismatch 未通过；表示层没有修复 proof 能力 |
| C05 | 原样解析 `n+m` | `n,m : Nat` | 完全相等；statement hash 与直接编译相同，路线编译状态也相同 | 当前 proof wire 原路线未通过；保持原稿算术错误 |
| C08 | 解析 `8/16+4/16+2/16+1/16` | 精确 Rat literals；和为 Rat | 完全相等；statement hash 与直接编译相同，路线编译状态也相同 | 保存的真实 Flash proof 重放和当前诊断 cleanup 后，原路线 Kernel 通过；旁路没有新增证明 |
| C10 | 多项式定义 `P*(X−1)` | `P,X : Polynomial ℝ`；factor subtraction 保序 | 完全相等；statement hash 与直接编译相同，两个 route 的编译状态均不变 | 保存 proof replay 显示两路线都未闭合；C10 的直观定义变换没有解决 proof terms |
| C12 | 显式嵌套 `exists M (forall x ...)` | `M,x : Real`；body 为 Prop | 完全相等，量词未交换 | 命题本身有反例，原路线未通过；重排表示不能改变真假 |

结构 equality 加相同的原 proof wire，支持“语义旁路结果会得到同一 compiler/Lean 输入”的确定性推断；本轮也逐题对照了直接与旁路后的 statement hash 和每条路线编译状态，五题全部相同。C04/C05/C10/C12 的保存 proof 失败和 C08 成功仍引用各自实际 Lean/Kernel 重放，不把零 Lean 的 parser 脚本说成独立 Kernel 运行。严格的同条件模型 A/B 不存在：旁路无模型调用，现有 Typed MathIR 来自历史模型结构化结果。Token、模型耗时和模型能力的差异不能据此比较。当前证据说明轻语义层对可审计绑定、类型约束、来源片段和防止某些语义漂移有工程价值，但没有显示它本身能增加原路线 Kernel 成功率；不应替换正式 v2 翻译。

在前述语义旁路 replay 阶段没有新的 DeepSeek 调用。C03 最近的实时 proof-only 尝试仍是上游 HTTP 402（Insufficient Balance），未返回 token 或 proof，故当时没有重发。真实模型结果只来自已保存 Flash 响应的 replay；语义旁路完全本地确定性执行。

## 工程缺陷与契约边界

**由当前可复核证据确认的工程问题：** C04 保存结构编译成功，但当前 obligation/induction-step 证明上下文与已保存 tactic 的 rewrite 目标不一致，且基例 proof 缺失；C10 saved proof 的 `dsimp` 在 Lean 中无进展，route_B 另缺 proof；C12 两个原始节点没有 proofTerm。它们目前分别是语义/证明翻译与模型输出覆盖不足，不能由独立 Kernel 替路线补全。本轮只记录和复核这些阻塞，没有改 compiler 或 proof policy。

**不能由工程层擅自消解的契约边界：** Kernel 只证明锁定 Typed MathIR statement 与 proof term；中文/图像原稿到该 statement 的意义对应仍需来源对齐证据，不是 Kernel 证书。证明路线是否要求每个原稿步骤都进入目标依赖闭包、是否允许经验证的等价步骤跳过，以及局部步骤证书如何与完整路线状态呈现，属于产品/数学核验契约；当前实现采取严格路线依赖和依赖使用审计。C05 错误式、C10 route_B、C12 量词次序和 C13 循环论证都必须保留原样，不能以“语义纠错”提升通过率。

此前语义步骤实验未发现足以支持替换 MathIR v2 的问题，也没有证据表明该层提升了 proof-only 能力。本轮真实 C06/C09 输出与离线 replay 新确认了确定性工程缺陷：有限求和 binder 在 renderer 的类型推断中丢失；`cast` AST 被类型检查器错误拒绝；归纳 base/step 只做语法相等，无法识别透明定义展开和等价自然数多项式。已逐项修复并加本地回归测试。除此之外，`T(n)` 的表示能力、根变量/目标量词的身份契约属于 MathIR 语义设计问题，不能靠证明阶段或自动补前提掩盖。轻量语义步骤层仍只被证明能做已审阅片段的保真 lowering，不会自动解决这些模型输出或表示能力问题。


### C01 当前真实自动工作流尝试

使用已保存的 C01 MathIR 启动当前自动 proof workflow；没有重识别输入，也没有重新生成 MathIR。工作流先发出 `LibraryPlan`（stage `other`），再发 `FormalProofs`（stage `formalization`），共 2 次真实 DeepSeek Flash 请求，输入 hash 不同、均 retry 0 / cache miss。两次均因余额不足返回上游 HTTP 402（适配器外层报 HTTP 502）；输入与输出 token 都未知。没有 proof patch、Lean 或 Kernel 阶段，所以这不是 C01 自动修复失败的数学证据。请求审计及中止状态见 [C01 current automatic loop](mathir-v2-C01-current-automatic-loop.json)，计入最新总请求记录见 [system capability matrix](mathir-v2-system-capability-matrix.json)。

另将保存的 Stage 8 九个真实 Flash proof-only 响应和 Stage 9 两个真实 Flash dependency repair 响应，在当前编译器下按原始锁与结构顺序重放：先应用 proof-only patches，再应用两个 repair patches，然后对完整 9 步路线执行一次批量 Lean/Kernel 验证。Statement Lock 保持，9/9 步通过，n_step4_intermediate 的三条依赖与 n_final 的两条依赖均被 Kernel binder-use 审计确认使用；固定命题和原路线均通过。耗时 101.808 秒、Lean 批调用 1、DeepSeek 新请求 0。此项验证了当前编译/Kernel 与历史真实模型补丁相容；它仍是保存响应重放，不能替代本轮未成功的实时自动模型调用。逐节点独立证据见 [C01 current compiler replay](mathir-v2-C01-current-compiler-replay.json)。


### C08 当前自动诊断修复回放

C08 先前通过共同 workflow 的完整回放，耗时 364.887 秒、27 个 Lean 进程阶段、DeepSeek 0 次，证据见 [C08 current workflow rerun](mathir-v2-C08-current-workflow-rerun.json)。为验证当前编译器下的 fresh diagnostic 路径，使用保存的 MathIR 和可追溯的真实 Flash proofTerms，调用完整 `complete_and_verify_proof_routes`。fail-closed provider spy 确认 workflow 未尝试网络。当前 Lean 重新产生 `n1: No goals to be solved`，workflow 的 deterministic repair 只接受一个 `n1` patch；候选 proof 经过真实 Lean 与独立 Kernel 检查，之后重新验证整条路线。Statement Lock 与 MathIR structural hash 不变，最终 fixed statement 和原路线 Kernel 均通过。

这次 fresh diagnostic 闭环耗时 123.779 秒、9 个 Lean 进程阶段、峰值并发 1；DeepSeek 请求 0 次。修复候选 wire SHA-256 为 `13a1d64cca821165dcc13c401aabf7d474cbd74d81d2d960af1679e62afe528b`。逐阶段资源、workflow event、原诊断、patch hash 与最终全路线证书见 [C08 current diagnostics cleanup](mathir-v2-C08-current-diagnostics-cleanup-20261011.json)。它验证的是自动确定性清理和 Kernel 闭环，不是本轮新生成的模型 proof。

之后再次从相同保存的 Stage 8 Flash 响应重建当前 Lean 诊断，并将结果写入独立文件，未覆盖上述历史报告。`n1` 再次出现 `No goals to be solved`；当前 workflow 只生成 `n1` deterministic-repair patch，候选先经 Lean + 独立 Kernel 检查，再检查完整路线。固定命题和原路线均通过，Statement Lock 与 structural hash 保持，Provider 0 次。总耗时 126.672 秒；串行运行、峰值 1 个 Lean process group；9 个 Lean 阶段、合计 121.622 秒。Lean 峰值 footprint 为 928.5 MiB，Python 峰值 RSS 为 212.5 MiB；macOS `maxRssBytes` 约 5.68 GiB，包含映射页，不能等同私有内存。证明/内核 wire 按内容 hash 引用已有 gzip 证据。逐阶段命令、诊断、patch、Lean 与 Kernel 证书见 [C08 diagnostics cleanup rerun](mathir-v2-C08-current-diagnostics-cleanup-rerun-20261011.json)。该复核只证实当前自动 workflow 能处理该已保存 proof 的真实新诊断，不是 DeepSeek 生成能力的新测试。


### C10 与 C12 当前路线回放

C10 的后续当前编译器回放复用保存 MathIR/proof wires：原文匹配、Statement Lock 保持、0 次 Provider 请求，Lean 51.263 秒、4 个 Lean 进程阶段、批量检查两次（每条路线一次）。两条路线的依赖图均连通但 Kernel 状态不完整；route_A 0/4 步通过，route_B 0/3 步通过。route_A 的 nA1 首个 Lean failure 是 `dsimp made no progress`；route_B 的 nB1 也有该诊断，nB2 缺 proofTerm，nB3 编译失败。原稿中 route_B 的额外 `(X−2)` 项及两条路线的独立性均保持。固定定理和两条原路线都未通过 Kernel。完整分路线和逐阶段数据见 [C10 current compiler route replay](mathir-v2-C10-current-compiler-route-replay-20261011.json)。

C12 原文匹配、Statement Lock 保持，题目仍编译为 `∃ M, ∀ x, x < M`，没有交换量词。此前 53.114 秒的诊断归属结果已被下方本轮重放取代；旧批量 expected-type 宏会把后续节点的 Lean 错误归到首个候选，不能再引用其 n3 失败作为当前事实。原固定命题由反例记录判为假，不是单纯未证明。逐节点新证据见 [当前 scoped dependency replay](mathir-v2-C12-scoped-dependency-replay-20261011.json)。


### C10/C12 当前生成与 Repair 契约核对

基于最新 Lean 回放结果和已保存的 proof-term 来源记录，在本机重新构造 proof-only generation 与 diagnostic Repair payload；没有调用 Provider，也没有再次启动 Lean。C10 的缺失 `nB2` 被列入 proof generation；六个已有、来源可追溯且失败的 proofTerm（nA1–nA4、nB1、nB3）进入 diagnostics Repair，未通过的依赖审计附在目标任务中。C12 的 n2/n6 进入 proof generation，n3 expected-type elaboration 失败与 n5 proof 编译失败进入 Repair。两题 Statement Lock 均与保存模型记录一致。此项只证明当前工作流正确构造了任务，不代表模型已修复或路线已通过。节点与 proofTerm hash 可见 [C10/C12 repair payload audit](mathir-v2-C10-C12-current-repair-payload-audit.json)。

### C12 修正后的作用域与路线闭环

针对上述错误诊断归属，Lean expected-type 宏现在为每个候选输出带 nonce 的失败标记，Python runner 只把对应 nonce 的错误交回对应节点；JSON `data` 诊断也会先解码再匹配。另修复 v2 obligation 编译：依赖节点以其完整检查类型递归进入下游 context，父节点自由变量在依赖族外统一绑定。真实 `lake build Jijian` 成功，新增的批量 nonce 真实 Lean 回归通过。


### C04 保存响应经当前完整 workflow 的真实 Lean / Kernel 闭环

本轮从保存的 C04 MathIR 重走当前 `complete_and_verify_proof_routes`，使用第一份已记录的真实 DeepSeek Flash `FormalProofs` 响应；没有调用网络，也没有重新生成 MathIR。该 Flash 响应实际包含 11 个 proof patch，历史 usage 为 10,451 输入 token、18,836 输出 token（总计 29,287），HTTP 耗时 70.371 秒。工作流随后请求的仅是 `base_conclusion`，与旧记录一致；该旧请求只有失败元数据、没有 provider 响应，所以回放以失败 fixture 终止，不能当作第二次模型回答。新 DeepSeek 请求为 0。

当前 Lean 4.34.0 串行执行 4 个 Lean 进程、峰值并发 1；工作流总计 52.641 秒，其中 Lean 52.275 秒。Statement Lock 保持。第一份 Flash patch 后 12 个可检查 obligations 全部未通过 Kernel：`base_conclusion` 无 proof；`step_conclusion` 的 `rw` 未找到原 proof 指定的归纳步求和目标；其余十个 claim 的现存 proof term 首诊断均为 ``dsimp made no progress``。workflow 的真实剩余 proof obligation 只有 `base_conclusion`。`final_conclusion` 是 compiler 通过 `Nat.le_induction` 结构组合 base 与 step 的目标节点，本来不应携带单独的原稿 proofTerm；它已单独记为结构合成目标，未再误算成缺失 obligation。

这组诊断将当前首要失败定位到 proof-only patch 对各步骤精确 obligation/context 的覆盖不足：Flash 的 `step_conclusion` term 尝试直接 rewrite `ih`，但当前 obligation 的局部前提是显式来源步骤依赖；Lean 报告的目标与所请求 rewrite pattern 不相符。此 replay 没有证据表明换成语义步骤中间层会修复这些已生成 proof term。语义层对 C04 片段的既有确定性测试只证明 lower 后 AST / statement hash 与 Typed MathIR 相同，不是新的 Kernel 成功证据。完整逐节点 diagnostics、proof wires、请求记录和资源数据见 [corrected C04 workflow replay](mathir-v2-C04-partial-generation-workflow-rerun-20261011-corrected.json)；能力矩阵已用该文件替换 C04 的最新 workflow 结果。

随后我为 proof-only prompt 增加了通用 binder/context 解释，并对相同保存 MathIR 发起一轮真实工作流以验证新提示。实际 `LibraryPlan` 与 `FormalProofs` 两次请求均 retry 0/cache miss，但都在收到模型响应前返回 HTTP 402 `Insufficient Balance`；token usage 未返回，没有生成 patch。因此这次不能验证新提示是否改善 proof term。工作流仍运行本地 Lean 核验；固定命题与路线均未通过。请求与失败元数据见 [C04 context-bound live attempt](mathir-v2-C04-context-bound-proof-loop-20261011.json)。

使用已保存 C12 MathIR/proof wire 批量执行 Lean/Kernel 检查：3 个带 proofTerm 的步骤通过单个 `check_many`，全程 3 个 Lean 阶段、40.255 秒、最多并发 1，Provider/DeepSeek 0 次。每项 wire 已按 SHA-256 gzip 外置；Statement Lock/hash 保持，量词顺序不变。n3、n4 通过真实 Lean/Kernel；n2 和 n6 没有原 proofTerm。n5 的 proofTerm 可在 Kernel 下证明其局部 expected type，但审计发现它完全没有使用已声明的 n2、n3、n4（`declared_dependency_unused`），因此只保留局部证书，原路线仍 incomplete。固定命题仍未通过，且独立反例证据表明 `∃ M, ∀ x, x<M` 为假。完整阶段资源、每步证书和 proof-wire 引用见 [C12 scoped dependency replay](mathir-v2-C12-scoped-dependency-replay-20261011.json)；矩阵构建脚本现将其作为 C12 最新证据源。

此前验证阶段：Lean-local 集合 `tests/v2/test_v2_kernel.py -m lean_local -q` 为 8 passed、3 deselected，真实 Lean/Kernel 串行耗时 633.22 秒；非 Lean-local 的 MathIR、workflow、runner 和 Kernel 测试为 70 passed、9 deselected。宏 nonce 归属的真实 Lean 测试包含在 Lean-local 集合中。恢复研究重放批处理后，C01/C12 saved-proof replay 的节点检查合批，实际减少 Lean 子进程且保持 Kernel/依赖结果一致。`lake build Jijian` 通过，`git diff --check` 通过。该阶段没有新的 DeepSeek 请求。本轮发现 C01 递归依赖类型过度嵌套并修复；C01 当前编译器完整路线回放和 C12 量词/依赖反例回放均成功。

此前续跑当时对 C06 的新请求返回 HTTP 402（534.617 ms，retry 0，token 未返回），所以当时未请求 C09。余额恢复后的新增结果已在本报告末尾单独记录；此前这段是历史运行结果，仍保留原请求证据 [C06 live attempt](mathir-v2-system-live-C06-20261011.json)。

### C04/C07 锁定 statement 作用域等价复核

对保存的 C04、C07 MathIR，比较编译器锁定 statement 与直接渲染 `goal.expression` 后的命题。前者包含保存的求和 `let` 定义以及与目标中重复使用的量词 binder；后者保留原目标里的量词、条件和求和表达式。隔离 Lean/Kernel 检查证明两者逻辑等价：C04、C07 均 `verified`、证书 `checked=true` 且 `statementMatched=true`。Provider 请求数为 0。每题各运行 expected-type elaboration、proof export、独立 Kernel replay 三个串行 Lean 阶段，耗时约 40.7/40.9 秒；Mac 进程峰值 footprint 约 0.93 GiB、Python 峰值约 42 MiB。完整输入命题、等价证明、statement hash、Kernel 证书及逐阶段资源记录以内容寻址 gzip 保存，引用见 [scope equivalence evidence](mathir-v2-scope-statement-equivalence.json)，可由 [audit script](../scripts/audit_mathir_v2_scope_statement_equivalence.py) 重建。

这排除了“锁定定理已被编译成另一个命题”这一解释，但没有证明归纳路线，也没有证明冗余绑定对 proof-only 提示无影响。该审计中的证明是人工写的命题等价桥接，只用于核对编译语义；未进入 C04/C07 route proof、Kernel route 状态或成功计数。编译器和 Statement Lock 均未修改。

### Proof-only 部分响应的工作流闭环

复核 C04 保存证据发现一项可确定修复的工作流缺陷：首个真实 Flash proof-only 响应对 12 个待证节点只返回 11 个 patch，遗漏 `base_conclusion`；旧 workflow 只调用一次 proof generation，之后 repair 阶段只接受本次已生成的 proofTerm，因此不会再为仍缺失的节点构造 proof-only 请求。C04 后续曾单独为该节点发起一次新请求，但该请求在返回响应前失败；这是失败前的一次真实调用，不是成功重试，也没有 Lean 结果。

现在 workflow 会按当前 MathIR 中的剩余 obligations 逐轮请求 proof-only。每一轮都用当下完整 payload 计算稳定 hash；只要有新 patch，就先重跑整条 Lean/Kernel 路线，再从锁定 MathIR 计算剩余 obligations。Provider 无 patch 时立即停止，防止相同输入重复调用；不设固定轮数，不改 statement、结构锁、来源、依赖图或 Kernel 边界。每轮 `proof_only_generation` event 附带该请求 payload 的 `inputHash` 和真实 Provider provenance。请求失败时返回最新一次 Lean/Kernel verification history。

回归用两个彼此独立的路线和 record-replay Provider 响应验证部分覆盖：第一轮收到两个 obligations 但只返回一个 patch，第二轮真实 proof-only helper 的 payload 只含剩余一个 obligation；各批次后 workflow 都执行 full verification，最终两条测试路线通过。另测空 patch 响应只调用一次并保留 incomplete 结果。定向 workflow 测试 11 passed；完整 `tests/v2` 为 68 passed、640.88 秒。该次全套为本地 stub/Lean 检查，DeepSeek 新请求 0；没有把测试 fixture 计作模型成功。`python3` 系统环境收集全部 v2 测试时缺少 `jsonschema`，完整测试由项目 `.venv` 执行。本次没有重新跑 C04 的真实模型请求，既有 C04 真实响应证据保持原状。

另以 record-replay Provider 验证“首轮已返回并通过一部分证明、下一轮 Provider 失败”：第二轮请求只含剩余 obligation；workflow 返回失败状态时保留第一轮 proof patch、第一轮之后的完整 verification、两次调用的事件记录与失败原因，不回滚已验证证据。该定向 workflow 回归 1 passed，未发网络请求。

继续检查自动 Repair 的失败类型时又确认：`statement_not_elaborated` 是 expectedType/声明层的 Lean 失败，proof-only 契约不能修改其命题、binder 或 MathIR；旧 payload 会将该状态错误地送入 proofTerm Repair。现改为把它单列在 `nonRepairable` 中，保留 route/node、expected type、来源和 Lean diagnostics；workflow 在没有其他可修 proof 时以 `proof_statement_not_elaborated` 终止。若同一路线还有 proofTerm 本身的 Lean 失败，仍正常构造并执行那些 Repair。MathIR + workflow 定向回归共 57 passed（14.76 秒），不含 DeepSeek 请求。该项是可由 Lean 状态和 proof-only 写权限直接判定的确定性工程修复；未尝试改写 MathIR 来规避失败。

Provider patch 权限审计进一步发现 Repair 的实际可写集合曾宽于 prompt 中的诊断目标：响应应用层拿到的是本 workflow 中所有已生成 proofTerm，因此如果模型意外返回另一个已通过节点的 nodeId，Statement Lock 虽仍能阻止结构变化，却不会阻止这个未被当前诊断授权的 proofTerm 被覆盖。现在生成 patch 只接受当前缺失 obligations 的 nodeId；Repair patch 只接受当前 diagnostics repair 列出的 nodeId，并将应用层 `generated_terms` 收窄为该集合。重复 nodeId 或集合外 nodeId 返回 `AI_PROOF_PATCH_INVALID`，不会应用任何 patch。测试以同路线一个失败节点和一个已 Kernel 通过节点构造越权响应，确认拒绝了对已通过节点的修改；另确认 generation 不能改写已填 proofTerm。`tests/v2/test_mathir_v2.py tests/v2/test_workflow.py` 为 58 passed（14.25 秒），provider contract 2 passed，越权边界新增定向测试 2 passed；均无 DeepSeek 请求。

### C03 保存 MathIR 的真实 proof-only / Lean / Kernel 工作流

余额恢复后，对已保存的 C03 MathIR 运行当前完整 proof workflow；没有重新识别原文或生成 MathIR。原文哈希与保存题目匹配，6 个步骤的来源引用均有效，Statement Lock 保持，锁定 statement hash 为 `89fc5ed4400e4280bd9dad945e46acbc3596353994489355c242e96d14e8f25a`。Mathlib Retriever 两次提供可用候选上下文（每次报告 17 个 checked declarations、0 个 source candidate matches），DeepSeek Flash 共 4 次真实请求：`LibraryPlan` 两次、`FormalProofs` proof generation 一次、`FormalProofs` diagnostic repair 一次。四次均 retry 0、cache miss；token 合计输入 219,452、输出 22,119，HTTP 合计 91.719 秒。逐请求 id、workflow id、input hash、prompt version、usage 与 HTTP 时间见 [C03 full live workflow](mathir-v2-C03-full-workflow-live-20261011.json)。

初次生成后，Lean 首个失败为 n1 类型类无法从未定类型推断乘法；n4/n5 局部 proof term 虽能由 Kernel 检查，但没有使用 MathIR 声明的前序依赖。Repair 只收到这轮真实 Lean/dependency diagnostics，并仅修补 n1、n4、n5；没有更换 theorem statement，也没有删除步骤。Fresh Lean 与独立 Kernel 重放后，6/6 source obligations 全部通过，n4→n3、n5→n4 依赖使用审计通过，n6 对其四条声明依赖的使用审计通过；固定命题 Kernel 通过。

完整原路线仍未通过：n2 是单独通过 Kernel 的展开等式，但 `dependsOn=[]`，且不在 n6 的目标依赖闭包内；来源第四步明确由第一步及第三步推出目标，并未引用第二步。故 route connectivity 将 n2 标为 `unconnectedClaimNode`，路线状态为 `incomplete`。这不是数学反例，也不是六个局部 proof 失败；若把 n2 当作可忽略旁算而仍宣称“全部原稿步骤构成的路线通过”，会与严格路线完整性判定冲突，因此本次保留未通过状态，不擅自添加依赖边。该例证明当前工作流能从保存 MathIR 自动走完真实模型生成、诊断定向 Repair、Lean 和 Kernel，但不能把一条含有无关独立步骤的证明冒充完整原路线。

两次有证明内容的 Lean/Kernel 验证分别耗时 54.310 秒与 60.833 秒，合计 Lean 指标时间 115.143 秒，均串行、最大并发 1；最终 Kernel replay 批次输入 JSON 为 121,480,714 bytes。保存的资源记录峰值 Python RSS 2,788.78 MiB，Lean 子进程组 max RSS 6,459.34 MiB（macOS max RSS 含映射页，不等同私有内存）。工作流报告和哈希外置 proof wire 保留逐轮 diagnostics、patch 与证书，可复核路线未通过的唯一最终阻塞是 n2 未连接，而非模型或 Kernel 报错。

### C04 保存 proof 的当前诊断 Repair 续跑尝试

沿用当前 Statement Lock、已保存的 Stage 9 proof/repair terms 与上一轮真实 Flash 的 `base_conclusion`，续跑现有完整 workflow；没有重做 MathIR 或 proof generation。先用真实 Lean 核验当前 12 个来源 obligation，再向 DeepSeek Flash 请求一份 Mathlib `LibraryPlan`（58,631 输入 / 496 输出 token，3.110 秒）和一次真实 `FormalProofs` diagnostic Repair（60,612 输入 / 27,763 输出 token，105.596 秒）；两个 request 均 retry 0、cache miss。Repair 响应已被工作流应用，工作流完成补丁后的 fresh Lean/Kernel verification 后进入下一次诊断循环。

这次研究 harness 把 `ProofLock` 错误地创建在已填入生成 proof terms 的 MathIR 上，令第二轮 `diagnostic_repair_payload` 将此前模型生成的 `base_sum` 错认作不可修改的原始证明，抛出 `ORIGINAL_PROOF_CHANGED`。因此 Provider 响应、Repair patch 逐节点内容、补丁后 verification summary 和本轮 Lean resource metrics 未能序列化；审计仍保存了两条真实请求，7 个在运行时间窗口内更新的 Lean proof evidence 文件也保留，但它们的 step 与 verification 轮次映射不完整。该失败属于本研究续跑器的 lock 初始化顺序错误，不是正式 v2 workflow 的 Lean 或 Kernel 结果。为避免重发同一个 Repair input（hash `603b98101e278d17dc7a7652387c5f2dab134846a590dec9c7355ff1b1005618`）而重复消耗 API，未重跑该请求；完整审计、缺失证据范围和外置文件列表见 [C04 seeded live repair attempt](mathir-v2-C04-seeded-live-repair-20261011.json)。续跑器现已修正为先从未打补丁的 MathIR 创建 lock，并在研究异常时序列化审计与当前 Lean metrics；此修正尚未用另一条 live C04 请求验证。

## 本轮新增的真实 C01 闭环与 statement 编译修复

余额恢复后，复用 Stage 8 保存的 C01 MathIR 和既有真实 Lean diagnostics，没有重新识别或重建 MathIR。第一次启动因为脚本默认读项目空 `.env` 而在 Provider 调用前退出；随后将 `JJ_ENV_FILE` 指向用户已配置的 `~/Library/Application Support/JijianLean/server.env` 并重跑。有效 workflow 为 `af0044bd-04e6-46e3-8701-7f30bf585369`，仅有 1 次真实 `repair / FormalProofs` 请求：模型 `deepseek-flash`，request id `79020c8b-a686-4cc8-b83b-9ca0f40f638d`，input hash `d279394050557521139bccd5c362e217e857d2cd6392c5174fb1b8f0843cdcee`，prompt version `sha256:b38aaa7f4ce5b5296481cfd0cf62048d1060db9e5d9ab4bb8feeac5abfa64099`，retry 0、cache miss、输入 8,683 token、输出 12,097 token、HTTP 46.789 秒。返回两个针对真实 dependency-use diagnostics 的 patch：`n_step4_intermediate` 与 `n_final`。MathIR hash 与锁定 statement hash `1216b1936d2b0cca9a83d6db3f1ede89133afb8162a06e2be1a7e06eacea3a3c` 保持。最终 9/9 源步骤各有 statement-matched Kernel 证书；固定命题与完整原路线均通过。最终检查使用 3 个串行 Lean 阶段、Lean wall time 57.914 秒；总 Repair 46.855 秒、最终 verification 103.286 秒；Python peak RSS 1,840.88 MiB、Lean child-group max RSS 6,347.47 MiB。完整 request audit、每步结果、证书与资源见 [C01 restored-balance live repair](mathir-v2-C01-restored-balance-loop-20261011.json)。研究脚本的 audit 输出现按 active `workflow_id` 过滤，避免把同一数据目录下旧 workflow 事件混进本次请求计数。

本轮 Lean-local 回归 `tests/v2/test_v2_kernel.py -m lean_local` 为 8 passed、3 deselected、637.05 秒；最新非 Lean-local v2 回归为 64 passed、9 deselected。另修复 `V2Compiler.theorem_statement()` 将未被 goal / theorem assumptions / variable constraints 使用的根定义也闭合进定理，进而重复绑定该定义内部变量的问题：现在只闭合目标相关定义的传递闭包，未使用的定义不会改变锁定 statement。新增回归断言确认加入无关 root definition 不改变 theorem statement/hash，也不产生重复 binder；已有目标引用根定义的测试仍保留。对保存 C04 结构做了不访问 Provider / Lean 的当前编译核对：`v_d_m`、`v_d_n` 各只绑定一次，未使用的 `S_n` 没有进入 theorem，当前编译 statement hash 为 `d5ab0ed34270ff7b786eebff91c8a41d3baadec67ce65e905a286d711c31877f`。该确定性修复不改变 Kernel 边界、Typed MathIR 或输入结构；C04 既有 proof replay 发生在此改动前，不能用其 statement hash `575ccfcc…` 冒充修复后的 C04 route 结果。

随后补上约束闭包检查：若 theorem variable 的 domain constraint 引用根定义，该定义仍被纳入锁定语句。定向编译回归 3 passed、46 deselected；脚本 `py_compile` 和 `git diff --check` 均通过，能力矩阵由保存证据重新生成。

C04 当前 statement 与直接渲染的 goal expression 字符串相同；为当前 lock 单独执行了真实 Lean/Kernel `A ↔ A` 的 `rfl` 检查，结果 `verified / checked=true / statementMatched=true`，0 Provider、单 Lean 阶段。第一份旧 binder bridge 失败记录保留在 `mathir-v2-C04-corrected-statement-equivalence-20261011.json`：其 proof 仍按旧重复 binder 的 4 个参数应用，报错 `n ≥ 1` 参数类型不匹配；该失败不表示命题不等价。修正后的成功证书在 [C04 corrected statement equivalence](mathir-v2-C04-corrected-statement-equivalence-kernel-20261011.json)。随后将同一批旧 Flash proof terms 用新的 statement hash 做本地 replay（历史响应仍绑定旧 hash，因此这不是同锁 proof-generation 结果）：固定 theorem 未通过；`base_conclusion` 缺 proof，`step_conclusion` 首个报错为 `rewrite` 没找到归纳步求和式，多个 helper 报 `dsimp made no progress`，只有 `step_sum`、`step_double_chain` 两步通过。Kernel 总结和资源在 [C04 corrected-statement saved-proof replay](mathir-v2-C04-corrected-statement-saved-proof-replay-20261011.json)。这将 C04 的确定性编译缺陷与真实 proof-only 阻塞分开：前者已核实修正，后者仍需要原路线 proof 生成/修复能力。

### 归纳路线依赖组合与 C04 复核

本轮修复了 MathIR v2 归纳 proof compiler 的结构性缺口。base obligation 现在保留原稿直接 dependsOn；step obligation 总是显式接收 induction hypothesis（即使来源图经 helper 才到达它），但 dependency-use 审计仍按原节点真实直接边记录，IH 经 helper 使用时由 helper 自身的 Kernel 证书承担。归纳 proof 组合器把 base、step 和 helper claims 分别声明为 Lean lemma，再沿 source dependsOn DAG 应用到 `Nat.rec` / `Nat.le_induction`；任何缺 proofTerm 或无法对应到 route 假设的情况都会让 composition 保持 incomplete/unsupported。归纳子目标的 root context 与 proof wrapper 现在共用同一 relevance 闭包：只引入实际使用的 root definitions、变量与相关约束，定义被使用时递归保留其自由变量，有限和的 bound index 不会升格成 theorem 参数。

真实本机 Lean/Kernel 回归包含两个归纳案例。原 `2^n·2^n=4^n` induction fixture 通过；新增多步 fixture 用 base support claim 和 `IH → step_helper → step` 路线，step 节点本身只依赖 helper，helper 的证明实际用 IH 经 `pow_succ` 与等式重写完成。两例的固定命题、各来源 claim 与完整原路线均获得 statement-matched Kernel 证书。两个定向 Lean-local 测试分别通过（40.110 秒与 43.376 秒）；多步 fixture 的完整 MathIR、Kernel 证书、依赖使用记录、运行资源见 [induction helper DAG Kernel evidence](mathir-v2-induction-helper-dag-kernel-20261011.json)。全套 v2 非 Lean-local 测试为 71 passed、10 deselected；DeepSeek 请求 0。

随后以保存的 C04 MathIR 和历史真实 Flash proof terms 做当前归纳 DAG 组合回放，无 Provider 请求。锁定 statement hash 为 `d5ab0ed34270ff7b786eebff91c8a41d3baadec67ce65e905a286d711c31877f`，与历史 Flash statement hash `575ccfcc…` 不同；因此这是旧 proof evidence 对当前 statement 的兼容性诊断，不是同锁模型结果。真实 Lean/Kernel 串行运行 3 个阶段、40.886 秒、最大并发 1；12 个 obligation 中 `step_sum` 与 `step_double_chain` 通过，其余 10 个不完整。首次阻塞是 `base_conclusion` 无 proofTerm，组合器如实返回 `incomplete: An induction source claim has no original proof term`；`step_conclusion` 首个 Lean 诊断为 `dsimp made no progress`，多个 base/step helper 也有同一诊断。固定 statement 与完整原路线均未通过 Kernel。完整 proof/status/diagnostic wires 与资源见 [C04 induction DAG composition replay](mathir-v2-C04-induction-dag-composition-replay-20261011.json)。这说明当前架构已能把真实多步归纳依赖组合并通过 Kernel，但 C04 的保存 Flash 项仍不足以给出同锁、忠实的原路线证明。

### C04 当前锁定命题的单次真实 proof-only 调用

余额恢复后，使用保存的 C04 结构和当前 Statement Lock，只向 DeepSeek Flash 请求缺失的 `base_conclusion` proof term；没有重新识别图片、生成 MathIR 或请求其他节点。真实 Provider 调用一次，stage 为 `formalization`、reason 为 `FormalProofs`、retry index 0、开发缓存 miss；审计记录 workflow `e67ca748-0862-4e0a-8807-e92a282de410`、request `b30fb677-4be0-4c5e-9090-adce66d0db8f`，请求 input hash `257afd80d19defdbe0bce8ee7c65bdb7a6e14791d95882af8c4fba7fed243f8b`。DeepSeek 返回 2,519 输入 token、12,690 输出 token（共 15,209；其中 12,605 为 reasoning token），HTTP 用时 50.031 秒。响应只补入指定缺失节点，Statement Lock 保持不变；没有触发第二次模型 repair 请求。

Lean/Kernel 使用同一锁定 hash `d5ab0ed34270ff7b786eebff91c8a41d3baadec67ce65e905a286d711c31877f`，本地核验串行运行 3 个 Lean 阶段、38.465 秒，最大并发 1；Python 峰值约 123.56 MiB，Lean 子进程组峰值 RSS 约 5,805.94 MiB。新增 base proof 在其 obligation 的 Lean elaboration 首先失败：`simp made no progress`；后续报告还显示该节点组合来源步骤时，生成的 `Eq.trans` 依赖链的类型与固定基例等式不一致。此轮 12 个 obligations 只有 `step_sum` 与 `step_double_chain` 单步通过。固定 statement Kernel 和完整原路线 Kernel 均为 false，路线仍 incomplete；这不是数学命题通过，也不是只因一个单步可证就判路线成功。端到端这次 live proof-only + Lean/Kernel 核验约 88.5 秒（两阶段计时相加，不含前置环境准备）。真实请求、逐步诊断、证书状态及资源数据见 [C04 current statement live base proof](mathir-v2-C04-current-statement-live-base-proof-20261011.json)；能力矩阵已将其列作 C04 最新同锁结果，旧响应回放仍作为独立历史证据保留。

### 工作流集成审计修复

端到端契约审计发现：Repair 阶段若 Mathlib Retriever 抛出 `AppError`，异常分支会引用尚未赋值的 `input_hash`，从而以 `UnboundLocalError` 取代真实检索失败，且丢失 repair 输入关联。现在先对不含新 retrieval 的诊断 payload 计算失败事件哈希；检索成功后再按带证据的最终 payload 重算实际 repair 去重哈希。新增回归覆盖“已有本轮生成 proof、Lean 诊断可修复、repair retrieval 失败”路径，断言工作流保留原 proof、返回原始检索错误与非空输入哈希。定向 workflow 测试 3 passed，脚本语法检查与 `git diff --check` 通过；本修复无 Provider、Lean 或 Kernel 请求。

## C06/C09 余额恢复后的结构捕获续跑

本续跑基于 `3804bae` 的研究工作树，只重新请求了两个历史缺结构样本各一次 MathIR；没有重新识别图片，也没有向 proof-only、Mathlib 检索、Repair、Lean 或 Kernel 发送请求。两次均为 DeepSeek Flash、stage=`mathir`、retry 0、cache miss、无图片 hash。合计输入 8,202 token、输出 69,460 token、HTTP 227,205 ms。完整逐请求字段、响应 ID、原始内容哈希与 response gzip 路径在 [C06 report](mathir-v2-C06-live-automatic-workflow-20261011.json)、[C06 offline replay](mathir-v2-C06-structure-replay-20261011.json)、[C09 report](mathir-v2-C09-live-automatic-workflow-20261011.json) 和 [C09 offline replay](mathir-v2-C09-recorded-structure-replay-20261011.json)。原始模型响应在 `reports/mathir-v2-live-structured-responses/{C06,C09}/` 内容寻址保存，后续检查均离线读取。

| 样本 | 真实 Flash 结构请求 | 原文与 MathIR 结果 | 首个阻塞 | Lean / Kernel |
|---|---|---|---|---|
| C06 自然数平方和归纳 | 1 次；4,082 输入 / 31,636 输出 token；104,222 ms | 原文逐字匹配；基础 MathIR 可解析，12 个原稿节点且无输入 proofTerm。缺 `assessmentBasis` 的机器 `supported` 标记保守降为 `not_assessed`；三项 base dependency closure 移到 IH 作用域之外、结论节点移到 root，并根据已有 `stepConditionNodeId` 记录结构边。表达式、原稿步骤、SourceRef 未变。归纳 base/step 校验在展开 `S_n` 定义、识别多项式等价写法后可通过 | 固定 statement hash 为 `a3e3b87b352187c894c7b0c0185530683d399c8e676180b9446dcad4f2d34c71`，但打印结果先以 root `n` 绑定 `S_n := Σ_{k=1}^n k²`，再在目标内部用相同 ID 量化另一个 `n`。后一个 binder shadow 前者，实际锁定的是“外层和的值等于任意内层 n 的公式”，不是原稿定理。source binding preflight 判为 collision | proof-only 未启动；Lean 0；Kernel 0。该 MathIR 不作为成功或失败定理 proof 计数 |
| C09 有理数有限和归纳 | 1 次；4,120 输入 / 37,824 输出 token；122,983 ms | 原始结构 response 被记录，但 provider schema 解析报 `AI_SCHEMA_INVALID`：22 个 `supported` 标记没有 `assessmentBasis`。离线把这些元数据降为 `not_assessed` 后可解析；按原题明确的“自然数索引按 ℚ 解释”把 41 处 Nat→Rat 错误 `ascribe` 转成显式 cast，并把明确引用的 lower-bound node 放入 induction scope | 仍有 10 个 `symbol T` 带一个参数，而 MathIR symbol 是零元；离线 compile 报 `V2_EXPR_ARITY: symbol expects 0 arguments`。此外 root `T` 定义依赖 `n_var`，goal 又重复量化相同 ID，存在与 C06 同类的 binder collision。MathIR v2 没有函数应用表达式，不能忠实表示 `T(n)` | proof-only 未启动；Lean 0；Kernel 0 |

C06 调试同时暴露并修复了 3 项可确定的工程缺陷，均不改 MathIR 表达式、statement lock 算法或 Kernel 可信边界：`ExpressionRenderer` 在 `finite_sum` binder 内调用类型推断时没有传递已绑定 ID；类型检查器曾拒绝本应合法的 `cast.targetType`；归纳 base/step 匹配仅做 JSON 语法相等，未先透明展开声明定义，也未识别自然数加乘多项式的等价写法。新增回归覆盖有限和中的局部 binder、Nat→Rat 显式 cast、定义展开的归纳 base/step，以及 `2*(n+1)+1 = 2*n+3` 的归纳算术比较。4 个定向测试通过。

C06/C09 结构 scope 修复和 assessment 降级只是研究脚本里的保守离线预检；它们没有静默改写原数学内容，也没有提交任何 proof。C09 的 cast 改写有原题的显式数域说明；它解决不了 `T(n)` 的表达能力或 binder 身份问题。根变量约束、显式 forall、依赖该变量的根定义应该如何在 MathIR v2 表示，及是否添加参数化定义/函数应用 AST，是需单独确认的契约设计，不能由本轮推测后写入正式产品逻辑。

分层翻译对照仍基于 C04/C05/C08/C10/C12 五个保存片段：轻语义表示经确定性绑定和类型约束后与原 Typed MathIR AST 逐项相等，statement hash 和路线编译状态相同，模型调用 0、Lean 调用 0。它验证了 lowering 的保真性，但不是同条件真实模型 A/B，也没有显示 proof-only/Kernel 能力提升。结合本轮 C09 的参数化 `T(n)` 未被当前 AST 表示、C06 的 binder 碰撞，建议暂保留轻量 parser 为隔离研究工具；不要据此替换正式 Typed MathIR。下一轮若继续，应先在研究 schema 中明确定义参数化定义、绑定变量与 theorem quantifier 的身份规则，再用保存响应和未参与设计的新样本比较 lowering 与原路线 Kernel，完成前不接正式 App。

本续跑中执行的验证：4 项新增/受影响单元测试通过；`py_compile`、矩阵重建及 `git diff --check` 通过。一次较宽的 `tests/v2/test_v2_kernel.py` 运行在 386.28 秒后有 9 项通过，但阻塞于耗时 Lean 集成用例，随后由我中断，因此不能记为全文件通过。此次 C06/C09 没有真实 Lean 或 Kernel 运行；C01/C08 等先前路线的实际 Lean/Kernel 结果仍按矩阵中的原报告单独引用。

## C13 保存 proof 的自动诊断修复闭环（2026-10-11）

本次从 Stage 7 压缩归档中提取同一份 MathIR，没有重新调用 MathIR 生成，也没有改动 statement、步骤语义或来源位置。MathIR 解压后的 SHA-256 为 `4beafd836a697ad7f837d5055958ca1124065f399cd89f613055ebf54573e2fe`；Statement Lock hash 仍为 `e658f25b89fda9793accabe0571eb9456bb9b111a520d4972a773580584da84c`。旧 Flash proof term 仅作为先前真实生成的候选输入，并在报告中标记其历史来源；本轮启动 repair 时锁定 statement/结构，但不把候选 proof 冻结进原始锁。

DeepSeek Flash 实际发送 4 次串行诊断 repair 请求，全部 retry 0、cache miss，stage=`repair`，reason=`FormalProofs`，未调用识别、MathIR、Mathlib Retriever 或反馈阶段。token 分别为 5,091/5,024、3,561/5,558、3,507/6,052、3,565/3,070（输入/输出）；总计 15,724 输入、19,704 输出 token，HTTP 合计 76.636 秒。四个请求的 input hash 均不同，说明本轮不是同一 repair 输入被重复重放。完整 request ID、input hash、耗时和 Lean 逐轮结果保存在 [C13 自动 live workflow](mathir-v2-C13-automatic-live-workflow-20261011.json)。

Lean 在每次有 proof term 变化后重新验证，串行执行 4 轮、每轮 3 个 Lean 阶段，共 176.025 秒 Lean 时间；整个工作流 288.318 秒。Python 峰值约 551.64 MiB，Lean 子进程组峰值 RSS 约 5,874.22 MiB。Flash 共提交 4 个发生变化的 proof patches（首轮两个，后两轮各一个），第四个响应对 `n_step4_conclude` 返回与现有 proof hash 相同的内容；系统据此以 `repair_did_not_change_proof_terms` 停止，没有再运行一轮 Lean，也没有再发相同 repair。

最终 4/4 个 claim obligations 都各自通过 Lean Kernel 证书，statement lock 保持；但这不等于原路线通过。目标节点 `n_step4_conclude` 仍声明依赖 `n_step3_expand`，Kernel proof-expression 使用审计确认此依赖未被使用；`n_step3_ineq` 的两个声明依赖均确实使用。更关键的是，路线组合器拒绝把 `n_step1_assume` 作为本地可接受的 theorem 前提，因为锁定定理没有声明该显式假设。路线图的节点连通不弥补这个循环假设。因此 `fixedStatementKernelPassed=false`、`originalRouteKernelPassed=false`、route=`incomplete`，proof composition=`unsupported`。该结果准确表达“局部结论有独立证书，原证明路线未闭合”；没有用可独立证明的目标或局部成功步骤替代原路线证明。

这次还暴露研究 runner 的锁定时序缺陷：续跑的模型 proof term 在初始化时被误并入锁定输入，第一次离线验证以 `ORIGINAL_PROOF_CHANGED` 结束，尚未发出任何 Provider 请求。修正后，runner 从同 statement/structure 的 proof-empty 快照建立锁，再把历史 proof 作为可修订候选传入工作流；确认锁定 hash 未变后才执行本次 4 次真实调用。现在可用 `scripts/run_saved_mathir_v2_live_workflow.py` 从已保存 MathIR 重现该路径，原始 MathIR、proof wire 与 report 均以内容寻址证据保留。

## C01 余额恢复后的单次自动修复闭环

账户余额恢复后，沿用已保存且 statement hash 未变的 C01 MathIR 与九个已有真实 Flash proof terms；没有再次生成 MathIR 或重新请求原先已有的局部证明。首次当前 Lean/Kernel 复核确认固定 theorem Kernel 已通过，但原路线因 `n_step4_intermediate` 和 `n_final` 没有实际使用声明依赖而 incomplete。工作流据这两条真实依赖诊断，向 DeepSeek Flash 发出一次 `stage=repair`、`reason=FormalProofs` 请求，retry 0、开发缓存 miss；input hash=`d279394050557521139bccd5c362e217e857d2cd6392c5174fb1b8f0843cdcee`，输入/输出 8,683/12,097 token，HTTP 46.789 秒。响应只替换这两个节点的 proof term，锁定 statement hash `1216b1936d2b0cca9a83d6db3f1ede89133afb8162a06e2be1a7e06eacea3a3c` 保持不变。

最终真实 Lean 和独立 Kernel 重放均确认固定命题与完整原路线通过，所有声明依赖使用审计完整、路线组合成功。单次 repair 计时 46.855 秒，最终验证计时 103.286 秒；Python 峰值约 1,840.88 MiB，Lean 子进程组峰值 RSS 约 6,347.47 MiB。没有第二个模型请求，也没有从 repair 返回内容之外生成新 theorem。报告明确将九个 proof 标作复用、两个标作本轮真实修复；逐步 proof wire 与 Kernel 证书记录在 [C01 余额恢复闭环](mathir-v2-C01-restored-balance-loop-20261011.json)。这项结果更新了先前 C01 余额不足而未进入 Lean 的尝试，但不抹除该次失败请求证据。

## C07 当前编译器下的归纳原路线 Kernel 闭环

复用同一份已保存 C07 MathIR、两轮真实 DeepSeek Flash diagnostic repair 得到的 proof terms、原 Mathlib retrieval 与来源映射；本次没有重识别、重生成 MathIR、重跑 Mathlib 检索或请求 DeepSeek。Statement Lock hash `b3491954ddef69160c2febbba008416ad2bce88e1772a27e360d7becc837e6f1` 保持不变。

首轮 8 个局部 proof obligation 已能分别通过 Lean/Kernel，但组合定理失败。Lean 诊断是归纳组合器把 theorem-level `n`/全局正性假设与同一 `SymbolId` 表示的显式归纳目标混为一组：helper claim 被错误地以 induction index 配外层 theorem assumption；base claim 也收到未绑定的 induction index。现有 locked statement 及 MathIR 均未修改。编译器现以不同 Lean binder 名区分外层 theorem 参数与归纳目标；base 保留外层上下文，step claim 保留外层上下文后再接结构归纳参数；归纳 helper 按 induction index 实例化，并在正好对应下界条件时使用 recursor 提供的下界证据。依赖应用缓存也按根参数映射和条件证据区分，避免跨上下文复用错误实例。没有删去任何原稿节点或依赖边。

新增的 shadowed-binder 回归覆盖引入顺序、base 参数和 helper 下界参数；与已有归纳组合测试共 3 项定向测试通过。随后将全部 8 个保存的真实 Flash source-claim proof terms 及编译后的 induction composition 串行交给本机 Lean 4.34.0 与独立 Kernel：8/8 局部 obligations 通过，固定 statement Kernel 通过，route connectivity=`connected`，dependency-use audit=`checked`，完整原路线 Kernel 通过。Statement Lock/hash 保持；Provider/DeepSeek 请求 0 次。总耗时 78.881 秒，其中 3 个串行 Lean 阶段合计 51.315 秒；Python 峰值 RSS 1,324.34 MiB，Lean 子进程组峰值 RSS 6,148.59 MiB，Kernel batch 输入 67,689,463 bytes。具体 proof hashes、各步证书、diagnostics、进程指标与最终复合 Kernel certificate 见 [C07 current compiler Kernel replay](mathir-v2-C07-current-compiler-kernel-replay-20261011.json)。此处的成功来自修正确定性 proof composition，未对数学 statement 或原路线作放宽。
