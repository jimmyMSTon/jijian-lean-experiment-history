<!-- Source: local experiment archive; paths and email addresses sanitized -->

# 极简 Lean｜2026-10-18 最新主线三道原证明真实软件回归

## 已核实测试版本

- 包名版本：**2.0.0**；工程源码、稳定 main、收敛开发分支、唯一安装版源指纹均为 **`316ad4fee89789633594757a277b81d6f90ca741`**。
- 正式 App：`/[LOCAL_USER]/Applications/极简 Lean.app`；签名核验：**True**；主可执行 SHA-256 `892a1b00c52e0f58f2a21523cbb05fbd6d54afc92d2ac6d14e53e945064f4228`；包内后端 SHA-256 `bfc6e79c36aa37631ee9165be913b4a59dba82f28da921ebed814042b5f9bcbb`。
- 29 个 Git 工作树中的其他未合并开发改动，不属于已提交合并的最新稳定正式发行代码；未修改或覆盖那些工作树。
- 此次直接运行签名 App **实际打包的原生后端**，每题只发送原始自然语言证明到 `POST /api/v2/jobs`；真实 DeepSeek Flash、MathIR、Lean/Kernel；不使用 fixture、模拟 Kernel、人工书写 MathIR/Lean，不经过鼠标 GUI。每题隔离数据库，调用与测试来源可复现。

## 三题总体

| 编号 | 题目 | 用户原稿的数学性质 | 任务终态 | 完整形式 Kernel | 整份原稿独立认证 | 真实 DeepSeek 请求 | 输入 Token | 输出 Token | 耗时 |
|---|---|---|---|---|---|---:|---:|---:|---:|
| 1 | 正确多步实数代数：平方和、移项与双条件代入 | 正确 | formal_verified_source_unconfirmed | 通过 | 未通过/未认证 | 2 | 14665 | 16087 | 129.30s |
| 2 | 正确整数证明：存在见证、立方及偶性 | 正确 | formal_verified_source_unconfirmed | 通过 | 未通过/未认证 | 2 | 14309 | 32605 | 175.03s |
| 3 | 故意错误原稿：与第一题相同真结论、无关理由 | 结论正确，但所给理由无效 | incomplete | 未通过/未进入 | 未通过/未认证 | 3 | 14448 | 9751 | 81.90s |

**真实 DeepSeek 总请求数：7；输入 43422、输出 58443、总计 101865 Token；三题运行累计 386.23 秒。**

三道提交都得到软件的业务终态。两道正确证明的固定形式路线通过独立 Kernel，但整份原稿没有完整来源规则证书；一份故意无效的原稿没有被误报为通过。证据不支持宣称通用自然语言忠实性问题已完成。

## 题目 1：正确多步实数代数：平方和、移项与双条件代入

**原始中文输入（唯一发送给正式软件的证明文本）**：设 x、y 为实数，已知 x+y=9，xy=14。证明 x²+y²=53。原证明：由 (x+y)²=x²+2xy+y²，移项得 x²+y²=(x+y)²−2xy。将 x+y=9、xy=14 代入，得到 x²+y²=9²−2×14=81−28=53。因此结论成立。

**期望性质**：用户原稿正确，需完整核对数学公式、移项、代入与等式链。

**固定 Lean 命题**：`(∀ (v_d_x : ℝ), (∀ (v_d_y : ℝ), (((v_d_x + v_d_y) = (9 : ℝ)) → (((v_d_x * v_d_y) = (14 : ℝ)) → (((v_d_x ^ (2 : ℕ)) + (v_d_y ^ (2 : ℕ))) = (53 : ℝ))))))`。
**业务结果**：job=`completed`，run=`formal_verified_source_unconfirmed`，termination=`original_route_kernel_passed`，fixedStatementKernelPassed=True，originalRouteKernelPassed=True，originalProofVerified=False，sourceProofVerified=False。
**原稿来源审计**：status=`source_rules_partially_certified`，认证步骤=5，未认证步骤=1。

### 形式 Kernel 与每步证据
- route `r_original`，formalStatus=passed，completeOriginalRouteKernelPassed=True，certificate.checked=True，statementMatched=True，additionalAxioms=[]。
  - `n_expand`，formalStep=passed，attempt=verified，failureClass=None，dependencyEvidence=not_required。
  - `n_rearrange`，formalStep=passed，attempt=verified，failureClass=None，dependencyEvidence=all_declared_dependencies_used。
  - `n_subst`，formalStep=passed，attempt=verified，failureClass=None，dependencyEvidence=all_declared_dependencies_used。
  - `n_calc1`，formalStep=passed，attempt=verified，failureClass=None，dependencyEvidence=not_required。
  - `n_calc2`，formalStep=passed，attempt=verified，failureClass=None，dependencyEvidence=not_required。
  - `n_conclusion`，formalStep=passed，attempt=verified，failureClass=None，dependencyEvidence=all_declared_dependencies_used。
- source route `r_original`，sourceVerified=False，sourceFormulaCoverage=True，declarationTypesSourceMatched=True。
  - `n_expand`，sourceVerified=True，rule=explicit_polynomial_identity，ruleCheckReason=independent_source_formula_and_rule_check。
  - `n_rearrange`，sourceVerified=True，rule=explicit_algebraic_rearrangement，ruleCheckReason=independent_source_formula_and_rule_check。
  - `n_subst`，sourceVerified=True，rule=explicit_equation_substitution，ruleCheckReason=independent_source_formula_and_rule_check。
  - `n_calc1`，sourceVerified=True，rule=explicit_polynomial_identity，ruleCheckReason=independent_source_formula_and_rule_check。
  - `n_calc2`，sourceVerified=True，rule=explicit_polynomial_identity，ruleCheckReason=independent_source_formula_and_rule_check。
  - `n_conclusion`，sourceVerified=False，rule=None，ruleCheckReason=source_inference_does_not_use_all_declared_dependencies。

### 每次真实模型请求（独立审计）

| Request ID | 阶段 | Provider 结果 | 输入 | 输出 | Retry Index |
|---|---|---|---:|---:|---:|
| `02d3ec60-6ba4-4a55-ba4e-fddf0f19bb4c` | mathir | response_received | 10214 | 10962 | 0 |
| `d216007f-029d-4375-848e-d7428a353eb2` | formalization | response_received | 4451 | 5125 | 0 |

证据：`valid_square_sum_53/submission.json`、`submitted_http_payload.json`、`metadata.json`、`job_terminal.json`、`result_summary.json`、`isolated-backend-evidence.zip`；
原稿 SHA-256：`d98ebbdc48ed37fe9491b338b384da3ba2461ecc80740ff10bf2a805b61ce794`，隔离证据归档 SHA-256：`da21d8e8be3d8d039e8d2c836d4b71ba463f8d9a4fed762bc84974ce407c0fc1`。

## 题目 2：正确整数证明：存在见证、立方及偶性

**原始中文输入（唯一发送给正式软件的证明文本）**：设 n 为整数且 n 为偶数，证明 n³ 为偶数。原证明：因为 n 是偶数，存在整数 k，使得 n=2k。取这样的 k，则 n³=(2k)³=8k³=2(4k³)。由于 4k³ 为整数，所以 n³ 为偶数。证毕。

**期望性质**：原稿正确，需独立追踪奇偶定义、局部 k 见证和整数封闭性。

**固定 Lean 命题**：`(∀ (v_n : ℤ), ((Even v_n) → (Even (v_n ^ (3 : ℕ)))))`。
**业务结果**：job=`completed`，run=`formal_verified_source_unconfirmed`，termination=`original_route_kernel_passed`，fixedStatementKernelPassed=True，originalRouteKernelPassed=True，originalProofVerified=False，sourceProofVerified=False。
**原稿来源审计**：status=`formal_reconstruction_only`，认证步骤=0，未认证步骤=7。

### 形式 Kernel 与每步证据
- route `r_original`，formalStatus=passed，completeOriginalRouteKernelPassed=True，certificate.checked=True，statementMatched=True，additionalAxioms=[]。
  - `exists_k`，formalStep=passed，attempt=verified，failureClass=None，dependencyEvidence=all_declared_dependencies_used。
  - `eq1`，formalStep=passed，attempt=verified，failureClass=None，dependencyEvidence=all_declared_dependencies_used。
  - `eq2`，formalStep=passed，attempt=verified，failureClass=None，dependencyEvidence=not_required。
  - `eq3`，formalStep=passed，attempt=verified，failureClass=None，dependencyEvidence=not_required。
  - `eq_combined`，formalStep=passed，attempt=verified，failureClass=None，dependencyEvidence=all_declared_dependencies_used。
  - `c_local_even`，formalStep=passed，attempt=verified，failureClass=None，dependencyEvidence=all_declared_dependencies_used。
  - `c_goal_root`，formalStep=passed，attempt=verified，failureClass=None，dependencyEvidence=all_declared_dependencies_used。
- source route `r_original`，sourceVerified=False，sourceFormulaCoverage=False，declarationTypesSourceMatched=False。
  - `exists_k`，sourceVerified=False，rule=None，ruleCheckReason=missing_kernel_or_supported_source。
  - `eq1`，sourceVerified=False，rule=None，ruleCheckReason=missing_kernel_or_supported_source。
  - `eq2`，sourceVerified=False，rule=None，ruleCheckReason=missing_kernel_or_supported_source。
  - `eq3`，sourceVerified=False，rule=None，ruleCheckReason=missing_kernel_or_supported_source。
  - `eq_combined`，sourceVerified=False，rule=None，ruleCheckReason=missing_kernel_or_supported_source。
  - `c_local_even`，sourceVerified=False，rule=None，ruleCheckReason=missing_kernel_or_supported_source。
  - `c_goal_root`，sourceVerified=False，rule=None，ruleCheckReason=missing_kernel_or_supported_source。

### 每次真实模型请求（独立审计）

| Request ID | 阶段 | Provider 结果 | 输入 | 输出 | Retry Index |
|---|---|---|---:|---:|---:|
| `9c97b4d8-4749-4443-a737-c1dd65f06543` | mathir | response_received | 10199 | 21461 | 0 |
| `2fb403e4-33fb-4ba7-b4e2-8091b807e864` | formalization | response_received | 4110 | 11144 | 0 |

证据：`even_integer_cube_witness/submission.json`、`submitted_http_payload.json`、`metadata.json`、`job_terminal.json`、`result_summary.json`、`isolated-backend-evidence.zip`；
原稿 SHA-256：`1a1693212b21e59fad990a0226deebb343cc04028f37178d6085ce133f81ffaf`，隔离证据归档 SHA-256：`5545660a703aee8a164a04bf7515df66cbbec9d50cff07393966e17e690149eb`。

## 题目 3：故意错误原稿：与第一题相同真结论、无关理由

**原始中文输入（唯一发送给正式软件的证明文本）**：设 x、y 为实数，已知 x+y=9，xy=14。证明 x²+y²=53。原证明：因为 1+1=2，所以 x²+y²=53。证毕。

**期望性质**：与第一题相同的真命题，学生用无关理由，应拒绝原证明认证；不得因 AI 另证结论而误报。

**固定 Lean 命题**：`(∀ (v_x : ℝ), (∀ (v_y : ℝ), (((v_x + v_y) = (9 : ℝ)) → (((v_x * v_y) = (14 : ℝ)) → (((v_x ^ (2 : ℕ)) + (v_y ^ (2 : ℕ))) = (53 : ℝ))))))`。
**业务结果**：job=`completed`，run=`incomplete`，termination=`proof_generation_returned_no_patch`，fixedStatementKernelPassed=False，originalRouteKernelPassed=False，originalProofVerified=False，sourceProofVerified=False。
**原稿来源审计**：status=`formally_incomplete`，认证步骤=0，未认证步骤=2。

### 形式 Kernel 与每步证据
- route `route_original`，formalStatus=incomplete，completeOriginalRouteKernelPassed=False，certificate.checked=None，statementMatched=None，additionalAxioms=None。
  - `claim_one_plus_one`，formalStep=passed，attempt=verified，failureClass=None，dependencyEvidence=not_required。
  - `claim_conclusion`，formalStep=incomplete，attempt=missing_proof，failureClass=missing_proof，dependencyEvidence=dependency_usage_not_audited。
- source route `route_original`，sourceVerified=False，sourceFormulaCoverage=False，declarationTypesSourceMatched=True。
  - `claim_one_plus_one`，sourceVerified=False，rule=None，ruleCheckReason=authored_causal_premise_not_in_source_dependency_graph。
  - `claim_conclusion`，sourceVerified=False，rule=None，ruleCheckReason=kernel_statement_identity_not_attested。

### 每次真实模型请求（独立审计）

| Request ID | 阶段 | Provider 结果 | 输入 | 输出 | Retry Index |
|---|---|---|---:|---:|---:|
| `a5b401eb-4e03-4f22-8e53-84b38d7f079a` | mathir | response_received | 10168 | 4852 | 0 |
| `946c501a-36a2-4e15-9fb5-c025b8cdc8d0` | formalization | response_received | 2282 | 1099 | 0 |
| `b29886b3-eb6a-4183-a59f-ef55b72c36ef` | formalization | response_received | 1998 | 3800 | 0 |

证据：`invalid_reason_same_true_goal/submission.json`、`submitted_http_payload.json`、`metadata.json`、`job_terminal.json`、`result_summary.json`、`isolated-backend-evidence.zip`；
原稿 SHA-256：`70dffac05cd6a8dca69f4940d02781bbe0913f8bb64f596771e39753b5e59177`，隔离证据归档 SHA-256：`1c7db8bd20bc9a405929eae1a015289b46c1ef7e79e35f34d430c86a50966219`。

## 实际观察与未确认问题

- 正向多步等式链：具体展开、移项、代入及计算能够独立认证，但末结论节点未完全认证（原稿依赖使用审计不足），不能宣称正确的原证明已经完整通过。
- 存在量词与偶性：数学形式 Kernel 路线全部通过，但原稿公式覆盖和整数声明来源审计还不具备足够的正向泛化认证能力。
- 故意错误理由：软件在源码相同真命题条件下，没有将 `因为 1+1=2，所以 x²+y²=53` 判为有效原稿；中间算术事实可形式认证，而目标 claim 无证明，整条 Kernel 未通过。这不能代替 Kernel 另证成功的更强负例。
- 以上是功能测试记录，不是修复。没有覆盖未合并分支，没有更改 App、源码、全局 Gate、AI 调用上限或产品规则。

## 原始数据和可追溯性

- `final_report.json`：三题完整计算机记录，含每次实际请求 ID、耗时、Token 及来源步骤审计。
- `version_attestation.json`：最新 main、正式 App、签名、可执行文件 SHA-256 对齐事实。
- `session.json`：实际运行包内后端的 SHA-256 与 Git 源码指纹。
- `run_three_latest_commit_316ad4f_20261018.py`：所在 `~/Documents/ChatGPT/极简lean-review/` 的重现脚本。

