<!-- Source: local experiment archive; paths and email addresses sanitized -->

# MathIR v2 Stage 9：统一上下文与原路线 Kernel 回放

> 本文件是早期 Stage 9 上下文回放快照。后续编译器修复、C04 proof-only/repair、C05/C10/C12 Lean 复核以 [Stage 9 自动 repair 结果](mathir-v2-stage9-automatic-repair-results.md)及其机器证据为准；出现差异时使用后者。

基线 `3804bae`。本轮只读取已保存的 Stage 7/8 MathIR 与 proof-only 响应；没有重新生成 MathIR，也没有调用 DeepSeek。正式 v1 App、Mathlib 检索、Repair 与 Kernel 可信边界均未修改。

## 结果

编译器现在用 `ScopeContext` 表示固定定理作用域与路线节点的局部作用域。定理闭合、节点上下文、obligation、依赖实例化和路线组合从同一组声明与假设中取值。固定定理作用域之外的局部声明不会被提升为定理参数；局部声明仍不能由组合器假装消失。

C01 原先把 `s_theorem` 下的 `a,b,c` 当成额外局部声明，导致路线组合器拒绝。修复后九个已保存 proof term 均通过实际 Lean 检查，组合出的固定命题通过独立数据式 Kernel 复核，statement hash 仍是 `1216b193…eacea3a3c`。原路线仍为 **false**：依赖使用审计发现 `n_step4_intermediate` 未使用 `n_step3a/n_step3b`，`n_final` 未使用 `n_pos2`。保留这些未使用边并判路线不完整是正确结果；独立定理证书不冒充原推导通过。

C08 的依赖类型问题已能由合法 Lean 应用衔接。上游 `∀ k, P` 只在 `k` 与目标无关、且没有额外约束时，以显式 `(0 : ℕ)` 实例化；Lean/Kernel 负责检查这个应用。若目标自由依赖该变量，或变量有未处理约束，组合器会拒绝合成。重放后 n2–n5 均通过，依赖使用审计完成；固定命题仍未通过，首个失败在 n1：保存的 proof term 触发 Lean `No goals to be solved`。所以 C08 的修复消除了依赖衔接阻塞，但没有把整题判成成功。

## 样本核验矩阵

| 样本 | 原稿与锁定命题 | 固定命题 Kernel | 原路线 Kernel | 首个已知阻塞 |
|---|---|---|---|---|
| C01 不等式 | sourceRef 有效，statement hash 与 Stage 8 相同 | **通过**（本轮真实独立 Kernel） | **未通过** | 已声明依赖未被 proof expression 全部使用 |
| C04 参数归纳有限和 | 保存结构保留 `m,n,k` 身份；路线仍是结构归纳 | 本轮未重跑 Lean | 未验证 | 已有 MathIR 把 `S_n` 存为依赖外层 `m,n` 的定义，同时目标再次量化同 ID；当前锁定语句保留此结构，不在本轮简化 |
| C05 错误归纳 | `n+m` 新增项原样保留；分层解析也恢复为 `n+m`，未改写为 `n+1+m` | **未通过**（Stage 8 真实回放） | **未通过** | `base_conclusion`、`step3` proof 缺失/未证明；错误项没有被修正 |
| C07 立方和归纳 | `n,k,T_n` 的声明 ID 与量词/求和 binder ID 可追溯；定义与目标哈希保留 | 本轮未重跑 Lean | 未验证 | `T_n` 定义的外层上下文与目标量词重复；该保存结构没有被本轮重写 |
| C08 有理数有限和 | 锁定 statement hash 与 Stage 8 相同 | **未通过** | **未通过** | 首个错误是保存的 n1 tactic 多执行一步，Lean 报 `No goals to be solved`；n2–n5 均通过 |
| C10 多项式双路线 | `Q=P(X)(X−1)` 定义、错误路线与正确路线分开保留 | **未通过**（Stage 8） | **未通过** | 两路线 proof 均不完整；路线 B 没有借用路线 A 通过 |
| C12 量词样本 | `∃ M, ∀ x, x<M` 顺序与两个 binder ID 保留 | **未通过**（Stage 8） | **未通过** | proof term 缺失或未能 elaboration |
| C13 循环论证 | 原循环假设仍是无 proof 的 local assumption | **未通过**（本地真实回放） | **未通过** | 假设目标本身不能作为已证前提；路线状态 incomplete |
| C14 整除证明 | theorem scope 与 `s_step` 局部声明分开 | 未证明 | **未通过/拒绝组合** | 路线节点确实可见 `d_k3a…d_k2c` 局部变量；组合器明确返回 unsupported，没有把它们提升成定理假设 |

Stage 7 保存集共 15 个编号：13 份可编译；C06/C09 没有可恢复 MathIR。C03 的旧内存事件缺少原始 proof 证据。本轮依照要求未追查缺失文件，也未重试同样的 MathIR。C05/C10/C12/C13/C14 的状态来自已有的真实 Lean/Kernel 记录；C01/C08 是本轮重新执行的 Lean/Kernel 回放。

## 量词与局部绑定审计

[stage9-scope-binding-audit.json](mathir-v2-stage9-scope-binding-audit.json) 记录了 C04、C07、C14 的保存 source 对应、statement hash、声明 ID、量词 binder ID 与每个路线节点可见的局部声明。C04/C07 的 `forall` 和 `finite_sum` 都引用其 MathIR 声明 ID；C14 的六个局部变量仍只出现在归纳路线作用域，不能成为 theorem-level 变量。

C04/C07 仍暴露一个表示层契约问题：求和定义 `S_n/T_n` 被存成依赖外层参数的 let，而证明目标又包含同 ID 的量词。当前编译忠实保留并锁定这份结构，没有擅自去掉冗余量词或搬动定义。若要消除这种重复，需要结构来源明确区分“带参数的函数定义”与“在目标内绑定的值”；在没有这项来源证据前，改写会改变 Statement Lock，故这里只作为明确的契约待定项。

## 分层语义表示研究

[semantic-roundtrip.json](mathir-v2-stage8-semantic-roundtrip.json) 是隔离研究模块：对 C05 的错误项、C10 的 Q 定义和 C12 的量词片段，从原文构造轻量语义 AST，再通过确定性绑定/类型约束降为现有 Typed MathIR。三例都与保存的 MathIR 子树结构相等，均成功编译，并保留了原稿中的错误或量词顺序。运行时间约 0.078 秒，Python 峰值约 2.07 MB，token 数为 0，Lean 次数为 0，Provider 调用为 0。

这证明分层表示可作为确定性来源解析实验，但没有证据表明它提高了 proof-only 能力或 Kernel 成功率。它与直接 Typed MathIR 使用同一输入证据，不是模型 A/B；本轮不建议替换现有 v2，也不接入正式 App。当前失败主要落在 proof-only 片段本身、原路线声明依赖未使用，以及 C04/C07 定义绑定表达契约；把翻译再分层不能代替这些证据。

## 请求与资源证据

本轮 DeepSeek 请求 **0**。复用的 Stage 8 历史记录中，C01/C05/C08/C10/C12 共 9 次真实请求、合计 198,317 input+output tokens；这是历史基线，不计入本轮。各样本分别为 1、2、2、2、2 次。C13/C14 回放与本轮审计均为本地执行。

保存 proof 回放工具仅从文件读取已记录的 `finalMathIR`；缺文件、JSON 格式错误或 MathIR/schema 缺字段时记录 `input_contract_error` 并跳过 Lean。该路径不构造 Provider，也不能触发 DeepSeek 请求。

C01 使用串行 Lean（并行度 1），21 个 Lean 阶段/子进程，358.7 秒；proof wire 完整保存在 SHA 内容寻址压缩证据文件中，90,516,804 字节未压缩、911,965 字节压缩。测得进程峰值约 1.90 GiB。C08 同样串行，11 个阶段/子进程，180.064 秒，Lean 进程峰值约 0.90 GiB。没有并发重型 proof 任务。C01 的高峰说明大型独立证书回放仍昂贵；当前外置 wire 后可完成且证据可恢复，但不应把它描述为轻量任务。

## 验证状态

- `pytest tests/v2/test_mathir_v2.py -q`：37 passed。
- 保存 MathIR 编译/source fidelity 审计：13 compiled，2 unavailable；C05 错误项、C10 定义/路线隔离、C12 存在量词顺序、C13 循环假设检查均通过。
- 分层语义 roundtrip：3/3 AST 相等、类型约束成立并成功编译。
- 本轮真实 Lean/Kernel：C01 固定命题通过、路线不通过；C08 固定命题及路线均不通过，已定位到 n1 proof。
- 所有真实 API 调用均来自此前保存的 Stage 8 记录；本轮无 API 请求。
