# Lean-first V3.2：局部 Lean 诊断修复与题目目标隔离

## 正式产品行为
本次用户确认“继续干”之后，在 Lean-first 正式路线继续实现局部 Lean 代码修复，**不**恢复封存的 MathIR 形式化主体，也不赋予 AI 解题或自行构造新的作者证明的权限。

- 原稿被分类为 given（题面前提）、claim（题面要求证明的目标）、inference（作者实际写出的推理）。
- **claim 只作为待证目标保存；不调用模型自行求证，绝不能取得冒充作者原推理的“已验证步骤”**。真正有原文论证的 inference 才进入局部 Lean 验证。
- 初次形式化仅由 DeepSeek 负责忠实翻译，LeanRunner 在独立环境检查和生成实际证书；证明语义的来源忠实性不由 Kernel 自动认证。
- 当正式 Lean 返回确实可操作的代码错误时，DeepSeek 收到原始 proofTerm、**后端锁定的** formalStatement、对应 Unicode 来源区间、依赖与原始 Lean 诊断，只能输出 proofTerm 和修复技术说明。服务端拒绝声明/禁用公理命令；修复后对完全相同的 formalStatement 和 sourceRefs 再次调用 Lean。
- 每一次原始和修订 proofTerm、diagnostics、certificate 和模型 provenance 都被写入该来源步骤的 repair.attempts。仅在实际 Kernel 证书检查通过且 no extra axioms 时给局部形式通过；继续标记 sourceEquivalenceCertified=false、originalProofCertified=false。
- 数学结构、缺失证明、不可形式化的步骤和命题本身解析失败不会伪装成已修好；如果模型拒绝修改、生成无效代码或复查未通过，保留原始错误证据。**该技术修复尝试不能被宣称为独立验证作者自然语言证明**。
- 反馈与 Mac 原生客户端显示局部证书来源、实际编译诊断、修订尝试及未核验依赖；题面已知和待证目标中性呈现，不冒充数学错误。
- 旧版 V3.1 和更早历史保留，已有局部持久化与中断恢复保持有效。

## 实现边界
一次代码诊断修复可修正部分 Mathlib 名称、语法、binder 和 tactic API 错误，不意味着能自动补齐所有不完备证明；后续复杂推理缺口仍需要精确区分“原稿确实缺失理由”与“模型无法形式化”。系统不在失败后以其他证明替代用户的数学路线，也不擅自把 Lean 编译错误说成数学反例。

## 审计
- 单元/契约测试覆盖：待证命题不求证、固定 formalStatement 不变、来源 span 不变、修复前后证据、无额外公理检查、AI 无效修复拒绝及完整任务兼容。
- 真实模型回放：见极简lean-review/v32-locked-repair/ 的独立审计记录；如不存在或失败，不宣称真实修复通过。
- 正式安装必须由稳定 main 完整重打包并签名，来源 commit 与二进制校验一致。
