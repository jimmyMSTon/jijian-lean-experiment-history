# MathIR v2 第五阶段语义约定（研究旁路）

本约定只作用于 `backend/v2` 研究旁路，不改变正式 v1 验证路径。

| 源材料 | MathIR v2 表示 | 能否单独构成已验证步骤 |
|---|---|---|
| 用户原稿中的命题 | `Goal.expression`；同时由 `statementHash` 锁定编译后的 Lean statement | 否。Kernel 只判定该固定形式命题的 proof term |
| 原稿中的推理理由/数学行 | 原文保留于 `SourceEvidence`；每个形式化 `RouteNode` 通过 `sourceRefs` 指向原稿片段；`expression` 表达该行的数学内容 | 只有它是 claim、在目标路线闭包中、存在通过 Kernel 的 proof，且显式依赖实际使用时，才构成完整路线步骤 |
| 系统翻译出的 statement/AST | `Goal`、declarations、assumptions、route expressions 和 source mapping | 不是用户原文；`sourceAssessment` 是来源对应判断，不是数学证书 |
| 原稿中已经存在的 Lean proofTerm（若有） | MathIR 节点 `proofTerm` 输入值，回放时作为原始形式化候选保留 | 仅经 Lean 导出与独立 Kernel 检查后通过 |
| 系统补充或修复的 Lean proofTerm | proof-only patch，带节点 ID、来源阶段、被替换候选、statement hash、diagnostic hash 和结果的单独 provenance 记录 | 不能冒充原稿 proof；仍需同一锁定命题下的 Lean 与 Kernel 证书 |
| 背景定义 | 有类型的 `Declaration(kind="definition")`，按作用域编译为定义绑定 | 定义可作为上下文；它本身不是一条原稿推理步骤，除非原稿明确给出并使用了该等式作为 claim |
| 计算/等式变形 | 原稿明确写出的每行可编码为 `RouteNode(kind="claim")`；精确表达中间结果；`dependsOn` 只列原文真实使用的前置行 | 不能因为计算局部可证就自动连接到结论；每条路线边须有来源支持 |
| 旁注 | 保留原始 source slice；不创建 proof claim | 不参与证明闭包、不要求 proofTerm |
| 未采用尝试 | 保留原始 source slice 和未采用标记/ambiguity 说明；不创建 active claim | 不参加目标路线，不删除原文 |
| 替代路线 | 每条路线使用独立 `ProofRoute`，各自有 goal、节点和依赖图 | 一条完整路线不能替另一条路线补步骤；any-route 成功仍要求该路线完整通过 |

当前 MathIR v2 node schema 只有 `claim` 与 `local_assumption`，没有可独立表达旁注、弃用尝试的 typed route node。处理这些文本时，不得把它们伪装成 claim；当前只能保留于来源片段，并使其不进入 active route，或通过 ambiguity 标出待分类内容。以后若要让 UI 可分别展示这些角色，应先扩展来源片段分类契约；不能从文本位置或 Lean 可证性自动推断其角色。

结构化步骤缺少 proofTerm 时，proof-only provider 返回 `{nodeId, proofTerm}` patch 列表。该响应 schema 没有 statement、MathIR、dependencies 或 source mapping 字段。补丁执行前后同时比较固定 statement hash 和 proofTerm 置空后的结构 hash；已有输入 proofTerm 受保护，repair 仅能替换本次运行记录为 AI 生成的 proofTerm。应用补丁只写 `proofTerm`，并输出生成/修复 provenance。若缺证明、Lean 未能导出 proof、diagnostics 未解决或 Kernel 未认证，状态统一为 `incomplete`，另保留 `proofAttemptStatus` 和原始诊断。当前系统没有从失败证明推导“数学上为假”的反证结论。

针对本阶段重点结构：

- **多项式定义**属于背景 `Declaration`。不要为了让目标节点通过而复制定义成路线 claim，再强行引用定义节点。若原稿确实逐步使用了一个定义展开，才把实际等式变形作为 claim，并记录来源与依赖。
- **归纳证明**使用 `InductionCase` 连接 base、step 与 conclusion。归纳假设和 step condition 只在 step 的本地上下文中；proof-only 只能补 step 的 proofTerm，不能把 IH 迁移为外部 assumption、修改 `P(n)` 或更换归纳变量。
- **有限和计算**明确区分 Nat 索引范围与 summand 的数域（如 Rat）。每个原稿中的等式计算行都是具有精确表达式的 claim；省略的算术展开不能自动补成用户原步骤，除非作为独立 proofTerm 对该计算 claim 形式化，并留下来源关系。
