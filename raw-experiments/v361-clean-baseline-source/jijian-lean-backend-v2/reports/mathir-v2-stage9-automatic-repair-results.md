# MathIR v2 Stage 9：原路线复核与 proof-only 闭环

基线 `3804bae`。本报告覆盖保存的 MathIR、Lean 编译器确定性修复、少量真实 DeepSeek Flash proof-only/repair，以及真实 Lean 和独立 Kernel 复核。没有重建 MathIR、识别图片、改动正式 v1 App、DeepSeek Provider、Mathlib A、Statement Lock 或 Kernel 可信边界。Lean 默认串行；所有运行一次只启动一个 Lean 子进程。

## 结论

已确认两类工程缺陷会把模型的 lambda proof 错误送入 Lean：proof wrapper 会对已经封闭上下文的 lambda 再引入变量；定理上下文中的 `let` binder 会抢占原稿证明想引用的依赖假设。编译器现在保留闭合 lambda，并在 lambda proof 的 tactic 部分先引入未显式绑定的原有定义。C04 的真实 Lean 路线因此从大量 parse/type failure 推进到多步 proof 的独立 Kernel 检查。proof-only obligation 选择器也曾漏掉 `induction_base`；现已纳入并有测试覆盖。

参数归纳样本 C04 尚无完整原路线通过。C01 的固定命题与原路线在单次 Flash 修复后通过；C08 的固定命题与原路线经本地确定性 cleanup 后通过。C04 曾在一次实际最终复核中记录 11/12 个节点通过，但基例节点仍缺 proof，固定命题及原路线未通过；更关键的是，那次运行依赖的 10 个早期 repair terms 被同路径的后续报告覆盖，没有保存在最终报告中。当前从剩余可恢复 proof files 重放仅有 3/12 节点通过，不能把 11/12 的历史汇总当作当前可重放证据。此证据保存缺口已单独标出。

## 题目结果

| 题目 | 最新可复核结果 | 固定命题 Kernel | 原路线 Kernel | 首要阻塞 |
|---|---|---:|---:|---|
| C01 多步不等式 | 9/9 节点通过；一次真实 Flash repair 修复未使用的依赖 | 通过 | 通过 | 无；Statement Lock `1216b193…eacea3a3c` 未变 |
| C04 参数归纳有限和 | 可恢复 proof 集重放为 3/12；另一次最终运行记录 11/12 通过，但 10 个前置 repair term 未被持久化 | 未通过 | 未通过 | `base_conclusion` 缺 proof；唯一基例 proof-only 请求失败，无模型响应 |
| C05 错误归纳 | 3/8 节点通过 | 未通过 | 未通过 | `n+m` 错误项原样保留；基例缺 proof、归纳步骤无法引用与其类型相符的 IH |
| C08 有理数有限和 | 本地删除 Lean 明确诊断的多余尾部 tactic 后，完整路线通过 | 通过 | 通过 | 已解决；Provider 请求 0 |
| C10 多项式双路线 | route_A 的 4 步均未通过；route_B 两步未通过、一项缺 proof | 未通过 | 两条路线均未通过 | Q 定义与两路线未合并；proof terms 仍有 `dsimp made no progress` |
| C12 量词反例 | 1/5 节点通过 | 未通过 | 未通过 | 保持 `∃ M, ∀ x` 顺序；`v_x` 未绑定、若干 proof 缺失或错误引用 `v_M` |
| C13 循环论证 | 采用 Stage 8 已保存真实 Lean 记录：若干独立步骤有局部证书，循环假设无 proof，整条路线不通过 | 未通过 | 未通过 | 目标不能因为成为自身假设而通过；本轮没有重新跑 Lean |

C05 的错误新增项 `n+m` 未被纠正；C10 的 `Q(X)=P(X)(X−1)` 定义及 route_A/route_B 分开，错误路线的额外 `(X−2)` 未被移除；C12 的存在量词和全称量词顺序未交换。C13 的局部 Kernel 证书没有替代完整原路线。

C04 的分层状态见 [可恢复 proof 重放](mathir-v2-stage9-C04-route-evidence.json)。该文件引用三个导出的 proof wire（SHA-256 内容寻址）。[真实 repair 运行记录](mathir-v2-stage9-C04-scope-repair.json)保留一次 repair request、Statement Lock 和 11/12 的最终摘要，但不含被该次运行复用的 10 个早期 patch。后续脚本曾用相同文件名覆盖早期 repair patch 清单。故这份 11/12 汇总是实际记录，却不满足完整可重建证据要求；报告不把它称为可独立复现的成功证明。针对唯一缺失的 `base_conclusion`，实际请求失败，耗时 474 ms，无 token usage；没有对相同请求重试。

C05/C10/C12 的修复后 Lean/Kernel 回放和 proof-wire 引用见 [post-fix replay](mathir-v2-stage9-postfix-C05-C10-C12.json)。C01/C08 的成功摘要与 audit 在 [automatic-repair.json](mathir-v2-stage9-automatic-repair.json)。其他保存结构的忠实性审计和缺失样本原因见 [Stage 8 fidelity audit](mathir-v2-stage8-fidelity-audit.json)；本轮没有追查 C06/C09 丢失的 MathIR，也没有追索 C03 不可恢复的原始 proof。

## 分层语义表示

隔离研究对 C05 的 `n+m`、C10 的 Q 因子、C12 的量词句做了 3 个局部样本。lowering 后 AST 与保存的 Typed MathIR 子树逐项相等，类型约束和符号绑定通过；原稿错误和量词次序均保留。运行约 0.078 秒、Python 峰值约 2.07 MB、0 token、0 Lean。证据见 [semantic roundtrip](mathir-v2-stage8-semantic-roundtrip.json)。

这不是严格模型 A/B：没有在同一模型、prompt、结构、proof 和 diagnostics 条件下比较两个翻译方案。它证明轻量语义层可对这三个已审阅片段确定性保真地生成相同 AST，**没有证明能提高 proof-only 或 Kernel 成功率**。现有失败仍由具体 proof term、依赖 binder 对齐、缺失基例 proof 和 C04/C07 定义作用域契约造成。当前证据不支持替换 v2 Typed MathIR；建议只把此 parser 保留为局部、可审计的确定性前端研究。

## DeepSeek 请求与资源

本 Stage 9 共 6 次真实请求尝试：5 次收到可用结构响应，1 次失败；没有 retry，全部 cache miss，无 MathIR 生成或视觉识别请求。C01 1 次 repair；C04 2 次 formalization/proof-only 尝试和 3 次 repair 尝试。成功响应合计 98,726 输入 / 130,648 输出 tokens，HTTP 时间约 466.224 秒；失败请求另耗时 0.474 秒且没有 token usage。精确 request/workflow ID、input hash、模型、阶段、cache/retry、token 和耗时保留在各 `.data-mathir-v2-stage9*/ai-audit.jsonl` 和 JSON 证据中。失败请求审计没有保存 HTTP 状态码或 provider message，因此不推断它是余额、限流还是服务端错误。

C05/C10/C12 本地重放分别耗时 119.49 / 133.593 / 53.323 秒；C04 可恢复 proof 重放耗时 218.481 秒，Lean footprint 峰值约 0.934 GiB。C01/C08 的最新 Lean 复核由 Stage 9 automatic repair 记录；历史 macOS `maxRSSBytes` 包含映射文件页，不等同私有物理内存。

## 实现与验证

- `V2Compiler` 修正闭合 lambda proof 和 let-binder/依赖 binder 的本地编译包装；不改 theorem statement。C04 实际 Statement Lock 始终为 `575ccfcc4cb19b1ac1497743f0b3a65d1afc6d427833a31939203e94f02bf7be`。
- Lean Export/Audit 把 proof elaboration 与 kernel audit 异常按 nonce 记录；Python runner 从 Lean JSON diagnostic 消息中还原具体错误。`1=2` 配 `by rfl` 的真实负例返回了 Lean 原始 tactic error。
- proof-only obligations 现在会包含 `induction_base`，而非静默排除基例。
- `pytest tests/v2/test_mathir_v2.py tests/v2/test_v2_kernel.py -m 'not lean_local' -q`：44 passed，4 个真实 Lean 测试 deselected。
- `/[LOCAL_USER]/.elan/bin/lake build Jijian.Export Jijian.Audit`：通过。
- 真实 Lean/Kernel：C01、C04、C05、C08、C10、C12 均有本地执行记录；其中只有 C01/C08 是完整固定命题和原路线通过。C13 的结果来自已保存 Stage 8 实际记录。

本轮没有修改 v1 App、生产模型、Mathlib、MathIR 结构或 Kernel 边界。Stage 9 的 C04 repair 归档路径缺少那 10 项 proof patch，仍是当前证据链的未完成工程问题。
