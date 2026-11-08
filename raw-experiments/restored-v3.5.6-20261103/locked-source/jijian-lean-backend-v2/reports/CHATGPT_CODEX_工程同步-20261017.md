# 数学核心工程同步（仅本工作树）

分支：`codex/v3-general-math-bigbuild`。实际实现提交：`631407c`、`8977e5e`。没有合并 main、推送、修改 Native、安装 App、重配 DeepSeek 或写其他工作树源码。

- 贯通 lambda、ite、显式 coerce、Mathlib 常量前置显式类型实参、真实半线性 LinearMap 的环同态值参数、库函数返回的结构类型传播。
- 新增 `closedDependencies`：引用实际独立核验的完整引理类型，支持局部假设闭合与兄弟分类 scope 汇合；不提升局部假设为总目标前提。
- 修复 Prop 类型视图、捕获检测与旧默认字段的 canonical hash 兼容。同步 Schema、结构化提示、proof-only/repair payload 和验证 step 元数据。
- 新增生成证明 let-intro 的保守确定性修复。只有实际 Kernel 和每条依赖使用均通过才应用，原证明受锁保护，不修改 runtime/Audit，不降低依赖审计标准。
- 最终非实时回归：683 passed、69 deselected、1 条既有 warning，8.53 秒。21 个不同 Lean/Kernel 定向测试最终通过；没有把全部历史 Lean 专项算作已执行。
- 真实 DeepSeek：既有 deepseek-flash 两次请求，生成两个 lambda，初始所有命题 Kernel 通过但一条依赖未审计；不新增 AI 请求的确定性 proof-only 修复后，完整原路线通过，statementHash 不变，依赖 `r_pointwise` 使用为 true。
- 真实领域代表样例覆盖实代数、有限求和、gcd、图/集合、矩阵迹/秩/行列式、线性映射核、连续/导数/积分/级数、欧氏距离三角不等式、一般测度的方差缩放、抽象群与整数理想 span。

完整证据、执行指令和明确缺口：[主体建设实证](MathIR-V3-通用数学主体建设实证-20261017.md)。真实模型原始/修复 MathIR、usage 与证书摘要：[JSON 证据](../tests/v2/fixtures/mathir-v3-real-provider-evidence.json)。Native 合同、完整 JSON 示例及 source 含义：[合同](../docs/MathIR-V3-通用函数与闭合引理合同-20261017.md)。

Native 后续需兼容 Expr.op 的 lambda/ite/coerce、mathlibConstant.typeArguments 及 RouteNode.closedDependencies，并展示局部变量/分段值/辅助引理条件。这不是已完成的客户端接入或 App 交付。当前仍缺任意具名隐参、任意结构归纳/多 recursor 组合，以及概率/几何/谱论等全面验收；不得宣称全工单所有数学目标已经达成。

按本次只写本工作树的约束，采用工单允许的 repo 内同步摘要路径，未写外部 review 工作树的同步文件。ChatGPT 可据此安全整合、接入 Native 和进行正式 App 构建；本次不执行这些工作。
