# 极简 Lean｜三道较难数学证明：真实端到端实测全记录

**版本：81d3522；真实模型 deepseek-flash；固定 Lean 4.34/Mathlib 和独立 Kernel。**

只提交三份原始中文证明。DeepSeek 自行结构化、生成及修复 Lean 证明；不预填 MathIR，不手动修理运行中的题目，三次任务串行运行到软件终态。通过正式已安装 Mac App 自带的真实后端 HTTP 接口测试，未操作 GUI。

## 汇总

- 真实 DeepSeek 请求：**6 次**，全都有完成审计记录；模型 retryIndex 全为 0。
- 输入：**40,511 tokens**；输出：**98,919 tokens**；合计：**139,430 tokens**。
- 三任务工作时长：**574.0 秒**（依次执行，不含报告整理）。
- 整条形式化证明获独立 Kernel 证书：**1/3**。原稿推理独立认证：**0/3**。

| 题目 | 产品终态 | DeepSeek 请求 | 输入 tokens | 输出 tokens | 时长 |
|---|---|---:|---:|---:|---:|
| 平方和归纳 | failed / MATHIR_V2_INVALID | 1 | 9,812 | 30,463 | 124.2s |
| 奇数平方模 8 | completed / incomplete | 3 | 16,500 | 46,469 | 269.1s |
| 二维柯西—施瓦茨 | completed / formal_verified_source_unconfirmed | 2 | 14,199 | 21,987 | 180.7s |

## 1. 平方和归纳：6Σ(k²,k=0..n)=n(n+1)(2n+1)

DeepSeek 返回归纳证明的结构化 MathIR，但在确定性结构校验拒绝 V2_INDUCTION_SCOPE：IH and induction step must share the step scope。检查路径为 proofRoutes[route_induction].inductions[ind_main]。模型提交 9 个路线节点和一个 NatInduction 描述，归纳假设和归纳步骤的局部 scope 不一致。未进入 Lean；不是反证原数学命题错误。原始错误的 MathIR 保留在 induction_square_sum/invalid_mathir_draft.json。

## 2. 奇数平方 n²≡1 (mod 8)

模型保留 Odd n → n² % 8 = 1，10 个路线节点；9 个形成形式化 step results，其中 7 个通过 Lean。整条路线没有取得 Kernel 证书：存在缺少证明的见证节点，结论步骤因 Unknown identifier v_d_k_witness 无法完成 Lean elaboration。最终 incomplete / proof_statement_not_elaborated。软件正常执行了两次形式化请求以尝试补全，不是网络层自动重试。

## 3. 二维柯西—施瓦茨：(ac+bd)²≤(a²+b²)(c²+d²)

模型保留全部四个实变量和差的平方恒等式证明路线；5 个形式化步骤均 passed。整条证明取得独立 fresh-environment Kernel 证书 checked=true、statementMatched=true、additionalAxioms=[]，形式上成功。最终 runStatus=formal_verified_source_unconfirmed，sourceProofVerified=false：不可拿形式证书当作人类原稿每一步忠实性已被独立证明。

## 每次真实 DeepSeek 请求详细账本

| # | 题目 | 阶段 | 北京时间 | Request ID | 输入 tokens | 输出 tokens | 响应 |
|---:|---|---|---|---|---:|---:|---|
| 1 | 平方和归纳 | mathir | 2026-10-17 22:30:02 +08 | cd543dec-d1b4-4715-aa91-de0acbef2185 | 9812 | 30463 | response_received |
| 2 | 奇数平方模 8 | mathir | 2026-10-17 22:32:48 +08 | 7a2a64b4-a9a9-4ca6-8b5a-ef116ba04796 | 9755 | 21632 | response_received |
| 3 | 奇数平方模 8 | formalization | 2026-10-17 22:34:20 +08 | 84607add-a834-47ef-939f-1f4603d0f854 | 4828 | 23947 | response_received |
| 4 | 奇数平方模 8 | formalization | 2026-10-17 22:37:09 +08 | bdb32393-f455-4fa8-8b87-3d58eda72b14 | 1917 | 890 | response_received |
| 5 | 二维柯西—施瓦茨 | mathir | 2026-10-17 22:38:05 +08 | e3d5a880-6caf-411f-8f2c-f19aa51d6f34 | 9742 | 15570 | response_received |
| 6 | 二维柯西—施瓦茨 | formalization | 2026-10-17 22:39:11 +08 | cbdfa40b-4acf-4079-8127-93e4732d22de | 4457 | 6417 | response_received |

每次请求的 workflow_id、request_id、input/prompt hash、模型、retry_index、cache、完整阶段用量与生产请求审计，均保存在 all_requests_ledger.json 和各题 provider_audit.json。

## 完整原始证据路径

- full_report.json：全部原始中文题目、测试预期、任务 IDs、阶段事件、工件库存、所有步骤/diagnostics、Kernel 证书和每次请求全字段。
- all_requests_ledger.json：六条供应商请求 ID、时间、阶段、tokens、响应、指纹、重试和缓存字段。
- 各题 metadata.json：起止时间、原始输入、工作流阶段、资源用量、工件 SHA-256。
- 各题 provider_audit.json：完整内容无关请求审计；job_terminal.json：最终 Job 原始输出。
- 各题 mathir_final.json、mathir_structure_before_proofs.json、result_summary.json、last_checkpoint.json：如阶段到达则保留完整原有数据。
- 各题 isolated-backend-evidence.zip：这一题独立运行的 SQLite、所有 jobs/events/checkpoints、生成的 Lean proof terms 与形式证明 wires；包括原稿结构与报错信息，不包含 API Key 或用户旧数据库。
- 同目录 console-<case_id>.log：各题原样终端运行记录。

## 证据边界

本轮没有启动 Mac GUI、没有图像输入，也没有直接拿 DeepSeek 原始未解析 HTTP 响应正文。生产提供者存储的是解析后的结构化数学内容、Lean 证明和不含内容的请求审计。

未干预生产自动流程；没有修改或提交任何项目源代码、Git、安装包、密钥、数据库或已有用户文件。未估算未提供的实际供应商计费金额。
