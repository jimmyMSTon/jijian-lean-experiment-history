# 极简 Lean｜2026-10-22 三道高难原证明实测与 DeepSeek MathIR 深层 JSON 修复

## 产品边界

唯一正式开发主线：`codex/official-proof-core`，稳定 `main`；封存的 V2 不参与新业务。DeepSeek 输出数学中间表示和 Lean ProofTerm，只有 Lean Kernel 能证明数学命题；即便 Kernel 通过，学生真正写出的原稿也必须由独立来源数学推理规则证明忠实对应。两项必须分开，任何负例、解析失败或未处理语义都不能冒充原稿通过。

## 三道高难实测：真正业务、不手填 MathIR/Lean

原稿一致的三题：

1. 证明存在无穷多个模 4 余 3 的素数：作者以有限枚举假设与 `4(p₁⋯pᵣ)−1` 导出反证。
2. 闭区间连续函数由 `f(0)<0<f(1)` 推出开区间零点：上确界与连续性证明。
3. 实对称矩阵正交对角化：单位球面极大 Rayleigh 商、正交补不变性和维数归纳。

两轮均实际调用 DeepSeek Flash，没有写入人工数学 AST、命题证书或用户证明替代步骤：

| 测试轮次 | 版本与执行方式 | 真实 DeepSeek 请求 | 输入Token | 输出Token | 合计运行秒 |
|---|---|---:|---:|---:|---:|
| 第一轮 | 已安装并签名 Mac App `90a6e5b` 包内后端 | 3 | 34,304 | 124,511 | 502.81 |
| 第二轮 | 正式开发源码 `90a6e5b` + 尚未提交的结构提示词调整 | 12 | 252,266 | 268,581 | 1553.761 |

第一轮 **3/3 均为 PARSE_ERROR**，未进入 Lean，不能宣称 Lean 证明错误。

第二轮：

- 数论结构化成功，11 个数学形式步骤中 6 个独立 Lean 局部步骤通过，剩余 5 个缺证明项；完整 Kernel **False**，原稿来源认证 **False**，终态 `incomplete` / `proof_generation_returned_no_patch`，10 次真实请求。
- 实分析上确界：真实 1 次 DeepSeek，JSON 深层括号不完整，在 MathIR 解析时终止，未进入 Lean。
- 实对称矩阵：真实 1 次 DeepSeek，同样 JSON 深层括号不完整，未进入 Lean。
- 总体 **完整 Kernel 0/3；完整原稿来源认证 0/3**。其中“未进入 Lean”严格区别于“Lean 已否定数学命题”。

所有原始请求、结果、失效 JSON 的 SHA-256 与隔离证据见：

- `/[LOCAL_USER]/Documents/ChatGPT/极简lean-review/live-three-hard-proofs-signed-app-20261021/three_hard_first_run_diagnostic.json`
- `/[LOCAL_USER]/Documents/ChatGPT/极简lean-review/live-three-hard-proofs-signed-app-20261021/three_hard_first_run_diagnostic.md`
- `/[LOCAL_USER]/Documents/ChatGPT/极简lean-review/hard-three-structuring-retest-20261022/hard_three_comparison_report.json`
- `/[LOCAL_USER]/Documents/ChatGPT/极简lean-review/hard-three-structuring-retest-20261022/hard_three_comparison_report.md`
- 原始业务 SQLite 记录、工作流 Checkpoint、DeepSeek request/response IDs、签名版独立隔离 ZIP 与完整第二轮真实源码报告，均未删除。

## 从真实失败响应直接修的通用故障

`backend/providers/json_parser.py` 保留原有严格 JSON + Schema 校验，并补充 **有数学 AST 类型边界约束的 JSON 定界符恢复**。有些真实 DeepSeek 响应在 `proofRoutes[...].nodes[...].expression` 的嵌套 `args` 层尾部少写 `]` 与 `}`，导致紧随其后的 `scopeId` 被错误吞入数学表达式。

恢复仅允许在原始 JSON 的结构性错误恰好定位到 Node 的 `scopeId` 冒号时，解析器实际扫描 JSON 字符串之外的容器栈，确认精确祖先路径为 `root.proofRoutes[route].nodes[node].expression`，再插入必然对应的结束括号。严格禁止任何修改、合并或构造数学变量、算符、公式、证明或模型字段。恢复前后完整保留原始模型响应；每处定界符恢复留下 `recovered` 与 `edits` 来源审计。

**恢复不是验证**：之后仍要求全 JSON Schema 及 Pydantic 的数学类型/来源一致性。任何不唯一、非该 AST 位置、结构错乱或类型不正确的输出继续失败，而不是强行跑 Lean。

基于第一轮签名版 DeepSeek **原始未验证真实 JSON**（3 份 gzip fixture，不是人工 JSON）直接重放：

| 原稿 | 纯语法括号恢复 | 完整 Schema | Pydantic 结构类型 |
|---|---:|---|---|
| 数论 | 2 处 | 通过 | **通过**；只能继续进入后续数学形式验证 |
| 实分析 | 6 处 | 通过 | **拒绝**：未解决的函数受限定义域类型不能伪称已形式化 |
| 线性代数 | 4 处 | 通过 | **拒绝**：26 处类型/作用域错误不能靠加括号冒充解决 |

专项回归：`tests/v2/test_real_complex_mathir_json_delimiters.py`，包括真实三例与非对应范围拒绝。严禁把真实 DeepSeek 结构语法恢复等同于 kernelVerified。

## 剩余技术能力缺口

1. 超长任意自然语言原稿仍可能生成数学结构错误或无法表达的概念，诸如限制定义域上的连续性、依赖类型矩阵尺寸、有限维子空间和 Rayleigh 商极值；在数学类型/来源无法证明忠实时，必须保留“不确定/未形式化”，而不能用自动补写定理过关。
2. 数论虽然成功锁定命题并从 3/3 JSON 解析失败改善到真实 Lean 局部检查，但 DeepSeek 10 次后仍缺多个原作者步骤的形式证明；后续应优先改善被截断/深嵌模型结构的上下文分解与局部证明上下文，而非无限堆长证书或任意费用 Gate。
3. 这轮没有宣称对三道题全部自动验证通过，也没有运行原生 GUI 手写图形测试。需要继续扩展真实证明语言语义，但保持数学主体 Lean/Mathlib/Kernel、原稿忠实性独立检查。

**不可回退项目目标**：用户输入自己的数学题和证明，软件自动结构化并验真实际写出的推理。不要新增强制 AI 离线 Gate、限制题型名单、无理由模型请求硬截断，或采用人工替换用户原稿方式制造“全绿”测试。
