# 极简 Lean · MathIR v2 第四阶段研究报告

本报告以第三阶段基线 `841e412` 为起点，只修改隔离的 MathIR v2 研究旁路。未接入或改动正式 v1 App、Mathlib A、DeepSeek Provider、Repair 工作流、Kernel 可信边界。没有新的 Repair 请求，也没有把任何失败样本自动改写成成功。

## 结果概览

五个预先指定样本各发送 **1 次真实 DeepSeek Flash 请求**，共 5 次；缓存均未命中，retry index 均为 0。输入 token 共 **20,814**，输出 token 共 **63,740**（合计 84,554）。五个请求耗时合计约 **609.829 秒**；逐请求模型、usage、响应 ID 和首次失败位置在提交的 [真实 AI 机器矩阵](mathir-v2-stage4-ai-matrix.json)。真实输出都保留 raw/normalized source，五份记录均标记二者与输入文本一致；这只说明文本字段没有被替换，不构成模型 MathIR 语义忠实的证明。模型输出的 `sourceAssessment` 同样不是独立证据。

本地确定性回放未访问 Provider，Lean 检查耗时合计约 **419.141 秒**。完整回放含实际 Kernel Audit proof/type wire data 的压缩包在 [Kernel 回放与证书数据](mathir-v2-stage4-kernel-replay.json.gz)，精简的可读证书索引在 [Kernel 证书摘要](mathir-v2-stage4-kernel-certificates.json)。压缩包移除了本机绝对文件路径，保留 theorem/proof 表达式数据、Kernel 返回证书、依赖使用结果与失败诊断。真实 Provider 原始响应的未压缩记录仍保留在本机 `reports/mathir-v2-stage4-live-matrix.json`，没有把大型原始模型输出加入提交。

| 样本 | Flash 输出及来源对应 | 固定命题 Kernel（保存响应回放） | 原路线 Kernel | 当前结论 |
|---|---|---:|---:|---|
| 正确等式：`a=b ⟹ a+1=b+1` | MathIR 保留原文结论，步骤 `n_concl` 指向前提步骤 `n_ab`，原 proof `by exact congrArg (fun x : ℝ => x + 1) h_ab` | 通过 | **通过** | 唯一形成固定命题与原路线完整通过的真实 Flash 样本；dependency binder 有 Kernel 表达式使用证据。 |
| 错误等式：`a=b ⟹ a+1=b+2` | 输出把来源评为 contradicted，但目标仍忠实表达错误结论；`n_conclusion` 没有 proofTerm | 未通过 | 未通过 | 识别出了错误结论的语义风险，但没有 Lean 反证；这是“缺证明”，不能报告成 Kernel 证明了命题为假。 |
| 从 1 开始归纳：`n≥1 → n+0=n` | 量化变量 `n` 与归纳步变量 `k` 已区分，base/条件/IH/step 显式存在；base 为 `by rfl`，step proofTerm 缺失 | 未通过 | 未通过 | 结构可解析，归纳步无法验证；失败首先来自模型未提供归纳步证明。未把 IH 提升为外部 theorem assumption。 |
| 有理数有限和：`∑ k∈[1,2], (1/2)^k=3/4` | 保留 `Rat` literals、有限和边界、求值范围及独立计算片段 `by norm_num`；目标步骤没有 proofTerm | 未通过 | 未通过 | 确定性编译器现能保持 ℚ 数域；calc/计算片段单独通过 Lean，但目标证明不完整，不能视为本题通过。 |
| 相依多项式定义 `P=X²+1, Q=P+1, Q(0)=2` | 输出显式 `Polynomial.C`，两个定义步骤及目标步骤都有 proofTerm；原目标 proof 是 `by rw [r_q_def, r_p_def]; norm_num` | 通过 | **不通过** | 固定 theorem 有真实 Kernel 证书，三步分别 Lean/Kernel 通过；但独立 proof-expression audit 显示两个 dependency binder 实际未被证明项使用，路线保持 incomplete。Lean 还报告 unused-variable 警告。 |

与第三阶段首轮结果相比，本轮离线回放使用相同保存下来的五份 Flash 输出，验证了确定性修复的影响：正确等式从 symbol-ID/上下文失败改善为完整路线通过；归纳从字段不匹配问题改善为结构可编译，但仍缺 step proof；有限和从未显式锁定的自然数除法改善为显式 ℚ statement 和局部计算证书，但目标 proof 仍缺失；多项式从缺少常数嵌入与编译失败改善为 statement/steps 均有 Kernel 证书，路线审计仍拒绝把未实际使用的依赖当作完整推导。错误等式仍没有目标证明。这个对照只隔离了 compiler/type/schema 的确定性变化；不是新一轮同条件模型 A/B，也不能推出一般成功率。第三阶段细节见 [第三阶段报告](MathIR-v2-stage3-original-route-and-live-study.md)。

## 原路线判定与实现

固定 theorem 的 Kernel 证书与用户原证明路线完整成立是两个结果。固定 theorem 可以独立证明，而原路线可以缺边、包含无关 claim、缺步骤证明、依赖关系错误，或声明了却未使用前置步骤。当前 v2 分别输出 `fixedStatementKernelPassed` 和 `anyRouteKernelPassed` / `completeOriginalRouteKernelPassed`。路线通过还要求目标存在、节点与目标依赖闭包可连接、所有必要步骤通过，以及显式 claim dependency 在数据式 Kernel replay 得到的 proof expression 中被实际使用。独立 claim 与各自 Lean/Kernel 结果继续保留；不会为通过而删除它们。

一般 claim dependency 被编码为 `∀ (jjdep_<id> : premise), conclusion`。编译器把来源 proofTerm 中对显式依赖 ID 的完整 Lean 标识符引用确定性映射到该 binder，保留原始 `originalProofTerm` 供复核。这样避免通过 Lean `let` 别名后被 zeta reduction 消去依赖使用证据。未使用依赖仍拒绝完整路线；多项式记录展示了这种拒绝的必要性：fixed theorem 虽通过，Lean 证明表达式中的依赖不需要，所以不能报告“原步骤推出了结论”。

第三阶段定义的独立反例矩阵仍适用并保留：两个互不关联的 `2=2`/`1=1` 各自 `rfl` 时，固定 `1=1` 通过但路线不完整；错误依赖关系不能凭 Kernel 分别证明两个节点就通过；正确显式依赖链可完整通过；两条路线一错一对时保留各自结果，只有完整正确路线支撑 any-route 通过。第三阶段实测报告记录了这些本机 Lean/Kernel 检查。

## 本阶段确定性工程修复

- MathIR v2 增加显式 `ascribe` 和 `poly_const` 节点，schema、typechecker、Lean renderer 同步。数域注记不能挂在任意表达式上被忽略；只有显式 ascription 生效，类型不匹配时报错。多项式常数明确编译为 `Polynomial.C`，不把 Real/Rat literal 静默提升为多项式。
- 符号解析先使用稳定 declaration ID；旧响应使用唯一精确显示名时，确定性映射回 ID 并记录 `symbolResolutions`；重复显示名拒绝猜测。身份对应现在可解释，但模型仍应输出稳定 ID。
- 归纳 case 增加可选 `stepVariableId`，将被证明的全称变量与归纳步局部变量分开。下界归纳构造中，IH/条件/step 都留在局部步进上下文；不改变被锁定的 theorem statement。
- 有理数 literal 的 Lean rendering 保留 ℚ 语义；多项式系数 embedding 明确表达。Mathlib 对照中已编译现有的有限和/多项式样例及新增节点。
- dependency proof mapping 现在保留 Kernel proof expression 中 binder 的直接使用，并在输出中同时保留原始与编译 proof term。

以上均属于 v2 sidecar。MathIR v2 schema 从实际 Pydantic 契约导出；v1 契约和生产 App 未修改。

## 剩余失败证据与契约选择

1. **错误证明语义**：错误等式输出没有 theorem proof。只有 Lean 针对完整目标运行并拒绝后，才能称为 Kernel 未验证；`sourceAssessment=contradicted` 是模型判断，不能替代反证。若将来要把“模型判断原文不支持目标”用于 UI，需产品契约定义它是识别提示还是数学结论。
2. **归纳步骤结构与证明**：`stepVariableId=k`、`variableId=n` 的类型作用域已表达，proofTerm 仍缺失。不能自动合成归纳步骤或把 n/k 合并。MathIR 的 step case 是否必须带完整 `P(k) → P(k+1)` 证明，或允许一个局部证明块，需由契约明定；本轮采取不改变语义的已有表达。
3. **有限和的原步骤**：MathIR 以 ℚ 锁定 statement，局部 `1/2+1/4=3/4` 计算过 Kernel，但目标 claim 缺 proofTerm。是否允许显式引用前一行计算结论、如何编码 `calc` 的行间等式和 coercion，仍需明确表示；不能把孤立片段拼成用户原路线。
4. **多项式路线依赖**：模型 proofTerm 声称使用 `r_q_def`/`r_p_def`，但编译后的 Lean proof 实际不依赖两个 binder，Kernel audit 给出 `used=false`/空依赖使用且 Lean 有 unused-variable 警告。即使重写成强行引用来抬高路线状态，也会掩盖“步骤是否为原推导必要依据”的语义，故当前不这样做。需要契约决定：多项式定义是否是背景定义、独立声明，还是应作为 proof-route claim 被目标实际引用。
5. **非证明内容及多路线**：当前一个 route DAG 里的每个 claim 都被视为证明路线组成部分。用户原稿可能有旁注、尝试、替代解法或无关等式；不能推测并删除。需考虑显式 node role（claim / annotation / discarded attempt）和多个 named route 的来源映射，但语义和 UI 呈现规则属于契约决策，本轮没有新增/推断这些角色。
6. **来源忠实性上界**：`sourceRefs` 精度仍为步骤/区间映射，模型自评与原文字符串相同并不能验证公式 OCR/数学语义一致。五个文本样本无图像识别；视觉/手写能力不在本阶段实测范围。

## v1 对照与接入建议

v1 历史记录与 v2 这五条研究输入存在相近证明类别，但没有一份五题完全相同的 v1 输入/MathIR/statement/proof/Lean diagnostics 配对。因此只做历史类比，不报告百分比或等条件胜率。逐题历史索引见 [第三阶段机器记录](mathir-v2-stage3-live-matrix.json) 与第三阶段报告；Stage 2 的人工 MathIR 成功也不等于真实 Flash 产物成功。

建议继续隔离 v2。正确等式说明带来源依赖、显式 theorem assumption 的简单路线可完整闭环；其余四题在不同层面暴露“缺原证明、结构不完整、依赖未实际使用”，固定 statement 通过不能代替路线忠实性。生产接入前需契约决定来源节点类型、多路线、definitions 与 proof claims 的区别，以及归纳/有限和局部证明形式。到那之前可以将 v2 作为 shadow/research 结果与原文并列审阅，不能用它覆盖正式 v1 验证结果或显示“原证明已通过”。

## 验证范围

- 真实 AI：仅五次显式 DeepSeek Flash 请求；没有额外 live repair 或 retry。具体 token、耗时、provider response IDs 在机器记录内。
- 当前保存响应的离线 Lean/Kernel 回放：五题都执行；正确等式固定 theorem 和原路线通过；错误等式、归纳、有限和未完成；多项式 fixed theorem 与每一步通过但完整路线因 dependency-use 证据拒绝。
- 本地快速测试：`.venv/bin/python -m pytest tests/v2 -m 'not lean_local' -q` 为 **27 passed, 3 deselected**；Python `compileall` 通过。
- 本机 Mathlib compile/kernel route matrix：第三阶段已实际运行；本阶段 replay 再验证五条已保存 Flash 输出。没有把 fixture 当成 Provider 结果。
- 未运行全量 pytest、未构建或重装 macOS App；生产 v1 App 与代码未修改。
