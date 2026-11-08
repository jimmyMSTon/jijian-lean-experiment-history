# DeepSeek Flash 三题结构锁与 Lean 转化实测（2026-10-07）

当前正式 App 默认使用 DeepSeek；没有 LIVE_AI_TESTS、OFFLINE_AI、DISABLE_LIVE_AI、pytest runtime Provider 网络封锁或自动 fixture 替换。AI 测试不需 live 开关，仅需正常供应商配置。开发缓存、single-flight、请求审计和无新信息修复去重保留。fixture/stub 仅由具体本地测试选择，不替换正式 Provider。请求与响应实际模型均为 `deepseek-flash`，thinking 为 provider_default；没有改模型路由或新增次数上限。

新版流程是类型化 MathIR → 代码生成 canonical specification / binder map / statement_hash → 固定 Lean 声明 → Flash proof-only。首次输出是固定顺序的 proof 数组；repair 单个响应仅 proof，单个请求恰含 fixed_statement、statement_hash、binder_map、current_proof、lean_goal、local_context、diagnostics、mathlib_candidates。外部前提、类型、作用域、量词与结论不能由 proof 响应编辑。源码声明 AST 比对允许 alpha-renaming；真实 Lean 导出类型在独立环境中比对，再进行独立数据式 Kernel replay。所有成功证书 statementMatched=true，additionalAxioms=[]。

仅重跑原来的三道文字证明，没有新增数学题或视觉专项。Mathlib 部分使用固定人工候选名称、实际本地源码检索和真实 Lean #check，未调用 AI 检索 planner；因此本报告不是完整生产 UI E2E。

| 同一原题 | 首次 proof | 一次 repair 后 | 最终 Kernel | statement / binder drift |
|---|---|---|---|---|
| 平方不等式（明确的本地 MathIR 样例） | 通过 | 不需要 | 通过 | 无 / 无 |
| 奇数求和 | 未通过（归纳假设片段 null） | 通过 | 通过 | 无 / 无 |
| 三角多项式 | 未通过 | 未通过：8/10 片段局部通过 | 未通过 | 无 / 无 |

平方题的完整 AI MathIR 转换实际失败：HTTP 响应收到，但 JSON 有多余闭合符号，后端保存原始无效输出并拒绝。上表平方题使用明确构造的本地数学 AST，保留原文步骤与零题目外部假设，再让真实 Flash 生成 proof，真实 Kernel 验证。不能把它报告成完整 MathIR AI 链通过。最终声明只有 x、y 两个实数参数；平方非负在内部步骤以 sq_nonneg 证明，没有添加为外部前提。

归纳题的最终目标保持对所有 Nat n 的奇数求和恒等式，hash 在 formalization、repair 与 Kernel 中一致。AI 初次把归纳假设列成待证明步骤而不是局部 assumption，并返回 null；测试用空 body 的真实 Lean 检查取得 unsolved-goal diagnostics，Flash repair 生成归纳法 proof 后 Kernel 通过。这里仍有原文步骤语义建模缺陷：证明了所锁定 MathIR 的形式化命题，不能据此宣称原有人类证明已逐步完全忠实验证。该 MathIR 未被偷偷修改或补前提。

三角题的 Polynomial P、Real θ、eval 和 cos θ 绑定保持不变，固定目标是 ∃ P : Polynomial ℝ, ∀ θ : ℝ, cos(3θ) = P.eval(cos θ)。首次十个片段都有 Lean 编译错误，主要是对已存在上下文变量重复 intro。一次 repair 调用针对这十个不同片段分别发出十个 proof-only 请求；最终仍有两处 tactic 错误：step_take_P 对已引入的绑定再 intro；goal 的 use 已解决目标后再 exact，触发 No goals to be solved。statement 和 binder 没有漂移，但完整证明 Kernel 不成立；未继续付费修复。

实现与环境排查发现并修复三处问题：canonical specification 内 tuple 保存成 JSON list 导致误报；导出辅助数值/类型类证据与内联证据的原始 Expr 差异；批量 expected 导出漏掉前面生成的辅助依赖。最终复核刷新真实导出数据，复用原有 AI proof，新增 AI 请求为零。真实受控篡改测试把同一平方题的候选声明 type 改成 False：Lean 在 Kernel replay 前返回 STATEMENT_DRIFT，没有成功证书，0 AI 请求。含 drift 的验证记录现在也不能进入 proof-only repair；它与全局离线模式无关。

本轮实际发起 22 次真实 HTTP 请求：mathir 3、formalization 3、repair 16；recognition、feedback、other 均 0。按原题归属：平方题 7（完整 MathIR 尝试 1、隔离 proof 1、校验误报导致的多余 repair 5）；归纳题 3；三角题 12。五次 repair 不应发出，已停止并修复触发路径。收到供应商响应 20 次；另外一次取消、一次审计未结束，用量未知，不当作成功。没有 SDK/HTTP retry、重复 input_hash、重复上传图片或额外 AI 自检环。

已知输入 token 172,216，输出 token 193,204（包含供应商计入 completion 的 reasoning）。两次用量未知，未补成 0。请求级内容无关证据见 request-audit-summary.json；原始审计保留在 .data-statement-lock-three/ai-audit.jsonl，不含密钥。

本地回归 296 passed，1 个第三方弃用 warning；这些 fixture/stub 检查不称真实 AI 成功。TypeScript 编译通过；Lean Export/Audit 模块真实构建通过；macOS App 重新构建并通过 codesign 验证，旧 App 保留。没有重跑图片、中文手写、Stitch 视觉/UI 完整 live E2E，也没有把它们报告为通过。

三题说明 Flash 可以生成及修复部分 Lean 证明，但首次转换、MathIR 语义与 tactic 上下文处理仍不稳定。Kernel 成功仅适用于表中注明的形式化命题和实际证书，不能外推为普遍可靠或完整生产链成功。

证据：algebra.json（真实 JSON 失败）、algebra-proof-only.json（本地 MathIR + 真实 proof/Kernel）、induction.json、trig_polynomial.json、native-drift-rejection.json、capability-summary.json。所有原始失败与旧证书记录保留。
