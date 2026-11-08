# 2026-10-23：复杂存在量词 MathIR 锁定目标 α-等价修复

## 实际失败证据与诊断

- 来源：正式 DeepSeek Flash 谱定理真实输出
  `tests/v2/fixtures/real_spectral_missing_goal_node_compiler_20261022.json.gz`
  （原记录 `reports/hard-three-spectral-after-delimiter-review-20261022.json`）。
- 原始错误：`V2_ROUTE_GOAL: route_main goalNodeId is not the locked goal`。
- 差异递归比较只有 **10 处 bound symbol/binder ID**，分别为 `q_goal/q_final`、`D_goal/D_final`、`d_goal/d_final`；定理文本、数学运算、类型及自由变量没有变更。
- `typecheck._expr_equal` 已能用词法 α-等价识别，但 `compiler.compile_route` 仍采用 `_expr_json` 严格 ID 相等，导致先前的完整 MathIR 无法进入证明义务生成。

## 通用修复

1. 新增 `_locked_goal_alpha_equivalent`：原 Expr α-等价成立之外，逐层要求对应绑定声明的 kind、type、constraints 与局部约束 α-等价一致。任何自由变量、运算结构、公式、量词范围、绑定类型或域条件不一致，均不通过。
2. 编译器目标节点选择改为精确引用 **claim** 且满足上述等价；不修改原始 MathIR、source、goal、statementLock、scope、依赖边或 proofTerm。
3. 用户原稿若通过 DeepSeek 切换了绑定类型（如自然数变整数）、遗失约束、或修改自由变量，继续拒绝。
4. 真正的 Lean 原证明完成、source fidelity 认证仍由原有独立 Kernel / 来源规则决定；不能把 MathIR 成功提升为证明成功。

## 可复现检查

- 真实谱定理 MathIR fixture：`compile_v2` 成功找到 `r_final`，后续 proofComposition 为 `incomplete`，错误原因为缺少 original proof term；**未声称整个谱定理 Kernel 通过**。原始 `route.inductions=[]` 及 `r_final.scopeId=s_step` 完全保留，归纳来源语义问题还需继续解决。
- 目标变量身份/自由变量换用、量词绑定类型不符、局部定义域条件不符、来源或固定 theorem hash 漂移，各负面测试拒绝。
- 本地独立 Lean 4.34/Mathlib 真 Kernel 对另一项存在量词 α-更名命题 `∃ k : ℕ, k=k` 完整验证成功：formal statement + complete route + independent Kernel certificate，额外公理 `[]`。此项是单独严格正例，**不是谱定理证明**；同时检查源码独立认证没有因 Kernel true 自动变 True。
- 日志 `/[LOCAL_USER]/Documents/ChatGPT/极简lean-review/alpha-goal-test-all-kernel-20261023.log`：6 passed。
- 全 Python 非实时回归 `/[LOCAL_USER]/Documents/ChatGPT/极简lean-review/alpha-goal-full-nonlive-20261023.log`：892 passed、70 deselected、既有1警告。此时 70 项未运行包含上述独立标记的真实 Lean 测试。
- 无额外 DeepSeek 网络请求、无 fixture 冒充实时请求、无新增 API Gate、无签名配置修改或新数学题型白名单。

## 仍未完成

复杂谱定理 proof-only 生成/归纳源码映射与原稿全部步骤独立认证；实分析区间域忠实类型化；数论源码 0/9 认证等。均不能仅因目标 α-等价修复而标记完成。
