# 当前三题：确定性解析、归纳结构与局部修复实测

仅接续当前三题一次。没有新增样本、模型或请求次数 Gate。DeepSeek 实际请求与返回模型均为 `deepseek-flash`，沿用已配置 Provider；Statement Lock、Binder Map、Statement Hash、Mathlib Retriever、Lean diagnostics 与独立 Kernel 复核机制继续生效。

本轮 MathIR 复用以前真实 DeepSeek 响应：代数题本地恢复原始非法 JSON，归纳题显式迁移已确认的局部假设角色，三角题不改 MathIR。没有将这些步骤报告为本轮新 AI 结构化调用；后续 proof 与 repair 请求是真实 API。

| 题目 | MathIR | 本轮首次／接续基线 proof | 真实 repair 数 | 最终 Kernel | 本轮真实请求 |
|---|---|---|---:|---|---:|
| 代数不等式 | 解析及 schema／结构检查通过 | 本轮首次 proof：6/6 片段通过，Kernel 通过 | 0 | 真实通过 | 1 |
| 奇数求和归纳 | 解析及 schema／结构检查通过 | 本轮首次 proof：2/10 片段通过，Kernel 未通过 | 8 | 真实通过 | 9 |
| 三角多项式 | 解析及 schema／结构检查通过 | 已有 proof 基线：8/10 片段通过，Kernel 未通过 | 2 | 真实通过 | 2 |

三角题上轮最初整批 proof 是 0/10 通过；本轮沿用的是其后已达到 8/10 的真实修复结果，没有重新生成整份 proof。

## MathIR 与 theorem 忠实性

- 代数：原始响应六个多余右花括号全部本地删除，数学字符串、字段和数值未更改；完整 Schema 通过。JSON 恢复产生 0 次新请求。最终目标仍为实数 x,y 的 `(x+y)² ≤ 2(x²+y²)`，沿用展开、配方与平方非负的原证明。

- 归纳：明确结构引用归纳变量、P(0)、局部 P(n) 假设、P(n+1) 后继结论和 ∀n,P(n) 总结。原 `step_ih` 改为归纳子作用域 Claim，不再要求 Flash 证明一条全局的 ∀n,P(n) 作为“假设”。原 AST 和原文定位不改；验证器对照基础和后继表达式。最终使用 `Nat.rec` 将原基础情形与带局部假设的原后继情形组合。

- 三角：仍为 `∃ P : Polynomial ℝ, ∀ θ : ℝ, cos(3θ) = P.eval(cos θ)`，量词顺序、选择的 P=4X³−3X、原三角展开路线及 Statement Hash 不变。8 个既有通过片段文本和 hash 完全保留。

三题总目标的外部 assumptions 均为空。修复前后各自 Statement Hash 相同，最终无 Statement Drift／Binder Drift。自然语言忠实性依据本题原文与 AST／推理路线对照；Kernel 核验的是锁定后的形式命题。

## 每一次真实 repair 的原因

| 题目／片段 | 真实 Lean 原因 | 修复范围 | request_id |
|---|---|---|---|
| 三角多项式 / step_take_P | Tactic introN failed: There are no additional binders or let bindings in the goal to introduce | 仅当前片段；其余片段原样保留 | 7835c034-05ad-4147-8f78-b50841d437e7 |
| 三角多项式 / goal | No goals to be solved | 保留已成功 use 前缀，只删除多余 exact | 86b336ba-83c6-4fb7-ae5e-96dbbd0b47c7 |
| 奇数求和归纳 / step_base_left | Tactic introN failed: There are no additional binders or let bindings in the goal to introduce | 仅当前片段；其余片段原样保留 | 6b38657d-de85-49d4-84c5-cb56e38026ec |
| 奇数求和归纳 / step_base_conclusion | Tactic introN failed: There are no additional binders or let bindings in the goal to introduce | 仅当前片段；其余片段原样保留 | 005944b2-5ab5-49b1-8a04-059f1f2b0087 |
| 奇数求和归纳 / step_consider_n1 | Tactic introN failed: There are no additional binders or let bindings in the goal to introduce | 仅当前片段；其余片段原样保留 | 58012f49-b8f2-4665-a7ad-7d75d0a565e9 |
| 奇数求和归纳 / step_decompose | Tactic introN failed: There are no additional binders or let bindings in the goal to introduce | 仅当前片段；其余片段原样保留 | d8c86db3-ffca-4d36-8314-fea8ef05f84a |
| 奇数求和归纳 / step_ih_simplify | Tactic introN failed: There are no additional binders or let bindings in the goal to introduce | 仅当前片段；其余片段原样保留 | 54fc1fcc-727e-4e45-97af-7fd6633eef2b |
| 奇数求和归纳 / step_ind_conclusion | Tactic introN failed: There are no additional binders or let bindings in the goal to introduce | 仅当前片段；其余片段原样保留 | fdd3c6db-a950-42fc-a394-751efbba76a7 |
| 奇数求和归纳 / step_induction_final | Tactic introN failed: There are no additional binders or let bindings in the goal to introduce | 仅当前片段；其余片段原样保留 | ec1b8b83-518d-4e8c-93ff-531238ff8678 |
| 奇数求和归纳 / goal_main | Type mismatch | 仅当前片段；其余片段原样保留 | 87e9213e-02a7-40af-ac1f-d90cfef87778 |

归纳的 7 次 repair 因重复引入已绑定上下文而发生 introN 错误；`goal_main` 的另一次 repair 因错误 intro 遮蔽已有证明依赖而产生 Type mismatch。修复没有重证归纳假设，没有更换证明路线。

三角只修 `step_take_P`（重复 intro）和 `goal`（目标已完成后仍 exact），其余 8 个片段随后也重新经过真实 Lean 检查；完整证明最终再经过独立数据式 Kernel 复核。

## 请求与验证证据

真实请求总计 **12**：formalization **2**、repair **10**；recognition/mathir/feedback/other 均为 0。全部 12 次响应实际收到，retry 0、重复 input hash 0、图片上传 0。本轮开发缓存命中 0；缓存和 single-flight 既有机制保留。

审计记录输入 token 94531，输出 token 43444（含 Provider 计入的 reasoning token）。`summary.json` 逐次记录 request/workflow/stage/reason/input_hash/prompt_version/model/cache/retry/token；不含 API Key。

- 本地测试：305 passed，1 条第三方 deprecation warning；明确排除 live 测试入口，未因本地回归发送额外 API 请求。解析／归纳作用域／只修失败片段／保留成功前缀的新增测试使用显式 recorded response 或 stub，不冒充真实模型、Lean 或 Kernel。
- TypeScript 类型检查通过；契约已重新导出。
- macOS App 已重新构建并通过 ad-hoc codesign 验证，保留之前构建。没有重启用户正在运行的 App，也没有额外执行 UI／视觉专项；这些不列为本轮成功项。
- 本轮三题 Kernel 结果由实际本机 Lean 4.34.0、已安装 Mathlib 和 macOS 沙盒进程产生；片段执行仅在开发 harness 并行调度，依赖建立及最终独立 Kernel 复核沿用正式实现。

逐题完整原文、首次 proof、repair proof、diagnostics、检索和证书见同目录 `algebra.json`、`induction.json`、`trig_polynomial.json`；本地测试、运行和构建日志见上级目录 `three-confirmed-fixes-*.log`。

本次能证明这三份原有推理的 Flash 转化在真实 Lean 诊断后闭环，不代表稳定一次成功：归纳新结构下首次只有 2/10 片段通过，需要 8 次逐片段 repair。未进行新增样本的泛化能力评估。
