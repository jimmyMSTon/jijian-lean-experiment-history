# MathIR v2 工作流调用与数据契约图

检查基线：`3804bae`，当前工作树源码与 2026-10-11 保存的运行记录。本文区分当前 App 实际 API 路径与 v2 研究 workflow；两者目前没有接线关系。

## 当前产品入口与研究入口

```text
当前 App: POST /api/pipeline
  backend/api.py:pipeline
    → Services.pipeline
      → v1 Understanding.structure (文本/图片 → v1 MathIR)
      → v1 FormalizationService.formalize (MathIR → Lean code)
      → v1 VerificationService.verify (Lean/Kernel)
      → v1 workflow.run (repair)
      → optional image failure review (result is not applied to MathIR/proof)
      → FeedbackService.build

v2 研究入口 (未由 API/App 调用)
  MathIRV2 + ProofLock
    → compile_v2 / TypedMathIR / fixed theorem / route obligations
    → verify_v2 (Lean expected-type batch → proof-export batch → isolated Kernel audit)
    → MathlibRetriever.context
    → generate_missing_proofs (Flash proof-only patches)
    → verify_v2 (all original route nodes)
    → diagnostic_repair_payload
    → repair_generated_proofs (diagnostic-directed; deterministic no-goals cleanup first)
    → verify_v2 (whole original route again)
    → per-route completeness + fixed theorem Kernel result
```

已核对 [API route](../backend/api.py#L206)、[v1 service pipeline](../backend/services.py#L76) 与 [v2 workflow](../backend/v2/workflow.py#L60)。因此矩阵中的 v2 结果是研究引擎的验证证据，不表示当前正式 SwiftUI App 已经调用 MathIR v2。

## 阶段责任和数据边界

| 阶段 | 输入 → 输出 | 责任与可信边界 | 源码 |
|---|---|---|---|
| 原稿到结构 | `source.raw/blocks`、`sourceRefs`、declarations、assumptions、goal、proofRoutes、ambiguities → `MathIRV2` | SourceRef 范围可确定性校验；`sourceAssessment` 记录对齐判断，但它不是数学等价证明。保存原稿步骤，不替用户纠错。 | [models.py](../backend/v2/models.py#L193), [typecheck.py](../backend/v2/typecheck.py) |
| 结构到固定定理 | Typed MathIR → canonical Lean statement、statement hash、route obligations、dependency contexts | 确定性符号绑定和合法结构 lowering；Statement Lock 固定 theorem 与 MathIR structure。此处不是模型重写原稿的权限。 | [compiler.py](../backend/v2/compiler.py#L953), [proof_only.py](../backend/v2/proof_only.py#L79) |
| 预检与 Lean | `expectedType + proofTerm + sourceRefs + statement_hash` → elaboration diagnostics、proof export、Kernel certificate | `probe_statements` 批量 elaboration；`check_many` 批量处理候选，Lean Kernel 在隔离环境逐证据重放。仅 Lean/Kernel `checked` 且 `statementMatched` 才是 proof 证书。 | [verify.py](../backend/v2/verify.py#L121), [runner.py](../backend/lean/runner.py) |
| 目标路线组合 | route goal、dependsOn DAG、induction cases、local assumptions → `proofComposition`, route closure, dependency usage | 每条 route 独立产生结果；目标闭包外 claim、断边、循环假设、未用声明依赖均不因目标 theorem 可单独证明而通过。固定 theorem Kernel 与 `completeOriginalRouteKernelPassed` 是两个字段。 | [compiler.py](../backend/v2/compiler.py), [verify.py](../backend/v2/verify.py) |
| proof-only 生成 | 缺失 obligation、原稿步骤、局部 context、锁定 theorem、可用 Mathlib evidence → `{nodeId, proofTerm}` patches | 只能提交 proof terms。ProofLock 检查 statement/structure/provenance；原 MathIR 和依赖图不属于可修复范围。 | [proof_only.py](../backend/v2/proof_only.py#L359) |
| diagnostics repair | 真实 Lean diagnostics、Kernel dependency-use audit、failed obligations、source fragments、prior proof term → targeted patches | `declared_dependency_unused` 会带 unused IDs、数学命题、原稿来源和依赖审计；`dependency_usage_not_audited` 单独标记，不能伪称 unused 已证实。只允许修改当前 workflow 产生且来源可核验的 proof terms。 | [proof_only.py](../backend/v2/proof_only.py#L161), [proof_only.py](../backend/v2/proof_only.py#L379) |
| deterministic cleanup | `No goals to be solved`、扁平 by-block proof → 去掉唯一最终 tactic 的候选 | 只处理结构明确的末尾 tactic；候选也必须经 Lean、Kernel 与 dependency-use 检查，再完整验证 route。C08 实际自动走过此路径，新增 DeepSeek 请求为零。 | [proof_only.py](../backend/v2/proof_only.py#L384), [C08 evidence](mathir-v2-C08-current-diagnostics-cleanup-20261011.json) |
| 失败保全 | provider / retrieval / repair `AppError` + 当前验证历史 → `ProofWorkflowResult.failure`、events、latest verification | 已有证明检查先于模型生成；生成、Mathlib 检索、repair Provider 失败需返回已完成的 Lean/Kernel 证据。失败 event 的 provider 调用状态未知时用 `None`，request audit 才是实际 HTTP 请求数的权威来源。 | [workflow.py](../backend/v2/workflow.py#L60) |

## 重复处理审计

- **标识与作用域**：MathIR 的显式 `symbolId` / `binderId` 经 `canonicalize_symbol_references` 与 typecheck 规范化；Lean compiler 再把这些结构确定性编码为 Lean identifiers。Lean Elaborator 重新检查目标/term 类型是可信验证，不是另一套数学推断器。当前轻语义研究层只给来源片段建立绑定和类型约束，未接到正式路线。
- **上下文**：compiler 把 route dependencies、induction hypothesis / step condition 与 theorem binders 生成 obligations；verify 用同一 compiled routes 检查局部节点和最终组合。已暴露的阻塞集中于 C04 的 induction-step context 和 proof term rewrite 目标不匹配，而不是用固定命题证书遮盖。
- **Repair 覆盖面**：Lean 编译失败与 dependency-use failure 都能进入针对生成 proof 的诊断任务；缺 proof 则走 proof generation。未审计依赖是独立状态。用户原有、没有本 workflow provenance 的 proofTerm 默认不被 workflow 覆写。
- **批量与资源**：verify 对各 route 的 expected types 批量 probe，再批量调用 `check_many`；每项 proof wire 仍独立 Kernel replay。研究脚本串行执行，当前重放观测到的 Lean 并发为 1；wire 以内容哈希外置，JSON 结果保存引用与校验哈希。
- **来源语义**：`sourceRefs` 保持到步骤/诊断层级。Typed MathIR 的 Kernel 证书不证明中文原稿、手写文本与 statement 的语义同一。此项需要来源语义契约与可复核证据，不由 proof-only repair 修正。

## 现状与验收引用

完整 15 题字段、请求、token、墙钟和资源引用位于 [能力矩阵](mathir-v2-system-capability-matrix.json)。目前 13 份保存 MathIR 可编译，C06/C09 原始结构缺失；完整原路线 Kernel 有两条已通过：C01 与 C08。C03 的近期 proof-only 请求因 HTTP 402 没有返回 proof。C05、C10、C12 的本轮逐项 Lean 重放见 [saved proof replay](mathir-v2-stage10-saved-proof-kernel-replay-20261011.json)。

本文件没有改变 v1 App、API 产品行为、MathIR、Statement Lock、Mathlib A 或 Kernel 可信边界。
