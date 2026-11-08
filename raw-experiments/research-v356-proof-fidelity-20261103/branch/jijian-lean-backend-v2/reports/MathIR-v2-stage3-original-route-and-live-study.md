# MathIR v2 第三阶段：原路线忠实核验与真实 Flash 旁路

基线 `3a47b84`。本研究未接入正式 v1 API、Mac App、Mathlib A、Repair 或生产 Kernel 路径。五道文本样本各发送一次真实 DeepSeek `deepseek-flash` 请求；没有图片请求、自动重试或输出修订。经过 schema 校验的 MathIR、首次编译/Lean 结果和逐请求审计保存在 [完整机器报告](mathir-v2-stage3-live-matrix.json)。首次 AI pass 发生在本轮 `targetType` 严格校验与 proof composition 修复之前；机器报告也保存了相同 AI 输出经过当前确定性 compiler 的无网络重放结果。没有因代码修复追加模型请求。报告中的首次 Kernel 结论仍是实际执行结果；无网络重放 rejection 反映当前 compiler 状态。

## 路线误判反例与修复

原实现逐个 Kernel 检查 claim，再独立 Kernel 检查固定 theorem；只要求所有 claim 都通过，没有要求它们属于目标节点的证明依赖闭包。因此 `2=2` 和 `1=1` 两个互不关联的 `by rfl` 都通过时，目标 Kernel 通过会被合并成“原路线通过”。这只证明了固定命题，不证明用户路线完整。

现在输出把两件事分开：`fixedStatementKernelPassed` 只表示当前 proof term 对锁定 theorem 的 Kernel 结果；`anyRouteKernelPassed` / `completeOriginalRouteKernelPassed` 还要求路线目标存在、每个 claim 位于目标的依赖闭包内、所有步骤通过，并且每条显式 claim dependency 在 Kernel proof expression 中被实际引用。induction base/step 通过显式 induction-case 关系纳入闭包。证明步骤和各自 Kernel 证书仍完整保留；无关 claim 会列在 `unconnectedClaimNodeIds`，不会被删除。

一般 claim dependency 现在编译为带稳定名字的显式 Lean `∀ (jjdep_<id> : premise), conclusion`。隔离审计器在独立数据式 Kernel replay 时分析 proof expression 对该前提 binder 的实际引用，并写入 `dependencyUsage`。没有拿到可审计 proof term 的步骤会标记 `dependency_usage_not_audited`；未使用的显式依赖不会被视为完整原路线。

本机 Lean/Kernel 对照实测：

| 对照 | 固定命题 Kernel | 步骤与路线 | 结论 |
|---|---|---|---|
| 独立步骤 `2=2` 与目标 `1=1`，两者均 `by rfl` 且无边 | 固定 `1=1` Kernel 通过 | 两个步骤保留且通过；`unrelated` 不在目标依赖闭包 | `fixedStatementKernelPassed=true`，路线 `incomplete`，`anyRouteKernelPassed=false` |
| 中间步骤 `2=2`，目标声称依赖它但 proof 为 `by intro h; rfl` | 条件 obligation Kernel 通过 | Kernel 表达式显示 `intermediate` binder 未使用 | `declared_dependency_unused`，路线不通过 |
| 中间步骤 `1=1`，目标 `1=1` 以 `by intro h; exact h` 使用前置证明 | 固定 theorem 合成 proof 通过 Kernel | 目标步骤实际使用命名依赖 binder；合成路线保留两步 | `completeOriginalRouteKernelPassed=true` |
| 中间步骤 `2=2`，目标 `1=2` 以 `by intro h; exact h` 声称从它推出 | 固定目标与条件 obligation 都未通过 | `exact h` 的类型是 `2=2`，不能证明 `1=2` | 错误推导关系失败；无目标 Kernel 证书 |
| 既有双路线：一条 `by assumption` 失败，一条 `by rfl` 成功 | 正确路线固定命题 Kernel 通过 | 两条路线与各自状态都保留 | Any-route 只因完整正确路线而通过 |

第二阶段矩阵还覆盖错误定理、从 1 开始的归纳和有理数有限和；新增审计字段不改变独立 Kernel 的信任边界。归纳结构的 IH 和条件仍作为局部步进上下文，而不是全局 theorem assumption。已有 induction-step proof 上下文会报告 `local_context_kernel_checked`；当前使用 binder 分析器对普通 claim 依赖进行逐项使用审计，归纳 IH/条件各自的使用详情尚未细化到相同字段。

## 五次真实 DeepSeek → MathIR v2 结果

| 样本 | MathIR/statement 首次结果 | 原步骤 Lean | 固定命题 Kernel | 原路线 Kernel | 同类 v1 历史记录 |
|---|---|---|---|---|---|
| 正确等式 `a=b ⟹ a+1=b+1` | `V2_UNKNOWN_SYMBOL`：声明 ID 为 `d_a/d_b`，公式却引用 `a/b`；未生成 statement | 未运行 | 未运行 | 未运行 | [V1 错误证明闭环](真实错误证明与修改闭环V1-2026-10-10.md) 的用户修改后同结论由真实 Kernel 通过；属于历史类比，不是同条件重放 |
| 错误结论 `a=b ⟹ a+1=b+2` | 同样先因 symbol ID 不一致被拒；因此本次没有把无效 MathIR 声称为 Lean 证伪 | 未运行 | 未运行 | 未运行 | V1 同一错误目标首次 `missing_proof`，最终 `kernelVerified=false`；见上列历史报告。两版都没有证明该命题为假 |
| 从 1 开始的自然数归纳 | `V2_INDUCTION_STEP`：所给 step AST 与 `P(k) → P(k+1)`/下界条件不一致；结论 binder 使用 `n`、归纳结构使用 `k` | 未运行 | 未运行 | 未运行 | [V1 归纳实测](statement-lock-three/DeepSeekFlash三题结构锁与Lean能力报告.md) 是奇数求和、从 0 起步，与本题不等价；报告为历史能力旁证 |
| `ℚ` 上 `∑ k∈[1,2], (1/2)^k=3/4` | 首轮编译曾忽略非 cast 节点的 `targetType`，把分数 literal `Nat` 锁为 ℕ；编译输出明确是自然数除法 statement。该次原始 DeepSeek MathIR 虽有 `targetType: Rat` 注记，literal 自身仍标成 `Nat` | 计算片段 `1/2+1/4=3/4` 的自然数版本通过；总和节点缺 proof | 未通过；没有完整目标 proof/证书 | 不通过 | [V2 第二阶段](../docs/MathIR-v2-stage2.md) 的人工确认 MathIR 使用真实 `ℚ` literal 和显式 proof，本地 Lean/Kernel 通过；不是同一次 AI 转换 |
| 相依定义 `P(x)=x²+1`, `Q(x)=P(x)+1`, 证明 `Q(0)=2` | 首轮确定性拒绝 `Polynomial` 上的 `pow`。修复该类型支持后，回看保存的 AI 输出又发现其在 `poly_x` 上设置了 schema 不允许的 `targetType`；原文的常数多项式嵌入也没有明确 AST 表达 | 首轮没有进入 Lean | 未运行 | 未运行 | [MathIR 通用化与原文忠实性研究](MathIR通用化与原文忠实性研究-2026-10-10.md) 有旧多项式绑定失败样本，不是该输入的 v1 同条件对照 |

本轮没有一个 AI 样本形成“MathIR忠实 → 固定 statement → 所有原步骤 → 完整目标 Kernel”的成功闭环。只有有限和样本的一个独立计算片段通过；它使用了错误数域，不能算正确题目成功。`sourceAssessment=supported` 和 `assessmentBasis` 是模型生成的自述，不是来源语义已被验证的证据。五份记录的原文文本和节点引用可复查；这不能证明来源语义等价。

## 请求、Token 与耗时

- 真实 API 请求：**5**（每题 1 次，stage `mathir`）；缓存均 miss，`retry_index=0`。审计文件会为每请求写 started/finished 两行，报告已按 request_id 折叠为 5 个真实 HTTP 请求。
- 模型：请求与响应均为 `deepseek-flash`，thinking=`provider_default`。没有上传图片。
- Provider usage：输入 **18,484 tokens**，输出 **58,830 tokens**，总计 **77,314 tokens**。输出 usage 包含供应商计费的 reasoning tokens；未保存私有 reasoning 正文。
- HTTP 总时间 **232.353 秒**；五个 case 端到端时间合计 **273.496 秒**，包括确定性编译及本地 Lean 检查。单题耗时和 token 可在机器报告逐行核对。
- 实验实际执行了 1 个真实 API 请求/样本；没有对失败输入追加请求、修复 prompt 或自动清理/改写模型 MathIR。

## 确定性修复与契约决策

已实施的确定性工程修复：

1. claim 路线必须覆盖目标依赖闭包；无关/断裂 claim 保留并让原路线保持 incomplete。
2. 一般 claim dependencies 以命名 Lean premise 表示，并从 Kernel proof expression 检查 premise 是否实际使用。
3. 独立提供固定 theorem Kernel 结果，避免固定命题成功覆盖路线失败。
4. `targetType` 只接受 `cast` 节点；此前对 div/literal 等节点上的 `targetType` 静默忽略，会把明确写成 ℚ 的 MathIR 降成 ℕ 除法。
5. `pow` 的指数为 Nat 时允许多项式底数，并让 renderer 在多项式语境中推导 `Polynomial.X` 的类型。一个真实本机 Mathlib 编译回归覆盖 `P=X²` 的定义与求值。

仍需契约决策、没有自动推断：

1. 表示常数多项式（例如 `X² + 1` 中的实数 `1`）需要显式、类型安全的 `Polynomial.C`/多项式常量表达；当前 AST 没有该节点。不能把任意 `Real` literal 自动提升成 `Polynomial ℝ`。
2. symbol ID 是 MathIR 节点身份，不是显示名称。模型的 `symbolId="a"` 对应声明 `id="d_a"` 时，系统拒绝猜测二者相同；需要确定性 ID 约定或显式 name-to-id mapping 契约。
3. lower-bound induction 必须准确绑定被量化的变量、step binder、IH、前提和结论。不能因为数学上熟悉而将模型输出里的 `n/k` 不一致自动改写。
4. 当前 route DAG 表达单一证明路线。独立 claim 不会自动降级删除；如果用户原稿确实含无关旁注或多种方法，应在输入映射中作为旁注/独立 route 表达，具体分类契约需确认。
5. sourceAssessment 的模型自我标注不能证明中文、公式和 AST 等价。生产 UI/验收仍需保留 `not_assessed` 与原文映射；Kernel 只对固定 statement 负责。

建议：继续把 v2 保持为隔离旁路；先确认多项式常量表达、名称身份绑定和旁注/多路线结构契约，再让样本完整通过同一真实链。现阶段不应让 DeepSeek 自动输出的 v2 MathIR 替换正式 v1 MathIR，也不应把“固定 theorem 可证”显示成“原推导已验证”。

## 实际验证范围

- `lake build Jijian.Audit`：Lean 4.34.0 本机构建通过。
- `pytest tests/v2 -m 'not lean_local'`：20 passed，3 deselected。
- 新路线忠实边界测试：本机隔离 Lean/Kernel 实测通过，1 passed；包含不连通步骤和未使用 dependency。
- 最新组合器版本的路线边界测试：本机隔离 Lean/Kernel 实测通过，1 passed in 517.98s；包含不连通 claim、Kernel 证明了结论但未使用依赖、实际使用前置证明的有效组合、以及错误依赖推导。第一种与第二种都能证明固定 `1=1`，但 `completeOriginalRouteKernelPassed=false`；有效链合成后通过 Kernel；错误推导被 Lean 拒绝。
- 编译含 `P : Polynomial ℝ := X^2` 的固定 statement：本机 Mathlib 编译通过，1 passed。
- 大矩阵中的五次真实 DeepSeek 输出与机器记录均为原始单次结果；没有把 mock、历史 v1 证据或局部 Lean 通过称为完整链成功。
- 本轮未重跑全库 pytest，也未重建 Mac App；所有生产 v1 文件和已安装 App 均未改动。
