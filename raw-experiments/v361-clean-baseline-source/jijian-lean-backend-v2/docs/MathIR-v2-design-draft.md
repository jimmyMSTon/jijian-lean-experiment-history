# MathIR v2 设计草案：类型、来源忠实性与证明路线

状态：研究草案，未批准实现。本文不修改 MathIR 1.0、API、Lean 编译器或验证状态。

## 设计目标与边界

MathIR v2 要解决的共同问题是：目前源文、变量/定义、公式 AST、局部作用域和证明步骤分别记录，缺少可核查的跨层绑定。目标是让数学对象有明确类型和来源，公式结构可确定性编译，局部归纳假设有真实作用域，多种原文方法可以各自验证。

v2 不声称把任意中文/手写内容自动证明为语义等价 Lean。AI 负责提出结构化解释；来源证据记录支持、冲突、歧义和未覆盖；代码负责校验树结构/类型/绑定并生成 Lean；Lean 和独立 Kernel 仍只对固定 statement 与 proof object 负责。来源对照状态不替代也不改变 Kernel 结果。

必须保持的现有不变量：proof-only 模型不能修改 statement；Mathlib Retriever 保留方案 A；Lean diagnostics 驱动 batch repair；每步验证和独立 Kernel 复核不变；原文错误和用户路线不能为了过关而改写。

## 目标数据层

### Source Evidence

保存输入版本和识别版本：`sourceId`、`raw`、`normalized`、`blocks`、页/bbox、用户修订和视觉 ambiguity。每个声明、条件、目标、步骤或定义附 evidence refs。每个 ref 记录 block 与 Unicode codepoint 范围；图像 ref 可附 block/bbox，但若位置精度只有 step/block，就不得降格声称字符级定位。

每项来源比较记录方法和结论：

| 状态 | 含义 |
|---|---|
| `supported` | 人或确定性规则确认所引原文支持该读法；记录核查依据 |
| `contradicted` | 已有证据与该读法冲突；保留冲突双方 |
| `ambiguous` | 原文支持多个候选或识别候选未决 |
| `uncovered` | 找不到覆盖该数学内容的来源 ref |
| `not_assessed` | 没有进行语义核查；不得按成功解释 |

source span 的合法性和覆盖率属于确定性位置检查。它们本身不能被标为 `supported`，也不能证明 AST 与原文等价。

### Typed declarations 与表达式

声明按稳定 ID 标识，分开表达对象的基础类型、域约束、定义、scope 和来源。类型用封闭的 type expression，而非从名称/自由字符串猜测：基础标量、集合/多项式应用、函数、积和必要的 subtype。Mathlib 常见类型由 compiler 的显式 lowering 表映射；任意 Lean 类型文本不作为用户模型的可执行语法。

概念示例（字段名可再议，不是定稿 JSON Schema）：

```json
{
  "declarations": [
    {"id":"n", "kind":"variable", "type":{"kind":"Nat"},
     "constraints":[{"op":"gt", "left":{"symbol":"n"},
                      "right":{"literal":{"type":"Nat","value":"0"}}}],
     "scopeId":"root", "sourceRefs":[{"blockId":"b0","start":8,"end":28}]},
    {"id":"theta", "kind":"variable", "type":{"kind":"Real"},
     "scopeId":"root", "sourceRefs":[{"blockId":"b0","start":40,"end":45}],
     "typeEvidence":"source_supported"},
    {"id":"P", "kind":"variable", "type":{"kind":"Polynomial","coefficient":{"kind":"Real"}},
     "scopeId":"goal", "sourceRefs":[{"blockId":"b0","start":50,"end":55}]}
  ]
}
```

若原文只给出 `n∈N*`，建议语义层保留 `Nat` 加 `0<n` 约束；canonical compiler 可生成 `∀ n : ℕ, 0 < n → ...`。若 θ 域或多项式系数域未由题面/可靠来源确定，则保留未决证据，不能通过“常见数学约定”静默补上。

表达式节点必须有确定类型规则。纯数字值须可指定类型；有理数 `1/2` 不能在未知类型时默认为 Nat。概念 literal 例如：

```json
{"op":"rational", "numerator":"1", "denominator":"2", "type":{"kind":"Rat"}}
```

在不改 schema 的研究账本中可以展示“未定类型”，但不能偷偷改变当前 `expression_type`。类型缺信息时，结构化结果可被记录为未决；何时向 API/App 暴露这类草稿状态需批准。

### 求和、定义和绑定

建议有限和直接保存范围端点和端点语义，不要求模型自行平移索引：

```json
{"op":"finiteSum", "index":"k", "lower":{"literal":{"type":"Nat","value":"1"}},
 "upper":{"symbol":"n"}, "upperInclusive":true,
 "body":{"op":"div", "numerator":{"literal":{"type":"Rat","value":"1/1"}},
         "denominator":{"op":"pow", "base":{"literal":{"type":"Nat","value":"2"}},
                         "exponent":{"symbol":"k"}}}}
```

上面 `1/1` 仅用于说明值类型，几何级数的 `2^{-k}` 项仍需经正确的 Rat coercion/幂规则表达，不能直接把 Nat 幂的结果当成 Rat。

Definitions 需声明参数、对象类型、值表达式和 scope。例如 `P : Polynomial ℝ` 是对象；`x : ℝ` 是求值变量；`Polynomial.eval (cos θ) P` 是求值式。若定义 `P(x)=...`，其参数关系和 value tree 必须绑定到 P，不将展示名 `x` 误放成额外 theorem binder。整系数多项式与实系数多项式属于不同类型，映射环同态必须是显式表达式/声明，而不是 provider note。

### Statement AST

Statement 包含目标与正式题设，量词 binder 和 scope 显式表示。域约束必须在语义 AST 可见；禁止把 proof 内引理或“平方非负”等证明事实提升为全局题设。每个 statement node 可以关联原文来源，但来源 metadata 不进入 Lean term。

Compiler 从声明和 statement AST 生成 `FormalTypes`、Binder Map、canonical Lean statement。模型返回的类型/定理字符串只能作为诊断参考，不能覆盖 compiler 的输出。

## Proof Route 与归纳

证明路线是与 statement 分开的有向图。原稿的“法一”“法二”分别保留为 route；route 内节点有稳定 ID、来源、dependsOn 和作用域。局部 IH 属于 case scope，只能在对应 step 使用。一个 route 通过不删除其他失败 route。

归纳 case 必须能表达不同起点/原则，而非固定 P(0)：

```json
{
  "kind":"induction",
  "principle":{"kind":"NatLowerBoundInduction"},
  "variableId":"n",
  "lowerBound":{"literal":{"type":"Nat","value":"1"}},
  "predicate":{"...":"P(n)"},
  "baseCaseId":"base_n1",
  "hypothesisId":"ih_at_k",
  "stepPremise":{"...":"1 ≤ k"},
  "stepCaseId":"case_k_plus_1",
  "conclusionId":"forall_positive_n"
}
```

Compiler 应验证 IH `P(k)` 与 step conclusion `P(k+1)` 的变量 substitution、step 条件、base 起点和最终量词/域条件对应；再由已选 principle 生成 Lean induction proof obligation。`Nat.rec`、lower-bound induction、strong induction、well-founded induction 和结构归纳不可互相冒充。旧 MathIR 1.0 的简单归纳映射仅可作兼容映射，不能让旧字符串启发式生成 v2 induction node。

## 锁定、哈希与 Kernel 边界

v2 仍使用固定 statement、Binder Map、Lean diagnostics、stepwise verification 与 independent Kernel。建议将身份拆开以便审计：

- `sourceEvidenceHash`：原始输入、转录与来源证据版本。
- `statementHash`：canonical typed statement、binder/type 和题设的稳定哈希。
- `proofRouteHash`：一个 route 的节点、依赖、case schema 与源映射。

route 修改不改变 theorem `statementHash`；原文/转录来源修改更新 evidence hash；变量类型、前提、定义、量词或目标改变必须重建 statement hash 并产生新的验证记录。所有 Lean theorem declaration 仍需与 statement lock 结构比较；proof response 不得重写 theorem 或添加 premise。Kernel 的结果依然只表明 proof object 证明已锁定 statement。

当前 v1 statement hash 还包含 scopes/表达式/induction 结构。v2 哈希拆分是新版本规则，不能重新计算或覆盖既有已存 hash/certificate。

## 路线结果与 API 决策

建议 API 单独提供结构校验、statement lock 和来源证据状态；不要让 HTTP 200/job completed 代替证明通过，也不要把未评估的来源忠实性映射成 success。建议状态名可分为：

- `mathIRStructuralStatus`：字段、ID、scope、ref 范围、dependency 结构校验。
- `statementLockStatus`：canonical typed statement 是否已生成且锁定。
- `sourceAlignmentStatus`：独立证据账本结论；可为 `not_assessed`。
- `routeVerifications[]`：每个原路线的 Lean/Kernel/步骤结果。

这些字段的存在与含义需要 API 兼容评审。保留 `/api/structure` 当前行为，不因本草案自动增加 draft-success 返回，也不增加新 Gate。

多 route 的 theorem-level 展示存在两个合理但不等价选择：

1. **Any-route**：至少一条完整的用户原文 route Kernel 通过，则 theorem 已有一份经验证的原证明；其他路线状态仍单独显示。
2. **All-routes**：所有用户提交路线都必须通过，才显示整体通过。

从数学命题是否有证明看，any-route 更自然；从评估用户所有方法的目标看，all-routes 才满足要求。产品必须选择，不能由 compiler 静默决定。两者都不允许用 AI 新路线替代原路线。

## 兼容和升级

- v1 API 和 MathIR 1.0 schema 保持不变。
- 历史记录有原文与已锁定 statement/proof/certificate 时，按历史值只读呈现；未 typed 的旧 MathIR 标为 `legacy_untyped`，不能反推并声称已获得 v2 statement。
- 如用户之后显式重结构化旧源，创建新版本记录，保留原始 source ID 和 lineage (`derivedFrom`/`supersedes`)，新记录必须独立锁定、Lean 编译和 Kernel 验证。
- 并行开发期可做 shadow comparison：v1 与 v2 输出并列研究，v2 结果不影响生产通过状态，待差异矩阵评估后再切换 API/客户端。
- fixture 分层：原始 source fixture、MathIR 结构 fixture、canonical statement fixture、route/proof fixture、Kernel certificate fixture。每条测试声明其 evidence 层级，不可由下游通过补写上游结论。

## 验收矩阵与优先级

| 顺序 | 变更/研究 | 验收样例 | 通过证据 |
|---|---|---|---|
| P0 | 已有只读 source ledger | 不等式、三角手写、双方法归纳、geometry sum | ref 越界/覆盖/ambiguity/typed AST 缺失都可单独报告；不改 verification |
| P1 | typed declaration/domain/literal/range sum | 正整数、Rat/Real 分数、实角、实系数/整系数多项式 | 生成的 statement 与声明的类型/域一致；`1/2` 不会隐式变成 Nat |
| P1 | proof route/case model | 法一/法二、P(0) 归纳、从 P(1) 起的正整数归纳 | IH scope、base、step、依赖被编译为精确 obligations；路线独立验证 |
| P2 | source↔statement 证据工具 | 错误前提、漏因子、未决 Δ/系数域、用户修订 | 语义未评估时保持 `not_assessed`，不会因 Lean 通过显示源文已验证 |
| P3 | v1/v2 迁移与 UI/API | 旧未 typed fixture 与新版本 | 旧锁/证书不变，新版本独立 hash；旧客户端/API 兼容行为经确认 |

每个层级都须覆盖：原文/转录、MathIR、固定 Lean statement、原 proof steps、Kernel 五种状态。错误证明、正确证明和源文不确定样本必须同时保留；模型调用只用于明确的能力实验，不进入常规 fixture 验收。

## 必须确认后才进入实现的事项

1. positive integer 采用 Nat + positivity constraint，还是 subtype 优先。
2. 未写明的 θ 域和多项式系数域怎样呈现未决含义，以及是否允许用户确认后生成 typed statement。
3. 任意多证明路线的 theorem-level 成功用 any-route 还是 all-routes。
4. MathIR v2 使用新 endpoint/schema version，还是对现有 endpoint 做协商版本。
5. 对 v1 未 typed 历史记录仅只读，还是提供显式重新结构化并新建 lineage 记录。

确认前不改正式 API、MathIR schema、statement hash、Compiler、验证状态或客户端成功语义。
