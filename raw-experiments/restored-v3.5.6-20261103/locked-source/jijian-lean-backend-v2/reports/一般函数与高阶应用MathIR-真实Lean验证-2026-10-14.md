# 一般函数与高阶应用 MathIR：确定性及真实 Lean 核验（2026-10-14）

## 范围与基线

从开发主线和 `main` 同步的 `6476fa1a3fe3569ecfe48d352835f23ad3b2b409` 接续。保存的用户数列证明首轮模型结果仍因 `V2_BINDER_UNKNOWN` 失败；其 1 次真实 DeepSeek 结果已留存，本轮没有对旧输入再次调用模型。此次改动处理的是 MathIR 的通用表达能力：显式数学函数及函数应用。没有修改 Statement Lock、ProofLock、原路线判定、Lean Kernel、用户证明来源或正式 SwiftUI。

## 修复

旧 MathIR 只有 `Polynomial.eval`，无法忠实表示一般序列或函数应用。把 `a : ℕ → ℝ` 编成多项式求值会改变对象；把未知值域静默指定成 `ℝ` 也会增加原题没有给出的类型前提。

现在 `MathType` 支持显式递归的 `Function(domain, codomain)`，表达式操作 `apply(f, x)` 由类型检查器核实函数类型及实参类型，编译为普通 Lean 函数应用。嵌套应用也递归保留返回类型，使 contextual numeral 解析不会把 `f(k)(n)` 的实数值误留成自然数。`eval` 仍只表示多项式求值。MathIR 与 Structure-only JSON Schema 已同步；结构化提示要求值域必须有来源根据，缺少依据时保留 ambiguity。

这项支持不会推断原稿未声明的函数值域，也不会自动修复已经保存的旧模型输出。

## 可复核验证

- 纯结构化、schema、类型与编译回归：最终全套非 live 回归 **474 passed，24 deselected，1 条 Starlette/AnyIO 弃用警告**；独立 Function 子集 7 项通过。
- 编译契约：运行 `scripts/export_contracts.py` 后，两个导出 Schema 与运行时契约一致；`compileall`、`git diff --check` 通过。
- 真正 Lean + 独立 Kernel：使用本机 Lean 4.34.0、已验证源码与 `.olean` 指纹的隔离 Runtime，函数应用定理及错误不等式负例合计 **2 passed，41.87 秒**。函数样例为 fixture：`∀ a : ℕ → ℝ, ∀ n, a n = a n`；真实 Kernel 证明了这个固定形式命题，不表示模型识别了用户原稿。错误不等式保留 `x + 1 ≥ y + 1`，Lean 未能证明，状态为 `not_established`，没有声称已给出反例。
- 另行真实 Lean + Kernel 验证了正确依赖路线 `m ≤ n ⟹ m + 2 ≤ n + 2`：完整原路线通过，且步骤确实使用已声明前提；测试耗时 **27.72 秒**。测试只断言真实 `leanMetrics.processCount < 6`，未持久化该指标的精确整数，因此这里不推算 Lean 进程数。
- `scripts/check_examples.py` 在显式指向已验证 Runtime 后通过，独立 Kernel 证书 `checked=true`、`statementMatched=true`。初次不传 Runtime 路径时因开发工作树自身未带 attestation 标记而返回 `LEAN_RUNTIME_NOT_BUILT`；没有把这次环境错误记录成数学失败。
- 本轮真实 DeepSeek 请求、视觉识别请求、输入/输出 Token、Mathlib 检索、Repair 均为 **0**。没有用 fixture 冒充真实模型调用，也没有新鲜视觉模型证据。

## 原证明忠实性状态

保存的 `proof-20261013-001` 仍是其历史真实 DeepSeek 结构化响应：1 次请求，3517 输入 / 44146 输出 Token，176.066 秒；在 `V2_BINDER_UNKNOWN` 处被确定性校验拒绝，未进入 Lean/Kernel。旧响应里的 56 个单参数 `eval` 与 `a : ℝ` 不会被这次改动重写或误当成已经修复。一般函数应用现在可以被正确表示，但样本还存在缺失 binder、原文没有明确声明数列值域、以及强归纳/递推索引范围等独立问题。本轮没有证明该用户原证明，也没有比较新旧模型成功率。

多模态真实识别、未参与设计的新用户样本、错误代数步骤和全称/强归纳用户稿的端到端来源忠实性，本轮未执行。仓库另有依赖断裂、未使用依赖和 incomplete 分类测试；其中标记 `lean_local` 的测试须在本机 Lean 执行，不能称为纯离线 fixture。它们不等同于本轮新鲜用户输入实测。

## 持久状态

仅本工作树的后端 MathIR 模型、类型检查、Lean 编译器、结构提示、JSON Schema、测试和本报告发生变化。没有改动或重建 SwiftUI App、没有修改 `server.env`、数据库、Lean Runtime 缓存或已归档 App。最终状态核对时，隔离工作树 `极简lean-mathir-breadth` 也出现了同一批核心文件的未提交改动，且包括额外的 Set/Finset/初等运算扩展和未跟踪的 `backend/v2/elementary_ops.py`、`tests/v2/test_elementary_operators.py`。该树未被修改；重叠 Function 工作没有合并，额外运算扩展也没有纳入本提交，留待按该工作树自己的测试和证据安全整合。
