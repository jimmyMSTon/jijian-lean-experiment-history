# Lean 运行时异常分类与 Repair 阻断通用修复

日期：2026-10-14  
范围：MathIR v2 verifier/workflow 的系统故障分类；没有修改 MathIR 数学语义、Statement Lock、ProofLock、Lean/Kernel 可信边界或 SwiftUI。

## 根因

V2 `verify_v2` 对 Lean 批次的 `AppError` 原样向外传播。503 Runtime 不可用和 504 Lean 超时因此会使工作流拿不到逐步的 `incomplete` 结果，也无法将错误作为可恢复证据写入验证记录。另一条风险路径是：若系统故障以普通 step status 到达 repair 构造器，通用分支会把它当作 proof 失败交给模型；Lean 没有提供新的数学诊断时，这种 repair 没有可操作依据。

该问题与 Kernel 判定不同：Runner 对 Lean 的数学 elaboration/proof 拒绝仍返回 `not_proved` / `statement_not_elaborated` 等具体结果；本修复只处理 Runner 抛出的 HTTP 5xx `AppError`。4xx Statement/Binder Drift 保持原有错误契约，不被改写为系统状态。

## 实施

- `backend/v2/verify.py`：对生产批处理、兼容型 probe/check 执行捕获 5xx `AppError`。步骤保留 `engine_unavailable` 或 `engine_error`、`failureClass`、`mathematicalStatus=not_established` 和无证书状态；附加 `engineError={code,message,httpStatus}`。目标 Kernel 未运行即没有 Kernel 证书，路线仍 `incomplete`。4xx 错误继续抛出。
- `backend/v2/workflow.py`：若初始或后续 Lean 结果含系统故障，在 proof generation / retrieval / repair 之前以对应 incomplete verification 和错误事件结束工作流。已有 verification checkpoint 先保存；不调用 DeepSeek 来代替缺失的 Lean 信息。
- `backend/v2/proof_only.py`：将 Lean Runtime/执行错误列为不可 proof-repair 的系统状态；无新 Lean diagnostics 时不生成 Repair 请求。
- `backend/v2/service.py`：压缩后的原生契约继续携带安全的 `engineError` 字段，避免持久化/展示层丢失系统错误类别。
- `tests/v2/test_v2_kernel.py`、`tests/v2/test_workflow.py`：覆盖 503、504、4xx Statement Drift、数学状态不误报、repair 不触发、压缩结果与 checkpoint 保留。

## 实际验证

- 定向系统错误与契约回归：`4 passed`。
- 完整非 live 回归：`489 passed, 26 deselected`；排除 `live`、`live_ai`、`lean_local` 标记；1 条 Starlette/AnyIO 弃用警告。
- `compileall` 与 `git diff --check`：通过。
- 实际 Lean/Mathlib/独立 Kernel：2 个本机 `lean_local` 测试，在既有源码锁定 Runtime `8ed0581c17efdbc6c9f64ccb66dad3768b4feb21ce25f501aab79b229e7443bd` 下分别通过：一般函数应用定理 `1 passed, 28.11s`；含 route-local binder 的原路线组合 `1 passed, 28.55s`。没有重建 Runtime；未运行 Lean 安装目录里没有 attestation 的旧 `lean-runtime/.lake` 产物。
- 新鲜 DeepSeek 请求/Token：`0`。本轮没有图片识别、Mathlib 检索或 Repair 请求。
- 曾在未指定源码锁 Runtime 的默认设置下运行 Lean-local 测试；Runner 按设计拒绝未 attested 的仓库内 `.lake` 产物，两个测试失败，11 个检查 runtime readiness 的测试跳过。随后显式选择上述现存指纹 Runtime，两个实测均通过。这次环境拒绝没有被解释为数学失败。

## 边界与剩余工作

此改动证明了系统故障不会被当成数学反例或触发无诊断 Repair；它不建立中文/图片原稿与固定形式命题的语义等价，也没有做新的用户原稿盲测或真实视觉识别。本报告未证明 DeepSeek 真实能力；正式 DeepSeek Provider 未调用、未变更。
