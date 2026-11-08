# 极简 Lean｜正式 Source-First Proof Core 2026-10-20 完整闭环验证

## 决定与范围

当前唯一正式开发分支 `codex/official-proof-core`、稳定 `main`、Mac 唯一入口 `~/Applications/极简 Lean.app`。旧 V2 在 `v2-frozen-316ad4f-20261019` 标签与独立校验归档中封存，不能复活成并行版本。本轮从正式已安装 `643e2e9` 的盲测记录出发，修复源数学原稿多步依赖、存在见证与实分析 `ε-N` 量词作用域，不改数学题目、原稿或既有用户数据，不添加全局离线 Gate、模型调用上限/费用阈值，也不把生成的正确 Lean 证明等同于作者原稿正确。

## 真实混合新题盲测基线

`/[LOCAL_USER]/Documents/ChatGPT/极简lean-review/live-source-first-fidelity-new-model-20261020-retry-checkout/manifest.json` 是上一轮运行结果（**正式开发源码**，非新签名 App），四个实际业务的 Dev E2E 原始输出在本工程 `reports/source-first-new-20261020-*.json`：

| 数学原稿 | 正确性预期 | 旧的完整 Kernel | 旧 sourceProofVerified | 新源码保存真实证书回放 |
|---|---|---|---|---|
| `x+y=13,xy=30 → x²+y²=109` | 原稿正确 | true | true | 6/6 来源步骤通过 |
| `7 ∣ t → 49 ∣ t²` | 原稿正确 | true | false，5/7 | **7/7 来源步骤通过** |
| `vₙ→B → vₙ+3→B+3` | 原稿正确 | false，缺 `forall_n_prop` | false | 下述真实重跑已完成 Kernel+来源证书 |
| 真结论但原稿理由“因为 4+5=9” | 原稿错误 | true | false | 仍然 sourceProofVerified=false、0 误报 |

盲测累计真实 DeepSeek **11 次**、86,839 input +98,513 output tokens，四题总耗时 693.263 秒；第一轮测试脚本因证据输出目录在 checkout 外失败，**0 付费请求**，随后修正测试脚本路径（未改软件）完成四题。原始 data/AI request ID 在上述各报告及历史隔离审计目录中。

## 新增通用数学语义依据

1. **原稿完整等式链**。用户写 X=Y=Z=W 时，依次核对全部相邻原文式子、来源引用、数学表达式与声明的全部依赖。已修复 `12²−2×35=144−70=74` 因数值规范化重合引起的 5/6 假阴性。不能改错数字而借 Kernel 通过。
2. **整数整除与存在见证**。区分作者明确写出的 `∃j∈ℤ,t=7j` 和 “取这样的 j”；局部平方、整数见证的类型来源、`t²=49j²` 与 `49∣t²` 必须逐条一致。若模型将局部存在消去偷换成全局前提、改错指数或删掉局部见证来源，则整份来源不认证。针对紧贴公式的 “因为” 不要求 MathIR SourceRef 重复包括这两个汉字，但不能跳过中间数学断言。
3. **源 `ε-N` 实分析推理**。独立从用户 Unicode `(vₙ)ₙ∈ℕ`、`任取 δ>0`、`存在自然数 K`、`n≥K` 等符号归属检查参数，不假定 DeepSeek 的内部新绑定变量 `n_lim`、`K_new` 与用户使用相同名称；验证局部误差界与平移后的绝对值等式、复用 K、全称引入及最终极限定义。原始题目“证明数列(vₙ+3)收敛到B+3”与正文必须一致，不能用后文正确公式覆盖题目里的错误常数。
4. **形式语义独立**。`source_scope_closure.py` 按已存在、源文本支持的局部父作用域见证结论恢复上层 `forall` 所需的前提。仅追加对既有源节点的依赖边，不产生新命题前提或人工 Lean proof term。Lean 生成的完整形式路线仍需独立 Kernel 证书，原稿来源步骤正向认证另由 `reasoning_fidelity.py` 检验 typed expectedType、当前 MathIR hash、sourceRefs、dependsOn、statement lock/step certificate。

## 实际高等数学 E2E 完整结果（新修复）

正式开发源码 `reports/source-first-real-analysis-forall-scope-retest-20261020.json`。原稿 `vₙ→B`，证明 `vₙ+3→B+3` 的 `ε-N` 证明，**真实 DeepSeek 1 请求**（缓存同样来源的已经审计 MathIR，生成7个真实 proofTerm），input 7,319 / output 30,741 Token，耗时 182.579 秒。独立 Lean4.34/Mathlib 检验全部 **7/7 形式步骤和完整路线**（kernel checked=true、statementMatched=true、额外公理 []）。旧失败的 `forall_n_prop` 新证明已由模型生成并在 Kernel 中通过；source 阶段在修复之前仍未认证，修改之后用同一真实 Kernel 证书独立重放，**7/7 原稿语义认证通过**。注意后一次来源重放 **0 DeepSeek 请求**，不可误算成新端到端调用。

另外 `reports/source-first-epsN-closure-real-model-replay-20261020.json` 记录一份另行执行的真实源码工作流：复用用户的原始 MathIR/已有模型 proofTerm，DeepSeek 3 请求（26,851 input/10,432 output）、264.243 秒，完整 Kernel true，运行当时来源仍未认证。是独立的真实证据，不和上述一次全链重复合计成同一个调用。

## 安全与回归

- `tests/v2/test_source_epsilon_N_real_seven.py`，基于真实7步 DeepSeek/Kernel 证书的正例及修改原稿极限、常数、K 作用域、δ 正性、误差界、错误原始命题等反例。重要发现：“证明数列(vₙ+4)收敛到B+3”不能因后续另证 `vₙ+3→B+3` 而被认证，已修复。
- `tests/v2/test_source_epsilon_N.py`、`test_source_existential_witness.py`、`test_source_authored_chain.py`、`test_parent_scope_closure.py` 与原有测试继续使用严格的数学/来源证据绑定。单元测试中恶意变更原稿而人为同步 hash 是故意制造的强反例，**不是**模拟 Kernel 通过事实。
- 本轮用户数据、密钥、V2 归档及其他开发工作树没有清理或覆盖。历史输出全存档，并严格区分非实时测试、真实模型/Kernel 运行、纯证书回放与包内 App 检查。

## 未完成的泛化范围（避免产品过度承诺）

目前实分析来源规则对可明确解析的数列极限平移 `ε-N` 原稿提供独立核验，尚不能对所有实分析、任意数学领域及手写含糊语义全面正向认证；不识别的正确证明保持“未认证”，不能冒充“错误”。本轮不包含图像/手写实际 GUI 鼠标操作或 iOS/Android 构建。新源码需另行从 `main` 全量构建签名并核对实际包内运行后，才可称正式 Mac 安装已更新。
