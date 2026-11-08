# Lean-first V3.5.2 — 原子证书的前提依赖分级

## 真实来源：BMO2 2025 Q2

V3.5.1 的真实 DeepSeek 分层诊断把完整几何证明拆分为 19 个源步骤，未能证明任何完整几何步骤。

它生成的唯一获 Kernel 证书的原文断言为 `XA·XD=XP·XQ`，对应的正式 Lean 命题实质上为
`∀ XA XD XP XQ XC2 : ℝ, XC2 = XA*XD → XC2 = XP*XQ → XA*XD = XP*XQ`。

Lean 真实通过的只是这一个**条件蕴含式**。其两个圆幂等式前提在整个原稿里尚未通过 Lean，所以不得将其显示为绝对成立的完整作者步骤。之前笼统标记 `atomic_formal_verified_source_unconfirmed` 存在误导风险。

## 通用修复

- `lean_first_step_diagnostics.py` 从固定闭合形式命题中检测 `→`/`->` 条件前提。无论 Lean 是否通过，保留 `sourcePremisesIndependentlyCertified=false`，不擅自证明其来源条件。
- `atomicConditionalVerifiedCount` 与 `atomicUnconditionalVerifiedCount` 分别统计条件蕴含和无附加假设的原子证书；两者合计仍是 `atomicFormalVerifiedCount`，均不提高 `kernelVerified` 或 `originalProofCertified`。
- 对 Lean 通过但前提条件未认证的结果，状态精确标为 `atomic_conditional_formal_verified_source_unconfirmed`；Mac Native 状态行、步骤检查器、导出报告及中文反馈均明确注明【只证明前提成立时结论成立，前提本身未认证】。
- 在模型来源声明不可被形式认证的情况下，条件检测偏向保守：即使前提确实是题设正数限制，也照样标注条件蕴含。这样不会凭空产生更强的证书。

## 证据与验收

1. Q2 真实模型原输出及真实 Lean Kernel 回包保存在 `~/Documents/ChatGPT/极简lean-review/2025-BMO2-Q2-geometry-source-diagnostics-live/`。19 个完整段落 0 项通过，但有一个以上述前提为条件的原子蕴含 Kernel 通过。真实 DeepSeek 1 请求，输入 3719、输出 31948 tokens。
2. 在同一原始中文、先前真实 DeepSeek 生成的那份候选、不改数学命题的条件下，独立真实 Lean Kernel 回放得到 `atomicFormalVerifiedCount=1`、`atomicConditionalVerifiedCount=1`、`atomicUnconditionalVerifiedCount=0`、`kernelVerified=false`、`sourcePremisesIndependentlyCertified=false`。该回放是保存候选+新真实 Kernel，**不冒充新 DeepSeek 全流程**。证据保存在 `~/Documents/ChatGPT/极简lean-review/2025-BMO2-Q2-conditional-lean-real-replay/`。
3. BMO2 Q4 的此前 3 条真实 Kernel 原子证书亦保留，全文 `kernelVerified=false`；本次只改善证书类别，不声称 Q2/Q4 全篇数学证明已经被自动认证。

仍需研发：对用户原稿的每条推理建立前提—结论引用依赖图，使被引用前提本身拥有 Lean 证书后才能推动整篇 Kernel 审查。复杂几何共圆/有向角以及 Q4 的模逆/强归纳仍未攻克。
