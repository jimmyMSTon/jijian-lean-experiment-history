# Lean-first V3.5.3：数学竞赛原稿中错误断言的独立发现与 Lean 反证

## 动机与旧测试真实性修正

2025 BMO2 第 3 题的先前五段中文证明，是助理自己写的，曾错误地作为“正常证明”提交。经重新审阅，其中第二步声称“每次行交换改变恰好两个 r_i”，该论断为假：在 4×4 交错棋盘上交换第 1 和第 3 行（两行颜色完全相同），整板无变化，因此 r_i 不发生任何改变。**不能继续将该样本当作完全正确证明的负样本来判断软件问题**；应作为正常题面+错误原稿来检测软件是否能明确定位反例。

注意，反例只否定**原稿的一条中间断言**，没有否定 BMO2 第 3 题的数学命题或最终可能正确的最大值答案。

## 实现（通用路径，没有题号/棋盘特判）

新增 `backend/lean_first_fault_screen.py`：
- 仅当整篇 Lean 翻译未完成且已有原始来源步骤时，额外运行一次**严格的错误陈述筛查**；已有明确错误诊断时沿用现存反证路径，不重复触发。
- 仅返回可指向原稿步骤的**逐字源句**，具体反例及原稿条件核对；不存在可确信错误时必须返回疑点为 false，不能把模型“不懂/无法形式化”解释为作者有错。
- 一个模型嫌疑 **不算 Kernel 证书**、不算数学错误：下游 `refute_authored_claim` 另一次模型负责闭合且保留原稿变量域的 Lean 命题/否定证明，严格检查逐字来源和禁用命令，再由真实独立 Lean Kernel 证明其否定。未通过 Kernel 始终记“未证实”；原题/原稿整篇也绝不因此被判假。
- 结果保留 `sourceFalsityScreen`（发现候选）和 `authoredClaimRefutation`（真正 Kernel 证书）两个互不替代的字段。原稿完整 `kernelVerified`、`formalProofCertified`、`originalProofCertified` 仍为 false。
- 无固定 n、无固定行/列、无棋盘条件特判，不引用人工修正证明，不恢复 V1/V2 或添加新的离线/费控 Gate。

## 真实 BMO2 Q3 正样本（有具体数学错误）

保持 V3.5.0 既存原始题面、中文证明和五个原始步骤，**不在提示词中告诉任何模型“哪里有错”**。2026-10-25 运行：
`~/Documents/ChatGPT/极简lean-review/run-2025-BMO2-Q3-falsity-screen-live.py`

- 第一次真实 DeepSeek 自动识别作者步骤中的“每次行交换改变恰好两个 r_i，列交换改变恰好两个 c_j”，并自主提出 n=4、交换第1与第3行的实际反例。
- 第二次真实 DeepSeek 独立把原作者局部错误断言“每次行交换改变恰好两个 r_i”闭合为 **任意 n、任意 Fin n 上排列 σ、任意两条不同交换行 a≠b** 的 Lean 命题（ZMod 2 编码原行的奇偶位元）。
- 独立 Lean4/Mathlib Kernel 接受**该闭合全称命题的否定**，使用合法反例 n=4、a=0、b=2、恒等置换，Kernel 证书 `checked=true`、`statementMatched=true`、`additionalAxioms=[]`、0 errors。
- 共 **2 次**真实 DeepSeek 请求，输入 **3,503**、输出 **30,857** tokens；耗时 **207.04 秒**。
- 新任务原始审计及真实 Lean Kernel 证书：
  `~/Documents/ChatGPT/极简lean-review/2025-BMO2-Q3-20261025-real-false-claim-discovery/`，分别 `screen.json`、`kernel-refutation.json`、`data/ai-audit.jsonl`。
- 核验结论严格为 `source_assertion_formal_negation_kernel_verified_source_unconfirmed`。Lean 证明所翻译命题为假，但没有对中文/Lean 语义等价的形式证书；也绝不意味着 BMO2 Q3 原题命题假。

## 真实 BMO2 Q4 阴性对照（原稿无明显虚假断言）

在第 4 题原来的正确数学证明六个步骤上，仅调用相同 `screen_authored_falsity`；模型输出 `suspected=false`，说明未找到真实可反例推翻的作者断言，没有编造数学错误或发送虚假反证任务。一次真实 DeepSeek 请求，输入 2,182、输出 4,552 tokens，耗时 22.52 秒。审计：
`~/Documents/ChatGPT/极简lean-review/2025-BMO2-Q4-false-positive-control/`。

两道题的一正一负只是严肃回归，不代表可以推定全域识别的灵敏度、假阳性率，更不能据此说已解决奥林匹克级别全部正确证明的自动形式化。

## 尚未解决

BMO2 Q2 完整圆幂/有向角证明与 Q3 的完整棋盘最优交换次数、Q4 的正整数递推互素强归纳和 2026 计数，**仍未取得整篇形式定理证书**。当前成果主要修复一个严重的实验质量漏洞：不能把作者自己写的错误证明当成“数学正确而模型不会译”。下一轮重点继续提升命题/证明的可组合形式化与前提闭合，不应为过拟合试题写定制 Lean 解答。
