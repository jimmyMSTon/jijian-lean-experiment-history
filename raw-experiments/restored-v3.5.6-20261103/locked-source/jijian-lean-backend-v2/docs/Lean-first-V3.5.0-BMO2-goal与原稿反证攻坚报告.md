# 极简 Lean V3.5.0：BMO2 正式试卷的验证能力攻坚

## 范围与原则

本轮从 V3.4.2 正式版真实测试 2025 UKMT BMO2 4 道真题获得的不可变证据出发；在 **同一 Lean-first 正式工程**中修复通用的两个失败类型：

1. 复杂数学对象和操作定义让模型在 `formalStatement` 中输出非法的 Lean 顶层声明，而用户正确的数学命题不能继续到 Kernel。
2. 模型能够指出原证明的错误等式，却没有独立 Lean 反例证书，因此“原文确有数学错误”仍依赖模型口头判断。

未改变正常任务默认真实 DeepSeek 调用，也没有重新启用 V1/V2、MathIR 或全局离线开关。**严禁把修复命题语法和反证某条断言冒充原题整篇证明通过。**

## 正式原始 BMO2 基线

| 题目 | V3.4.2 真实结果 | 具体瓶颈 |
|---|---|---|
| Q1 三角形数分式求和，故意植入错误证明 | `whole_proof_translation_incomplete` | 模型指出等式错误，但没有 Lean 证书 |
| Q2 内心垂直平分线与两圆共圆 | `whole_proof_translation_incomplete` | 几何对象和有向角/圆幂论证未转成完整 Lean |
| Q3 n×n 棋盘行列交换最坏恢复次数 | `whole_invalid_source_plan` | 把 `import/namespace/def/inductive` 当成待证单个 Prop |
| Q4 幂次 2025 的整数递推解数 | `whole_proof_translation_incomplete` | 互素、模同余、强归纳、计数未完整形式化 |

基线目录：
`~/Documents/ChatGPT/极简lean-review/2025-BMO2-V342-四题真实全线验证/`。

## 一：通用 `goal` 表达式修复（不是试题特判）

新 `backend/lean_first_goal_repair.py`：仅在 **原有完整命题格式非法** (`invalid_goal_expression`) 时请求一次 `LeanGoalExpressionRepair`；原题和原稿步骤、先前不合法候选全部只读保留。

模型只能输出一个闭合 `Prop` 表达式，可用嵌套 `let` 为非线性数据类型、状态转换、极值次数编码；拒绝独立顶层命令、任何未解决的关键数学概念、不自认保留语义的候选，以及带禁用命令的候选。必须真实调用 Lean `probe_statement` 展开并通过，才能把语法修复后的目标用于后续正式证明翻译。完整来源语义尚不具备形式认证，始终明确 `sourceEquivalenceCertified=false`。

### BMO2 Q3 新鲜实测

- 从原始失败任务的真实模型锁定命题和源输入继续，DeepSeek 真请求 **1 次**（输入 1,826 / 输出 8,278 tokens）。
- 将 `Board` 编为 `Fin n → Fin n → Bool`，行列操作用 `Bool × (Fin n × Fin n)` 表示，并以内层 `let` 定义棋盘状态、合法操作列表、可达性、恢复最小次数及 `if even then n/2 else n-1`；完整约束仍为所有正整数 n，含上界与下界的原题量词。
- **真实 Lean elaborator 报 `elaborated=true`**：解决了原来 `invalid_goal_expression` 阶段的语法阻碍。
- 此证书仅表示原始目标的修订编码确实是 Lean `Prop`，不是其可证性。
- 第二次针对这个已通过类型检查的目标进行 **真实 DeepSeek 整篇原证明翻译**（1 次请求，输入 2,202 / 输出 8,719 tokens）后，模型仍返回 `complete=false`：棋盘操作与奇偶不变量、最坏配置构造还没有对应的 Lean proofTerm，**Q3 并未取得完整 Kernel 证明证书**。
- 两阶段实验产物：
  `~/Documents/ChatGPT/极简lean-review/2025-BMO2-goal-expression-repair-live/`、
  `~/Documents/ChatGPT/极简lean-review/2025-BMO2-Q3-repaired-goal-proof-live/`。

## 二：原稿错误步骤的独立 Lean 否定证书

新 `backend/lean_first_refutation.py`：只有原始证明翻译返回 `complete=false` 并明确指明“错误等式、数学断言一般不成立、反例”等**具体数学虚假陈述**，才尝试额外单步反证。单纯“无法形式化”“API 不支持”不能触发。模型必须：
- 引用真实 `sourceExcerpt`，并核对它是某个作者步骤的逐字连续片段；
- 用闭合的 Lean Prop 表示该作者在原稿所声称的完整普遍断言、保留所有约束；不能为了易举反例偷偷固定 n；
- 给出 `by` 项证明 **同一个固定断言的否定**，交给独立 Lean Kernel；
- 禁用 `sorry/axiom/unsafe` 等绕过命令。不通过 Kernel 不报数学反证；已有原题整体形式证明仍判未通过。

### BMO2 Q1 新鲜实测

故意错误等式来自提交原文：
```
2(1/n−1/(2n−1))=1/n
```
独立反证把它翻译成对 **所有正整数 n** 的有理数等式，固定为 Lean 源断言；Lean 对其**否定命题**独立 Kernel 复核结果：`status=source_assertion_formal_negation_kernel_verified_source_unconfirmed`、`kernelRefutationVerified=true`，0 条 Lean 错误。具体反例 n=2 时左侧 1/3 右侧 1/2。

真实 DeepSeek 请求 1 次，输入 1,423 / 输出 2,553 tokens，总时长 37.66 秒。结果不改变 `whole_proof_translation_incomplete`、`originalProofCertified=false`、`overallProblemDisproved=false`。模型文本到形式等式的语义忠实性仍不是形式认证。

原始证书目录：`~/Documents/ChatGPT/极简lean-review/2025-BMO2-Q1-source-refutation-live/`。

## 三：反馈和原生 Mac UI

- `lean_first_feedback.py` 及正式结果报告分别展示【整篇 Kernel 验证】与【某一原文断言的独立 Lean 反证】，也展示复杂 `goal` 表述修复的来源和未认证边界。
- Mac 原生结果文案展示准确原文引用、被否定的 Lean 表达式、Kernel 通过情况，不把“某一步是假”误写成“整题命题是假”。
- 所有原本拒绝的候选和模型调用元数据、真实 Kernel 结果保留。

## 四：目前尚未解决的严格限制

Q2 大量欧氏几何角度/圆幂与对象构造，以及 Q4 递推数论中模运算、互素性、强归纳和集合计数，**仍未自动编译出完整 Lean proofTerm**。Q3 的命题现在能够展开，但证明生成仍失败。完全自动地检验任意 BMO2 证明的目标目前**没有实现**。

本轮工程不能用 BMO Q1 的反例成功来掩盖三个正常样本未取得 Kernel 完整证书，也不能保证未来复杂证明一定通过。后续技术方向应围绕自定义 Lean 语义对象模板、语义忠实性风险定位、带局部 Kernel 反馈的可组合证明义务展开，但不能直接以 AI 补写缺漏数学证明来替代原稿。
