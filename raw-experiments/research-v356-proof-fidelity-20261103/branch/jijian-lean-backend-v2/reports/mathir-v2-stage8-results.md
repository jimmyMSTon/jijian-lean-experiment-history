# MathIR v2 Stage 8：已编译结构到原路线 Kernel 的证据报告

基线 `3804bae`。本轮复用保存的 MathIR；C01、C05、C08、C10、C12 使用 DeepSeek Flash proof-only，MathIR 不重建；C13、C14 从已保存 proof 输出做本地 Lean/独立 Kernel 重放。未修改正式 v1 App、Mathlib A、Statement Lock、DeepSeek Provider 或 Kernel 可信边界。

逐请求无密钥审计见 [request ledger](mathir-v2-stage8-request-ledger.json)，题目结构和验证结果见 [machine-readable evidence](mathir-v2-stage8-evidence.json)。审计含 request/workflow ID、stage/reason、hash、prompt version、模型、retry、cache 状态及可用的 token 数；没有提示正文或密钥。

## 结构忠实性

13 份可用的保存结构均重新确定性编译，原始/规范化来源文本匹配，所有 SourceRef 均在来源区间内；C06、C09 仍不可用，本轮未追查也未重新请求。检查未运行 Lean 或 Provider。C05 的错误项 `n+m` 原样保留；C10 的 `Q(X)=P(X)(X−1)` 定义与 `route_A` / `route_B` 两条不相交路线保留，错误路线的 `+(X−2)` 保留；C12 仍为 `∃ M, ∀ x, x<M`；C13 的局部假设仍与目标同式且无 proof，不会被单步可证的其他节点冒充完整路线。六项专门断言全部通过，见 [fidelity audit](mathir-v2-stage8-fidelity-audit.json)。

## 逐题证明结果

| 题目 | 首次/最终阻塞 | 固定命题 Kernel | 原路线 Kernel | 实际证据 |
|---|---|---:|---:|---|
| C01 正确多步实数不等式 | 9 个源步骤都分别得到 Lean/Kernel 局部证书；组装阶段返回 `Claim composition with local declarations is not implemented` | 否 | 否 | Flash 1 次；无 repair。证明片段成立，但当前路线组合器不支持这些局部声明。 |
| C05 参数归纳错误稿 | `base_conclusion` 缺 proof；`step4_conclusion` 诊断含 `assumption failed … ⊢ False` / 引入 binder 失败；错误的 `step3`（新增项 `n+m`）仍无 proof | 否 | 否 | Flash proof-only + 1 次基于新 Lean diagnostics 的 repair；`base_calc_1`、`base_calc_2`、`step4` 局部通过。原错误未修正，整条路线不通过。 |
| C08 有理数有限和 | 首次失败在 `n1` 的依赖应用：生成的 `n2` 类型为 `∀ d_k, ...`，调用处却期待非全称合取；repair 后 `n1`、`n5` 仍未通过 | 否 | 否 | 两次有 token 的请求（proof-only、repair）；`n2`、`n3`、`n4` 局部通过。 |
| C10 多项式双路线 | `route_A` 从 `nA1` 开始多个步骤反复 `dsimp made no progress`；`route_B` 的 `nB1` 同样失败，错误 `nB2` 没有 proof | 否 | 否 | proof-only + 1 次 diagnostics repair。两条路线独立保留，未用 A 路线结果替 B 路线背书。 |
| C12 量词次序错误命题 | `n3` 为 `statement_not_elaborated`，`n2` / `n6` 缺 proof；原稿逐点取 `M=x+1` 不能证明固定的存在常量 M、再对所有 x 的命题 | 否 | 否 | proof-only + 1 次 diagnostics repair；无量词交换或自动补前提。 |
| C13 循环论证真命题 | 固定命题的已保存 proof 未形成完整证书；循环假设节点没有原始 proof。`n_step2_subtract`、`n_step3_expand`、`n_step3_ineq`、`n_step4_conclude` 局部通过 | 否 | 否 | 本地重放；0 次 Provider。不得把四个独立通过片段当作原路线成立。 |
| C14 整除见证 | `c_factor` / `c_divisible_6` 使用的 `Nat.Coprime.mul_dvd` 是 Unknown constant，目标节点缺 proof | 否 | 否 | 本地重放；0 次 Provider。`c_base`、`c_three_consecutive`、`c_even`、`c_final_step` 局部通过。 |

本轮 **没有任何一道题完成固定 theorem 的 Kernel 证明，也没有完整原路线通过**。C01 最清楚地表明：proof-only 可以给每步生成并由 Kernel 单独验真的证书，但路线组合层仍是确定性阻塞。C05、C08、C10、C12 的首要问题发生在 proof-only 产物与固定 statement / 依赖类型对齐处；额外的 AI repair 没有消除这些问题。C13、C14 的阻塞则由已保存 Lean/proof 证据直接支持，无需新模型请求。

## 请求、耗时和资源

本轮共审计到 11 个真实请求尝试：10 个返回了 token usage，1 个 C08 中断流程中的 formalization 尝试结束时没有 token usage。按 stage：MathIR 1、formalization 6、repair 4；已知合计输入 51,378 tokens、输出 176,682 tokens。11 个尝试的 `retry_index` 全为 0、cache 全为 miss；审计没有显示 SDK/工作流 retry。C01/C05/C08/C10/C12 的 proof-only 与 repair 总墙钟时间约 16 分 41 秒，不含一次中断的 C08 额外 90 秒结构请求。完整逐请求账本保留每个 input hash；账本中没有完全相同的 hash 对。

需明确记录一项执行失误：C08 的第一次续跑文件包装格式不符合 runner 期待，造成已有 Stage 7 MathIR 仍被误判为不存在，发出一次不必要的 MathIR 请求；其响应 4,016 输入 / 25,727 输出 tokens。随后流程被 Ctrl-C 中断，formalization 审计有 started/finished 记录但没有 token usage。两次状态都留在独立报告 `C08-aborted-duplicate-mathir.json`；正式 C08 验证随后正确复用归档 MathIR。Stage 7 历史 C08 MathIR 与这次意外请求的 input hash 不同，因此不伪称为完全相同 hash 重放；但从工作量看，这次请求本来可以避免。

C13/C14 本地 proof 重放没有 API 调用，分别耗时 42.213s / 42.906s。Lean 子进程最大 memory footprint 分别约 1.03 GiB / 1.12 GiB；Python 峰值约 467 MiB / 499 MiB。大 proof wire 仍以 SHA-256 内容寻址 gzip 对象保存，业务 JSON 引用独立证据；每个重放记录了 proposition、proof export、wire materialization、独立 Kernel replay 等阶段资源。没有并发启动重型 Lean 作业。

## 轻量语义步骤旁路比较

新增的隔离研究解析器只处理三个已人工核对的来源片段：C05 的 `n+m`、C10 的 Q 因子表达、C12 的中文“存在 M…对任意 x…”量词句。解析器生成显式 operator/operand/binder 表示，检查局部类型约束和符号绑定，再 lower 回 Typed MathIR。三个 lowering 都与原 Typed MathIR 子树结构完全相同，保留原错误/量词次序，重新编译 statement 成功；运行约 0.075 秒，Python 峰值约 2.0 MB、0 token、0 Lean 调用。报告为 [semantic roundtrip](mathir-v2-stage8-semantic-roundtrip.json)，代码在 `devtools/research/mathir_v2_stage8/semantic_roundtrip.py`。

这证明一个受限、显式的语义层可以在局部文本片段上确定性保真地转成现有 Typed MathIR，但没有证明它能取代通用 MathIR 识别器，也没有改变这三题的路线 Kernel 结果。特别是 C10 的 `P(X)` 需要依据多项式上下文解释成声明 P；这依赖有类型的符号环境，不是单靠字符串规则。当前证据不足以支持整体替换 MathIR v2。更稳妥的接入研究是为范围清晰的表达式/量词片段增加可选的确定性 parser 与 binder/type checker，并在不一致时保留原 AST、报告冲突；proof-only 的主要短板仍是步骤证明与局部依赖组合，而不是把所有输入再包一层表示。

## 可复核边界与代码

所有实时 AI 调用仅用于 proof-only 或其 Lean diagnostics repair；没有重复 MathIR 请求（C08 上述一次误触发除外），没有图片输入，没有对 UI 或测试作 live 调用。本轮还增强 Stage 7 runner 的 checkpoint：完整 proof AST 写入内容寻址 gzip 证据文件，JSON 保存引用，降低大 wire 重复展开造成的内存峰值。运行结果为：结构审计 13 compiled / 2 unavailable / 0 Provider / 0 Lean；语义解析三项 roundtrip、类型检查与编译均通过；三份 Python 文件 `py_compile` 通过；C01/C05/C08/C10/C12 有真实 Lean 和 Kernel 执行。
