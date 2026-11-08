# Lean-first V3.4.2：三领域真实泛化测试与嵌套原稿推理完成顺序修复

## 原始正式签名 V3.4.1 测试（真 DeepSeek、真 Kernel）
使用签名安装的 `~/Applications/极简 Lean.app` V3.4.1，构建提交 `caba1630a3ad0d0a0745183de2fcca332e6ad811`，通过正式打包后端 `POST /api/v3/jobs`，原始输入保留，不预写 Lean。三题来源 `~/Documents/ChatGPT/极简lean-review/20261024-跨三领域真实泛化测试原稿.json`。

1. **数理逻辑**：`∀x (P→Q)` 与 `∀x(Q→R)`、`∃x P` 推出 `∃x(P∧R)`，完整形式证明获得 Kernel 证书，来源审计未发现具体疑点，原稿 7 个步骤；4 次真实模型请求，6,120 输入/13,605 输出 Token，89.31 秒。
2. **实分析**：非负 Lipschitz 常数 L 下 Lipschitz 映射具有一致连续性，原稿使用 `δ=ε/(L+1)`；模型正确锁定完整 ε-δ 命题，分解为 10 个原稿步骤。V3.4.1 **未送 Lean 就错误拒绝**，状态 `whole_proof_source_witness_incomplete`。模型生成的 Lean 代码用一个外层 `source_step_8 : ∀x y, ... := by` 将内部此前的第 3–7 步放在该 `by` 块中。按代码源文本顺序看是 0,1,2,8,3,4,5,6,7,9；但当证明块完成时，逻辑步骤顺序是 0,1,2,3,4,5,6,7,8,9。系统之前将该合法结构误报成重排。原始正式任务真实请求 3 次，输入 4,272/输出 21,035 Token，95.60 秒，未执行来源审计。
3. **解析几何**：r>0，点 (a,b) 在圆上，证明直线 ax+by=r² 与圆 x²+y²=r² 唯一公共点为 (a,b)，形式化为两个平面点集合交集等于单点集合。完整 Kernel 通过、8 个原稿步骤来源审计无具体疑点。4 次真实模型请求，9,239 输入/38,086 输出 Token，约 225 秒。

## V3.4.2 通用修复
`backend/lean_first_whole.py::validate_author_markers` 不再只按 Lean 源文件中 `have source_step_i` 的字符串出现顺序判定，而是按声明**完成次序**验证：对有缩进层级的嵌套 `by` 块，先要求其内部步骤完成，再计算外层 `have` 的完成；使用栈按缩进归约到 postorder。仍严格要求预期序号 0..N-1 每个出现恰好一次、真实非空命题和原稿相符，拒绝缺失、重复、同层逆序、非法占位，以及原题/源锚点修改。本修复不修改原证明、Lean 形式命题、原稿步骤，也不自动放行 Kernel 验证。

- 新增正例：合法嵌套 `source_step_3` 包含 `source_step_1`、`source_step_2`；
- 负例：同层步骤顺序反转、缺失与重复的嵌套步骤；
- 其它 V3.3/V3.4 来源校验测试全部保留。

## 独立真实 Kernel 回放
对原始 V3.4.1 已保存、此前被顺序校验误拒的实分析 proofTerm，使用修改后的来源校验得到合法 10/10 步；将同一个正式模型已生成的原始 proofTerm 及冻结的 ε-δ Lean 目标直接送真正 Lean4/Mathlib Kernel，得到 `status=verified`、独立 checked 证书、零报错（约 25.49 秒）；没有再让 AI 改写数学证明。随后**1 次真实 DeepSeek 来源审计**逐条审核十步：`no_specific_mismatch_identified_by_model`、10/10 完成，没有报告具体跳步，输入 2,216 / 输出 5,058 Token（25.06秒）。

严格区分：该实分析数学证书是**已保存原模型候选的真实 Kernel 重放**，并非在 V3.4.1 正式二进制里的一次完整成功流程；在 V3.4.2 最新正式安装包下从原稿重新执行在线端到端链路需另行测试。即使形式证明 Kernel 通过及模型无具体来源疑点，也仍保持 `originalProofCertified=false`，不自动声称自然语言证明的语义严格等价获得认证。

原始资料与独立结果位于：
- `~/Documents/ChatGPT/极简lean-review/v341-20261024-三领域Lean全线泛化测试/`
- `~/Documents/ChatGPT/极简lean-review/v341-analysis-proof-postorder-replay/`

请注意：这只是改善真实三领域测试发现的通用软件缺陷，**并非任何数学题型专门特判**。
