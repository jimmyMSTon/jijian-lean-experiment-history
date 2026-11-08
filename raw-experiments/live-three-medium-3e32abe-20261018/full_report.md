# 极简 Lean｜三道中等难度原证明真实功能测试

日期：2026-10-18（北京时间）。安装版 Git commit：`3e32abe2c232396db3ef8c03faf2eb56764e74d6`。模型：真实 `deepseek-flash`。Lean：4.34.0 + Mathlib + 独立 Kernel。

## 方法与证据边界

三份原始中文数学证明分别通过已签名安装版 `~/Applications/极简 Lean.app` 的真实内置后端 HTTP `POST /api/v2/jobs` 提交，软件自行完成 DeepSeek → MathIR → 证明生成 → Lean 验证。未人工提供 MathIR、Lean proofTerm、fixture 或伪造 Kernel；未重复提交同一题。此次测试没有操作 GUI，也未测试图片、手写或 PDF。每题使用隔离数据库，不改用户原有数据。

## 总结果

| 题目 | 软件终态 | 完整形式 Kernel | 原稿推理独立认证 | DeepSeek 请求 | 输入 tokens | 输出 tokens | 耗时 |
|---|---|---|---|---:|---:|---:|---:|
| ① 实数条件代入平方和 | `formal_verified_source_unconfirmed` | 通过，5/5 步 | 未认证 | 2 | 14,217 | 20,899 | 158.44s |
| ② 偶数平方被 4 整除 | `MATHIR_V2_INVALID` | 未进入 | 未认证 | 1 | 10,107 | 21,548 | 91.75s |
| ③ 奇数求和数学归纳法 | `formal_verified_source_unconfirmed` | 通过，4/4 步 | 未认证 | 2 | 13,346 | 56,355 | 278.16s |

总计：5 次真实 DeepSeek 请求；37,670 input tokens，98,802 output tokens，共 136,472 tokens；三任务合计 528.35 秒。2/3 获完整形式路线 Kernel 证书，1/3 MathIR 校验失败，0/3 具有原稿推理独立忠实性认证。

## ① 实数代数

输入：设 a、b 为实数，已知 a+b=5，ab=6。证明 a²+b²=13。原证明：由 (a+b)²=a²+2ab+b²，移项得 a²+b²=(a+b)²−2ab。把 a+b=5 和 ab=6 代入，得到 a²+b²=25−12=13。因此命题成立。

数学锁定命题：∀a,b:ℝ, (a+b=5) → (ab=6) → (a²+b²=13)。五步展开、移项、代入、计算、结论的 formal steps 均 passed。独立证书 checked=true、statementMatched=true、additionalAxioms=[]。sourceProofVerified=false；这不认证 AI proof-only 的每一步是原人类推理的独立忠实翻译。

## ② 整数整除

输入：设 n 是整数，且 n 是偶数。证明 4 整除 n²。原证明：因为 n 为偶数，根据偶数定义，存在整数 k，使得 n=2k。取这样的 k，则 n²=(2k)²=4k²。因为 k² 仍为整数，所以 n² 是 4 的整数倍，即 4∣n²。证毕。

真实模型 MathIR 将局部见证 k 放入 s_witness_k，同时把局部条件 n=2k 放入 assumptions；结构校验以 V2_EXTERNAL_ASSUMPTION_SCOPE 拒绝：Theorem assumptions must be scoped on the locked goal's root-to-goal chain。用户的命题与原证明正确；失败在数学结构化/局部见证表示，不在 Lean。软件正确报告结构未完成，未冒充证明错误或擅自增加全局前提。原始失败 MathIR 保存在该题的隔离 SQLite artifact (mathir_v2_draft) 中。

## ③ 归纳法

输入：对任意自然数 n，证明从 k=0 到 k=n 的 (2k+1) 之和等于 (n+1)²，即 ∑(k=0..n)(2k+1)=(n+1)²。原证明：采用数学归纳法。当 n=0 时，左边为 1，右边为 1，成立。假设 n=m 时 ∑(k=0..m)(2k+1)=(m+1)² 成立。则 n=m+1 时，依照有限和的末项拆分，∑(k=0..m+1)(2k+1)=(m+1)²+(2m+3)=(m+2)²。因此归纳步骤成立，结论对所有自然数 n 成立。

锁定命题：∀n:ℕ, (∑k∈Finset.Icc 0 n, (2*k+1))=(n+1)²。base_claim、step_claim、split_claim、algebra_claim 四个形式验证步骤 passed；完整路线 Kernel 证书 checked=true、statementMatched=true、additionalAxioms=[]。但 sourceProofVerified=false。

## 未解决的真实能力边界

第一，普通存在消去与局部见证的 MathIR 生成、作用域验证、Lean 下放尚不能可靠泛化。第二，通用原稿推理认证没有完成：Lean 核验的是模型形成的 proof terms，不能自动证明其忠实于用户自然语言推理。以上均为测试发现，不是新流程 Gate，也未在此报告添加业务限制。

## 工程与原始证据

根目录的 `final_report.json`、各题 `metadata.json`、`job_terminal.json`、`result_summary.json`、`isolated-backend-evidence.zip`、`backend.log` 保存完整任务、阶段、请求标识与使用量；各题原始提交体与 SHA-256 在 `submitted_http_payload.json` 和 `metadata.json`。真实请求分别 2、1、2 次，均 retry_index=0。所有三题运行到软件终态，测试结束无残留 backend/Lean 进程。main/开发主线代码未改动，正式安装 App 未覆盖。
