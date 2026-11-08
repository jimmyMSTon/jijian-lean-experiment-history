# Lean-first V3.3：整篇形式定理 Kernel 复核

## 2026-10-24 工程路线修正

### 已确认的 V3.2 根因
V3.2 将作者的每一句推理单独译成一个带前提的闭合 Lean 命题，允许前面没有真正被证明的中间结论作为局部目标的假设；局部 11 步 Kernel 通过不能组合成原题的证明。这是架构错误。

### V3.3 正式行为
1. 输入仍来自真实文字/图片识别，原文 SHA-256、原文与识别数据不变。
2. `WholeProofPlan` 一次 DeepSeek 结构化输出：原题完整形式命题 `formalStatement`、原题给定条件的原文精确引文、待证目标精确引文、作者所有实质证明步骤及 Unicode 原文锚点；最后的反证收尾必须作为作者推理被定位。位置有偏移时，只允许**全原稿中唯一的完全相同字符串**精确重定位；重复引用/歧义或原文不符即阻断后续验证，不静默改写任何数学文字。修正记录写入 `sourceOffsetRepairs`。
3. `WholeProofProgram` 在完全冻结的 `formalStatement` 下，只给一份连续 `by` 证明。每个作者数学推理必须在这份真实 Lean 证明内用 `have source_step_i : <原文内容对应的命题> := by ...` 留下可检查的形式化节点。顺序、唯一性、禁用占位 True 及原文锚点机械核对。
4. 原题定理和整个 `proofTerm` **在同一个 Lean 环境中**真正经 Kernel 复核。以真实 `checked`、`statementMatched`、`additionalAxioms=[]` 为标准；没有任何“局部通过即整篇通过”的升级途径。
5. 仅遇到实际 Lean 编译诊断时，DeepSeek 可修 proofTerm（不允许重新输出命题或更改作者步骤锚点）。修复请求显式传入必须保留的全部 source_step 标记；修复必须保留所有 source_step 标记，再次独立 Kernel 复核。未通过来源标记校验的修复候选保留完整被拒绝代码，不进入 Kernel，修复前后真实证据均保留。
6. 对源稿-数学语义和自然语言作者理由的严格忠实性，Lean Kernel **不能自动认证**，所以即使整篇形式命题通过也保持 `originalProofCertified=false`、`sourceEquivalenceCertified=false`。这不是产品已实现全面原稿验证的声明。
7. 历史与中断恢复仍按 immutable checkpoint 与 `runTraceId`，正式 API `/api/v3/jobs` 不变。旧局部验证模块仍可供历史/审计，**不是正式默认按钮**。

### 工程泛化和否证测试（真模型、真 Kernel）
* 没有参与本轮开发的实数不等式：`(a+b)^2 ≥ 4ab`，2 次 DeepSeek，整篇形式定理 Kernel 通过。
* 故意错误的奇偶性推理：`∀n:ℤ, Odd(n(n+1))`，2 次真实请求；模型拒绝重建正确证明，报告翻译不完整，不假称 Kernel 给出反例证书。
* 前 n 个奇数和 = n² 的归纳法：2 次 DeepSeek，整篇形式定理 Kernel 通过；代码明确按原稿基例/归纳步构造 have markers。
* 复杂原稿重测：原来 17 步的高联不等式，初次 whole plan 出现 `source_span_mismatch_at_12`；加入通用“逐字唯一引文重锚定”后，第二次整篇形式化成功锚定 19 步。但模型将有限求和写为 Lean 不接受的 `∑ i in Finset.range n, ...`，导致整篇目标解析失败。加入纯语法、非数学重写的 `∑ i in s,` → `∑ i ∈ s,` 通用规则，保存规范化前后的命题和证明；**不重新调用 DeepSeek** 的第三次真实 Lean 回放证明完整目标已可解析，但原证明仍有 `unsolved goals` / tactic 目标状态问题及一处加法顺序类型不匹配，Kernel 未通过。不能宣称高联题已经解决。
* 静态安全与 API 真实路径的 fixture 测试、SwiftUI typecheck 另列实测，不等于真实模型泛化成功。

### 尚未解决的硬边界
即使 Lean 通过完整定理，也无法从 Kernel 本身保证 LLM 对原题自然语言、手写图片识别和作者原本推理路线的语义完全忠实。source_step 的形式化标记只证明有命名代码节点，不能独立保证该数学公式与原文语义等价。因此 V3.3 是**整篇形式定理编译形态**，仍需大规模不见题测试、失败诊断收敛、来源忠实性独立检查与更好的用户可读反馈才能达到最终产品目标。不得以几道样本通过宣称完全泛化或数学无错。

## 发布与回滚
只从开发分支提交已验证源码，稳定 main 必须 fast-forward 合并，再从 main 全量构建、签名、安装唯一入口 `~/Applications/极简 Lean.app`。用户运行中的旧进程不擅自关闭。保留 V3.2 历史版本及所有审计日志。
