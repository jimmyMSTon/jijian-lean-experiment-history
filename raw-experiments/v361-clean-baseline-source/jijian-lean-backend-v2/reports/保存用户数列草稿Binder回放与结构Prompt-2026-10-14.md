# 保存用户数列草稿的 Binder 回放与结构 Prompt 修正（2026-10-14）

## 使用的已有证据

只读读取 `极简lean-review/user-samples/proof-20261013-001/isolated_backend_data/backend.sqlite3` 中保存的 `mathir_v2_draft`（artifact id `23af01a9-fee1-46b6-8e73-dc0cee17db6f`）；未运行 Provider、未修改或覆盖记录。该素材是基于用户图片人工重建的文本，不是原图视觉识别结果。

当前代码 `MathIRV2.model_validate` 可读入草稿；现有显式类型 binder 归一化产生 **0 条**修订，因为六个 `forall` 均未提供 binder Declaration，也没有明确 `targetType`。随后确定性编译仍以 `V2_BINDER_UNKNOWN: bind:m_cond` 停止。此处必须保持失败：无类型来源时，代码不能推断数域或补造量词声明。没有进入 Lean 或 Kernel。

## 通用修正

在 `STRUCTURE_INSTRUCTIONS` 中明确要求：每个 `forall`、`exists`、`finite_sum` 的 binderId 对应唯一变量 Declaration；body 符号使用同一 ID；类型须由原稿明确给出或唯一确定；词法变量放在专用子 scope；原样复用的量词断言保留相同 binder ID；不确定时记录 ambiguity；不通过 `targetType` 给量词猜类型。

这避免把 `targetType` 当成量词类型字段，也不改变 MathIR、Lean 命题或原稿步骤。provider JSON Schema 支持 `scopes` 和 `declarations`，因此模型可以输出该表示。

回归新增有效表示样例：MathIR provider schema 接受 child-scope 变量声明，当前编译器保持量词 statement，并得到预期的 `∀ (v_q : ℕ)` obligation。此表示进一步通过真实 Lean 4.34 / 独立 Kernel：`∀ q : Nat, q=q`，证书 `checked=true`、`statementMatched=true`、`additionalAxioms=[]`，28.30 秒。Prompt 合同测试覆盖类型不明时禁止猜测。保存的真实草稿本身**仍未通过**；没有对同一输入再次请求 DeepSeek，且这次 Prompt 修改后的模型遵循情况尚未实测。新 theorem 是手工构造的合同用例，不是用户原稿或模型输出。

## 局限与后续证据

即使 binder 表示合格，原样本还包含 56 个一元 `eval` 表达式和错误的 `decl:a : Real`，无法忠实表示一般 `a : Nat → ?` 数列。现有 MathIR 已提供 Function/apply 类型，但本次保存草稿没有采用；不能把 `eval` 静默改成函数应用，也不能假定未给出的值域。当前先失败于 binder，须在未来新的、明确允许的模型实测中判断结构 Prompt 能否同时给出原稿支持的函数类型、逐步路线和来源映射。原图仍未进入 Mac 研究目录，不满足真实视觉 E2E 的材料条件。

## 验证

- Binder 与 Structure pipeline 定向测试：`14 passed`，包含 provider JSON Schema 与明确声明形式编译用例。
- 最终非 live 回归：`480 passed, 24 deselected, 0 failed`；`compileall` 与 `git diff --check` 通过，1 条 Starlette/AnyIO 弃用警告。
- 单独执行现有真实 Lean/Kernel 路线矩阵，`1 passed in 162.10s`；显式声明 binder 的真实 Kernel 合同用例 `1 passed in 28.30s`。运行环境明确使用与当前 Lean 源码指纹相同的已验证 Runtime `8ed0581c17efdbc6c9f64ccb66dad3768b4feb21ce25f501aab79b229e7443bd`，没有重建或改写 Runtime。
- 该真实矩阵包括 `1=1` Kernel 成功、`1=2` 的 `rfl` 被拒绝、两条路线一失败一通过、归纳用例的固定命题通过但完整路线因依赖使用审计不完整，以及有限有理数和 Kernel 成功。两个 Lean 测试均是代码内回归样例，不是用户原稿，也没有使用 DeepSeek。
- 本次最终全套非 live 回归：`480 passed, 25 deselected, 0 failed`；`compileall` 与 `git diff --check` 通过。新鲜 DeepSeek/视觉请求均为 0。真实模型遵循新 Prompt 的效果仍未实测。
