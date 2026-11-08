# 极简 Lean｜三题原稿独立忠实性真实测试报告

测试日期：2026-10-18（北京时间）。签名安装版本：`316ad4fee89789633594757a277b81d6f90ca741`。

## 方法与范围

直接使用 ~/Applications/极简 Lean.app 已签名打包后端 POST /api/v2/jobs，每题仅提交完整原始中文题目与原证明（不向产品注入任何人工 MathIR、Lean proof、形式目标替换、模型 fixture 或预置答案）；使用真实 deepseek-flash、MathIR、Proof-only 和独立 Lean4/Mathlib Kernel。每题独立临时数据库，不操作 GUI，未改用户证明或项目源代码。业务自己的 Proof/Repair 正常运行，未人为限制真实 AI 调用。

## 总结

| 项目 | 核验证据 |
|---|---|
| 真实提交 | 3/3 软件任务均到终态 |
| 独立形式 Kernel 完整路线 | 2/3 通过 |
| 原稿全部独立认证 | 0/3 |
| 故意错误原稿是否被误报正确 | 否 |
| 真实 DeepSeek 请求 | 7 |
| 输入 / 输出 Token | 43557 / 59929 |
| 总 Token | 103486 |
| 三任务累计耗时 | 408.39 秒 |

真实正例的原稿未认证是软件能力缺口而不是数学错误；第三题真命题的原证明错误但没有被软件认证，不等于结论为假。

## 题目 1：实数平方差因式分解与两个条件代入

**提交原文**：设 x、y 为实数，已知 x+y=11 且 x−y=3。证明 x²−y²=33。原证明：因为 (x−y)(x+y)=x²−y²，而 x−y=3、x+y=11，所以 x²−y²=(x−y)(x+y)=3×11=33。因此原命题成立。

**数学参考性质**：原稿正确。公式因式分解和两个已知等式的代入都应属于原证明。

**软件业务终态**：`formal_verified_source_unconfirmed`；任务状态 `completed`；结束原因 `original_route_kernel_passed`。

**固定数学命题**：`(∀ (v_x : ℝ), (∀ (v_y : ℝ), (((v_x + v_y) = (11 : ℝ)) → (((v_x - v_y) = (3 : ℝ)) → (((v_x ^ (2 : ℕ)) - (v_y ^ (2 : ℕ))) = (33 : ℝ))))))`。

**证据指标**：`fixedStatementKernelPassed=True`，`originalRouteKernelPassed=True`，`originalProofVerified=False`，`sourceProofVerified=False`。

**原稿规则审计**：`source_rules_partially_certified`；已认证步骤 1，未认证步骤 4。

**耗时与 AI**：135.79 秒；2 个真实请求；13879 输入、14327 输出 tokens。

### 形式证明与来源步骤
- 形式路线 `r0`：passed；Kernel checked=True，statementMatched=True，additionalAxioms=[]。
  - `n1`: formal=passed；source=False；failureClass=None。
  - `n4`: formal=passed；source=False；failureClass=None。
  - `n5`: formal=passed；source=False；failureClass=None。
  - `n6`: formal=passed；source=True；failureClass=None。
  - `n7`: formal=passed；source=False；failureClass=None。
- 原稿路线 `r0`：independentSource=False，formulaCoverage=False，declarationTypesSourceMatched=True。
  - `n1`：sourceCertified=False；rule=None；ruleCheck=authored_causal_premise_not_in_source_dependency_graph。
  - `n4`：sourceCertified=False；rule=None；ruleCheck=authored_causal_premise_not_in_source_dependency_graph。
  - `n5`：sourceCertified=False；rule=None；ruleCheck=authored_causal_premise_not_in_source_dependency_graph。
  - `n6`：sourceCertified=True；rule=equality_symmetry；ruleCheck=independent_source_formula_and_rule_check。
  - `n7`：sourceCertified=False；rule=None；ruleCheck=source_inference_does_not_use_all_declared_dependencies。

### 真实 Provider 请求
- `bb3ee172-f7af-48ec-911c-4dadd5e1aa90` | mathir | response_received | input=10205 | output=10895 | retry_index=0
- `43ad0e5d-8004-44d5-8519-f488209c34d0` | formalization | response_received | input=3674 | output=3432 | retry_index=0

**证据保全**：`factorization_with_two_conditions/job_terminal.json`、`metadata.json`、`submitted_http_payload.json`、`isolated-backend-evidence.zip`，原稿 SHA256 `2a29e5b8cb55aaccd9731897210e46529cd6907ee6f3de4000d225118dd1cc08`，压缩证据 SHA256 `b784b1f8035c5e29459ddd3d04a33d16bf5c7a95f9eb659faeaedea560dd51de`。

## 题目 2：整数奇数的局部存在见证与代数推出

**提交原文**：设 n 是整数且 n 为奇数，证明 n² 也是奇数。原证明：由 n 为奇数，存在整数 k 使 n=2k+1。取这样的 k，n²=(2k+1)²=4k²+4k+1=2(2k²+2k)+1。因为 2k²+2k 是整数，因此 n² 是奇数。

**数学参考性质**：原稿正确。应追踪局部存在见证 k、偶奇定义、整数性，不应为缺失的通用原稿语义证书冒报成功。

**软件业务终态**：`formal_verified_source_unconfirmed`；任务状态 `completed`；结束原因 `original_route_kernel_passed`。

**固定数学命题**：`(∀ (v_d_n : ℤ), ((Odd v_d_n) → (Odd (v_d_n ^ (2 : ℕ)))))`。

**证据指标**：`fixedStatementKernelPassed=True`，`originalRouteKernelPassed=True`，`originalProofVerified=False`，`sourceProofVerified=False`。

**原稿规则审计**：`formal_reconstruction_only`；已认证步骤 0，未认证步骤 7。

**耗时与 AI**：175.81 秒；2 个真实请求；14918 输入、32880 输出 tokens。

### 形式证明与来源步骤
- 形式路线 `r_proof`：passed；Kernel checked=True，statementMatched=True，additionalAxioms=[]。
  - `n_exist`: formal=passed；source=False；failureClass=None。
  - `n_sq_eq_2k1_sq`: formal=passed；source=False；failureClass=None。
  - `n_expand`: formal=passed；source=False；failureClass=None。
  - `n_factor`: formal=passed；source=False；failureClass=None。
  - `n_sq_final`: formal=passed；source=False；failureClass=None。
  - `n_witness_odd_sq`: formal=passed；source=False；failureClass=None。
  - `n_final_odd_sq`: formal=passed；source=False；failureClass=None。
- 原稿路线 `r_proof`：independentSource=False，formulaCoverage=False，declarationTypesSourceMatched=False。
  - `n_exist`：sourceCertified=False；rule=None；ruleCheck=missing_kernel_or_supported_source。
  - `n_sq_eq_2k1_sq`：sourceCertified=False；rule=None；ruleCheck=missing_kernel_or_supported_source。
  - `n_expand`：sourceCertified=False；rule=None；ruleCheck=missing_kernel_or_supported_source。
  - `n_factor`：sourceCertified=False；rule=None；ruleCheck=missing_kernel_or_supported_source。
  - `n_sq_final`：sourceCertified=False；rule=None；ruleCheck=missing_kernel_or_supported_source。
  - `n_witness_odd_sq`：sourceCertified=False；rule=None；ruleCheck=missing_kernel_or_supported_source。
  - `n_final_odd_sq`：sourceCertified=False；rule=None；ruleCheck=missing_kernel_or_supported_source。

### 真实 Provider 请求
- `cc5d4887-80c7-436a-9720-202dce8475cd` | mathir | response_received | input=10212 | output=20316 | retry_index=0
- `c88b9365-1169-4fa6-b0af-40fde122c68e` | formalization | response_received | input=4706 | output=12564 | retry_index=0

**证据保全**：`odd_integer_square_witness/job_terminal.json`、`metadata.json`、`submitted_http_payload.json`、`isolated-backend-evidence.zip`，原稿 SHA256 `f8d643df66d1248291fb3373911d007843a60d272d63778f3db5000dd9b6bf53`，压缩证据 SHA256 `c07f8b0753b29d406bbf2d60f72e9131f5ac7383bf1a314c7a2290559b64db15`。

## 题目 3：结论数学上正确但学生原证明的理由无关

**提交原文**：设 a、b 为实数，已知 a+b=8，ab=15。证明 (a−b)²=4。原证明：因为 2+2=4，所以 (a−b)²=4。因此命题成立。

**数学参考性质**：题目结论确实由两个已知条件成立，但学生的原证明仅用 2+2=4，不能推出该结论；即使系统另证目标成功，也绝不可认证原证明。

**软件业务终态**：`incomplete`；任务状态 `completed`；结束原因 `proof_generation_returned_no_patch`。

**固定数学命题**：`(∀ (v_decl_a : ℝ), (∀ (v_decl_b : ℝ), (((v_decl_a + v_decl_b) = (8 : ℝ)) → (((v_decl_a * v_decl_b) = (15 : ℝ)) → (((v_decl_a - v_decl_b) ^ (2 : ℕ)) = (4 : ℝ))))))`。

**证据指标**：`fixedStatementKernelPassed=False`，`originalRouteKernelPassed=False`，`originalProofVerified=False`，`sourceProofVerified=False`。

**原稿规则审计**：`formally_incomplete`；已认证步骤 0，未认证步骤 2。

**耗时与 AI**：96.79 秒；3 个真实请求；14760 输入、12722 输出 tokens。

### 形式证明与来源步骤
- 形式路线 `route_original`：incomplete；Kernel checked=None，statementMatched=None，additionalAxioms=None。
  - `node_premise_2plus2`: formal=passed；source=False；failureClass=None。
  - `node_conclusion`: formal=incomplete；source=False；failureClass=missing_proof。
- 原稿路线 `route_original`：independentSource=False，formulaCoverage=False，declarationTypesSourceMatched=True。
  - `node_premise_2plus2`：sourceCertified=False；rule=None；ruleCheck=authored_causal_premise_not_in_source_dependency_graph。
  - `node_conclusion`：sourceCertified=False；rule=None；ruleCheck=kernel_statement_identity_not_attested。

### 真实 Provider 请求
- `7a75d6b1-eed0-48bd-8dbf-db4c57c59b60` | mathir | response_received | input=10173 | output=10086 | retry_index=0
- `7d69da86-568a-4feb-b9b3-5609aa6fb9b6` | formalization | response_received | input=2451 | output=2273 | retry_index=0
- `596fc98c-4a5a-42e9-ae2d-21d67f98d4c2` | formalization | response_received | input=2136 | output=363 | retry_index=0

**证据保全**：`true_goal_invalid_reason/job_terminal.json`、`metadata.json`、`submitted_http_payload.json`、`isolated-backend-evidence.zip`，原稿 SHA256 `48629e05db9e0f5e966b40793ec0b9bf15b02ca7df0def0e9dcd6aeccb761c57`，压缩证据 SHA256 `8f1e4ac40a1b1bc2e4dc3aa1b843a99aae9a5ba974170fe9c8ecb4ed50515e17`。

## 结论及实际缺口（不是新增产品规则）

1. 第一题原稿数学上正确，5/5 形式步骤过 Kernel，来源仅 1/5 正向认证；多个步骤出现 `authored_causal_premise_not_in_source_dependency_graph` 和 `source_inference_does_not_use_all_declared_dependencies`，且 route 的 `authoredFormulaCoverageMatched=false`。这是多步因果依赖与原文公式覆盖的独立认证缺口。
2. 第二题原稿数学上正确，7/7 形式步骤过 Kernel，来源 0/7；局部见证已经能编译成真实完整证明，然而存在量词/奇偶整数这类语言推理的独立规则认证尚不能完成，`declarationTypesSourceMatched=false` 与 `authoredFormulaCoverageMatched=false`。
3. 第三题最终命题在给定前提下数学上成立，但学生提供的理由 `2+2=4` 与结论无逻辑推导关系。软件只形式化验证了这个真算术事实，最终结论缺证明项，完整 Kernel 路线未通过，原稿认证 false。真实检测未误报，但不等于完成“其他证明 Kernel 成功而错误原稿被单独拒绝”的最强实测。
4. 本次仅功能测试，未改程序源码、正式 App、用户历史证明，也未添加门禁、调用次数或数学范围的产品硬规则。

## 运行环境

源码：Git 316ad4f；正式 App Bundle 源指纹与签名校验已在测试开始核验，测试进程正常运行的是真实包内后端，每题数据隔离。

根目录：`final_report.json` 为机器总结；根目录测试脚本 `run_three_source_fidelity_live_20261018.py` 在 `~/Documents/ChatGPT/极简lean-review/`；本目录的每题子目录包含原始失败/证书证据。
