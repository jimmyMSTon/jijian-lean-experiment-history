# DeepSeek Flash 三题 Lean 转化能力报告

日期：2026-10-07。仅执行用户给定的三道干净文本证明，无图片、OCR、UI或其他live专项。真实Provider为项目配置 `deepseek-flash`，thinking为provider_default；本次不使用任何live环境开关。三题原文仍保存在 ../flash-three-text/inputs.json，未替用户修改数学证明。

## 实际结果

| 题目 | 新增真实请求 | MathIR录制回放 | 初次完整Kernel | 一次proof修复后 | 最终Kernel |
| --- | ---: | ---: | --- | --- | --- |
| 实数平方不等式 | 2：formalization2 | 1 | 通过（带额外前提） | 未修复，首轮已通过 | true |
| 奇数求和归纳法 | 3：formalization2、repair1 | 1 | 不通过：missing_proof | 通过 | true |
| cos(3θ)的多项式 | 3：formalization2、repair1 | 1 | 不通过：missing_proof及依赖未成立 | 不通过 | false |

三题合计8次新真实请求：recognition0、mathir0、formalization6、repair2、feedback0、other0；另有3次完全匹配MathIR的已有真实响应回放，不冒充新AI调用。每题形式化拆为statement/type和proof两次。传输retry0、图片请求0。既有MathIR也是原三题实际DeepSeek输出，本次重新验证了其下游，并重新调用形式化与必要的单次修复。MathIR回放使本次不是三条“每个AI阶段都新调用”的全新链；所有本机Lean与Kernel结果为本次真实执行。

本次三题新请求token：代数 input18630/output8704；归纳 input36167/output33011；三角 input55063/output44017。输出包含供应商计入completion usage的reasoning token，不把它们再重复相加，也不记录私有reasoning正文。

Mathlib检索使用人类指定的候选名、当前本机真实源搜索与批量Lean #check；发送真实declaration/type，没有模拟签名。此次为了限定请求范围没有调用AI检索规划器，因此不是自动检索规划能力的评测。三题没有模拟Provider；缓存与并发机制的单元测试使用stub，不能混入真实AI/Kernel成功统计。

## 1. 实数平方不等式

原题 `(x+y)^2 ≤ 2*(x^2+y^2)`；保留原稿的展开等式、平方非负、差非负、推出不等式步骤。实际使用ring、原步骤引用与sub_nonneg。Kernel首次通过全部4个步骤及aggregate，additionalAxioms为空，未使用sorry、新公理或native_decide。无首轮Lean错误，无repair。

MathIR部分忠实：等式链及结论保留，但“任意实数平方非负”被提升为root assumption，而不是引用Mathlib的已知事实。变量实数域也被重复编码为Set.univ前提。没有删除原题前提。

实际aggregate statement：

```lean
∀ (v0 v1 : ℝ),
  v0 ∈ Set.univ ∧ v1 ∈ Set.univ →
  (∀ (r : ℝ), r ^ 2 ≥ 0) →
  (v0 + v1) ^ 2 ≤ 2 * (v0 ^ 2 + v1 ^ 2)
```

目标结论体与原题相同；严格的原题statement没有被原样保留。额外前提都可证明，故可以将这个条件定理实例化为原题，但本次没有默默做这一步，也不宣称Kernel直接证了无额外前提的原证明。自然语言等价性判断为人工检查，不是Kernel对MathIR忠实度的认证。

Mathlib实际查询sq_nonneg/sub_nonneg/sub_sq等；独立查询sub_nonneg.mp未作为单独声明找到，但使用已查到的sub_nonneg等价定理的.mp是有效Lean用法。未将未找到项标为找到。

## 2. 奇数求和归纳法

MathIR保留n=0空和、局部归纳假设、range successor展开、代入假设、n²+2n+1=(n+1)²和归纳结论。归纳假设仅处于归纳步骤作用域，不是最终定理外部前提。没有增加/删除root数学前提；有多余的求和dummy变量外层绑定，以及不必要的 `amb_natural_includes_zero`（原稿已经明确n=0）。因此不能称MathIR完全无歧义。

首轮类型翻译把“考虑n+1”这个过渡节点译为后继结论，初次proof=null。实际状态missing_proof，diagnostics为空；该节点没有可编译proof，不能伪称产生了Lean语法/类型错误。其他10个片段局部通过，但aggregate不存在，首次kernelVerified=false。

只执行一次固定statement、typesHash及statementFingerprint的proof修复。返回：

```lean
by
  rw [Finset.sum_range_succ]
  rw [h0]
  ring
```

这使用原稿后续已经明确写出的后继展开、归纳假设和算术化简，未换成其他求和证明；不过把这些操作提前放到“考虑n+1”节点，步骤来源语义仍不够准确。全部11个步骤及aggregate在本次修复后实际通过独立Kernel复核，additionalAxioms为空。

实际显示statement：

```lean
∀ (v0 v1 v0 : ℕ), ∑ v1 ∈ Finset.range v0, (2 * v1 + 1) = v0 ^ 2
```

显示中的同名绑定存在遮蔽：两个多余外层自然数参数后，才是原题的∀n。冗余参数可以实例化为0，不弱化原题，人工判断主定理等价。最终proof明确使用 `induction n`，基础情形与后继情形引用原有步骤。API最终originalMeaning仍为unresolved_ambiguities；Kernel通过不等于识别/自然语言歧义已经被消除。

## 3. 三角函数与多项式

MathIR保留加法公式、倍角公式、sin²=1−cos²、化简为4cos³−3cos以及给出P的结构；主目标正确保持“存在同一个P，再对所有θ成立”的量词顺序：

```lean
∃ P : Polynomial ℝ, ∀ θ : ℝ,
  Real.cos (3 * θ) = Polynomial.eval (Real.cos θ) P
```

没有增加/删除root数学前提。MathIR同时将待选P引入为任意free variable，又保留其definition；var_x也变为冗余绑定，amb_x_domain未解决。类型翻译将所选多项式定义为d0，却把ps7_take_P写成：

```lean
v1 = (4 : Polynomial ℝ) * Polynomial.X ^ 3
     - (3 : Polynomial ℝ) * Polynomial.X
```

v1是任意多项式，而非具体d0。主存在性目标等价原题，但这个中间statement错误；不能因主目标正确就宣称整个原证明被忠实翻译。

Flash首轮正确返回ps7 proof=null并解释无法从上下文推出任意P等于指定多项式。实际missing_proof没有Lean编译错误可返回；其余8个有proof的片段局部通过，其中ps8与goal因未成立的依赖被标为conditional_dependencies，不算整题成立。

一次固定statement修复仍返回null，明确拒绝用sorry/新公理伪造。typesHash与statementFingerprint保持不变。之后本次实际重新执行Lean复核：ps7仍missing_proof，ps8与goal依赖未成立，aggregate为null，最终kernelVerified=false。失败原因是MathIR/类型阶段的自由变量与定义绑定混淆；仅修proof无法使任意P等式成立。没有将证明片段的局部通过或任务结束冒充整题Kernel成功。

## 能力判断与边界

Flash已经展示出生成可通过真实Lean/Kernel的代数、归纳法proof的能力；也能在固定错误statement上拒绝伪造。但当前端到端转化不能被评为可靠：已出现外部前提提升、过渡节点误译和定义绑定漂移。只有三道指定样本，不能给出泛化成功率，也不能把全部问题归因于Lean proof能力；MathIR与statement生成本身就是问题来源。测试结束后不继续扩大样本、不自动修类型或改原证明。

本次形式化缓存未命中还发现一个非数学原因：本机#check诊断raw.fileName含每轮不同临时Task.lean路径。已仅在fingerprint中归一化这种元数据，保留错误文本、位置、声明/type、proof和原稿映射。274项本地测试通过；不会以新live请求验证该优化。对8个已保存的types/proofs响应，严格重建并核对旧完整fingerprint和responseId后建立新hash索引，0新增请求；原记录不删。证据见 ../no-gate-cache-reindex.json。此次8次真实请求仍照实计费记录，不能追溯改称缓存命中。

完整JSON：algebra.json、induction.json、trig_polynomial.json；Provider原始有效输出：各 *-provider-outputs.json；请求与Kernel摘要：request-and-kernel-summary.json；审计原日志位于 .data-flash-three-text-rerun/ai-audit.jsonl。导出generated.lean是本次形式化展示代码，不把单独导出文件假称另外完成了一次编译。
