# DeepSeek 请求序列化压缩与真实 Smoke

日期：2026-10-13。此修改只调整开发和正式 Provider 发出的 JSON 文本编码、请求审计指纹与开发缓存键。模型、API 地址、JSON mode、thinking 配置、MathIR、数学验证及 Kernel 均未改变。

## 实施

`backend/providers/deepseek.py` 现在以紧凑 JSON 编码发送原 payload 和完整 JSON Schema，保留 schema 中的 `title`、描述和验证约束。模型响应仍由完整原始 schema 本地校验。紧凑化只去除 JSON 的空白字符。

`backend/ai_audit.py` 与 `devtools/ai_testing.py` 共用 `compact-json-v1` 版本标记，并将其纳入输入指纹及 `prompt_version`。开发缓存因此不会把旧 wire 格式的响应误作新格式命中。Provider 审计哈希与开发缓存哈希已通过 MockTransport 测试逐项比对。

## Smoke 暴露的 MathIR 输出契约缺口

离线检查被拒绝的真实结构输出后确认，根因是 JSON Schema 将 `Expr.targetType` 表示成对所有运算都可选，而既有 `TypeChecker` 只允许 `ascribe`/`cast` 使用该字段。保存的模型输出在普通 `add` 和 `forall` 节点填了 `targetType`；确定性校验因此报告 `V2_TARGET_TYPE_SCOPE`。这是模型输出与 MathIR 类型契约不一致，不是原证明错误、Compiler 故障或 Lean 失败。

`backend/v2/models.py` 现在在递归 Expr JSON Schema 中要求 `ascribe`/`cast` 必须有 `targetType`，并禁止其他操作出现该字段；`backend/v2/structure.py` 对模型提示同样明确该规则。MathIR/TypeChecker 规则及 Statement Lock 未变。契约已重新导出到 `contracts/MathIRV2.schema.json`、`contracts/StructureOnlyMathIRV2.schema.json` 和 `contracts/openapi.json`。

真实响应已经保存为 `tests/fixtures/deepseek/mathir_target_type_scope_failure.json`。本地 MockTransport 用当前 Provider 契约回放后，新 Schema 在 4 个对应表达式位置拒绝它，并分类为 `PARSE_ERROR`；不会进入 MathIR 编译或 Lean，也没有重发模型请求。另有 MathIR Schema/typechecker 回归验证合法的显式 ascribe 与普通运算。模型收到新增规则后的真实输出尚未重新验证。

## 可复核的请求体测量

`scripts/measure_prompt_wire_size.py` 从此前保存的真实 MathIR SQLite artifact 重建相同结构与 proof-only payload，再用 HTTPX 本地序列化完整请求体；不载入密钥、不访问网络、不估算 Token。结构和 formalization 两阶段都保留完整 model-visible schema。

证据来源为 `reports/performance-convergence-20261013/fresh-real-smoke-zero-addition/runtime-data/backend.sqlite3` 中的 artifact `fa93490b-ef22-47e7-abc6-86f44b5c47b3`，原文 SHA-256 为 `4b7c6bd22e941890e8eca5897fd2a0d243930015aaac5ed0c2308555b6209371`。

| 阶段 | 原空白 JSON 请求体 | 紧凑 JSON 请求体 | 减少 | 比例 |
|---|---:|---:|---:|---:|
| MathIR（含最新 targetType 合法性约束） | 14,065 B | 13,229 B | 836 B | 5.944% |
| Proof-only formalization | 5,677 B | 5,570 B | 107 B | 1.885% |

这是保存输入上的确定性 HTTP body 字节对照，不能解释为相同数量的 Token 节省或端到端延迟提升。之前报告的 source-reference 去重测量属于另一项提示词变更，未在这里与空白压缩混算。

## 单次真实 DeepSeek 尝试

运行 `scripts/run_v2_single_live_smoke.py` 时，先尝试过更激进的 schema `title` 裁剪候选。该候选随即撤回；当前最终源码只做空白压缩并保留全部标题。该次 live 证据不代表最终 `compact-json-v1` 格式已通过真实链路，也不作为 Kernel 结果。

该次请求为新输入 `任取自然数 n。证明 n + 0 = n。理由：自然数加法右单位元性质。`，真实使用 `deepseek-flash`，没有图片，cache miss，retry index 为 0。审计标识：workflow `0305c941-ba4e-4ae5-9bf2-7f798765efe9`，request `0b5ab4b9-7c1b-46ba-b29f-037d5d97333f`，input hash `4a018d20afe70f0d3302d43b87f1a7284d595e7094a1e0c2c731d61730d931d5`。

DeepSeek 返回 2,572 输入 Token、16,009 输出 Token，其中 15,144 为 reasoning tokens；HTTP 耗时 83.323 秒，workflow 总耗时 83.435 秒。结构化响应随后被确定性 MathIR 校验以 `V2_TARGET_TYPE_SCOPE` 拒绝；工作流明确在 Lean 之前结束，没有运行 Lean 或 Kernel。因此这次实测没有证明数学命题，也没有证明性能或完整业务链提升。原始审计和结果保留在被 Git 忽略的 `reports/performance-convergence-20261013/fresh-compact-wire-smoke/result.json` 与对应 runtime-data 目录，响应 replay 保留于本机 `.dev-ai/cache/`。

由于该响应没有成功生成可验证 MathIR、且请求使用了已撤回的 title-pruned 候选，本轮没有重复该输入或另发 live 请求。最终的空白压缩格式完成了本地 Provider、审计和缓存一致性测试；真实 DeepSeek、Lean/Kernel 端到端表现仍待单独新鲜 smoke 才能确认。

## 回归

- `pytest -q -m 'not live and not live_ai and not lean_local'`：452 passed，21 deselected，1 个既有 Starlette deprecation warning。
- `tests/test_ai_audit.py`、`tests/test_deepseek_prompt_serialization.py`、`tests/test_ai_test_architecture.py`：45 passed。
- MathIR targetType Schema/prompt 回归、既有 TypeChecker 目标类型回归及序列化测试：68 passed，1 个已标记 `lean_local` 用例 deselected；新增真实响应 fixture → Provider `PARSE_ERROR` 回放测试通过。
- `python -m compileall -q backend scripts tests`：通过。
- `git diff --check`：通过。
- 新增 Lean/Kernel 合并阶段真实回归：一个正确候选获得独立 Kernel 证书，一个引用前候选临时声明的候选被拒绝，一个含未知标识符的固定命题被分类为 `statement_not_elaborated`；实际只启动 statement/proof export 与独立 Kernel 两个 Lean 进程组。
- `scripts/build_mac.py`：本轮 PyInstaller 6.22.3 后端打包、ARM64 SwiftUI 编译和 `codesign --verify --deep --strict` 均通过。构建位于 `/[LOCAL_USER]/Documents/ChatGPT/极简lean 2/dist/极简 Lean.app`，Info.plist 标记源码提交 `0285643a25f26e86d5fcf20a9471fd1d2da00bc5`、`dirty=false`。包内 `runtime.json` 与 immutable Runtime lock 均指向源码指纹 `8ed0581c17efdbc6c9f64ccb66dad3768b4feb21ce25f501aab79b229e7443bd`。App 可执行文件 SHA-256：`d3c0f4fd2be9470a47ab193d389b050db2a78162e9e440a609b7ebea165e1141`。构建脚本保留了先前 `dist` App 的备份；没有安装或替换用户 Applications 中的 App。随后只有本报告会再更新。

## 结论与边界

已经实际测得的是保存输入上请求体字节数下降；没有得到相同 live 输入的 Provider Token/延迟 A/B，也没有得到本轮样本的 Kernel 成功。该 live 响应的输出大部分是模型 reasoning，但单个样本不足以推断普遍性能。thinking 参数保持原值，未尝试改变模型执行策略。

## 当前 Lean Runtime / 独立 Kernel 回放

随后使用此前保存的成功 MathIR 与 proof wire，在当前源码指纹匹配的隔离 macOS Lean Runtime 中重新执行验证；未启动 Provider，也未发起 Mathlib 检索。证据文件为 `reports/performance-convergence-20261013/current-runtime-kernel-replay/d9-saved-mathir-2161c2bb82fd47d492fc823a6f99a72e.json`，其源记录来自 `/[LOCAL_USER]/Documents/ChatGPT/极简lean-review/latest-v2-real-e2e-d9ba067-20261013/data/backend.sqlite3` 的 artifact `ef2bcee6-4d84-4824-9946-d8032c41ccb4`。这是历史真实 AI 输出的当前 Runtime 回放，不是新的 DeepSeek 端到端调用。

结果：`fixedStatementKernelPassed=true`、`kernelVerified=true`，`route_original.status=passed` 且 `completeOriginalRouteKernelPassed=true`。原路线依赖闭包为 `connected`，没有未连接的节点；Kernel binder-use audit 确认结论步骤实际使用了 `n_step`。两个源步骤均有 `sourceRefs`，结论来源区间为 `b0[33,42)`；路线 Kernel 证书中的 `statementMatched=true`、`checked=true`、`axioms=[]`、`additionalAxioms=[]`。statement hash 为 `311869be6e177086642a8dc16e3e624b72edea1dd27f85e8269c566f483e470e`，MathIR hash 为 `a0ba24159ec602aaa0933c288bfc1578ee849a7c8c2399c55fbf959b3e9f35a3`，回放输入源 SHA-256 为 `dea3cec7280b85ceaa8dfbe95d33986f39d74ad5bd2193f8ad327dae05081dbe`。

本次 Runner 共启动 3 个 Lean 进程组，峰值并发为 1；Lean 阶段合计 64.959 秒，脚本总耗时 64.976 秒。DeepSeek 请求数为 0，Mathlib 检索请求数为 0。它验证了保存下来的该条 MathIR/证明在当前 Runtime 上能完成原路线 Kernel 复核；不证明前一节失败的那次 fresh DeepSeek 结构输出，也不构成当前 App 分发包的 UI 端到端验证。此后只有交付报告改动，App 所含产品源码与已构建版本一致。

## Lean / Kernel 启动开销收敛

同一保存的 Stage 5 数学输入在原流程中先用 Lean elaboration 固定命题，再启动 Lean 导出 proof wire，最后启动独立 Kernel replay。Mathlib 每次进程启动都重新加载。历史性能记录显示批处理前为 5 个 Lean 进程组，批处理后为 3 个；命题 elaboration 仍然是一个独立的 Mathlib 启动。

当前 `verify_v2` 对生产 `LeanRunner` 使用 `check_many_with_probes`：`jj_export_expected` 先在导出进程里生成固定命题的独立表达式 wire，再显式恢复为 import-only 环境，然后才处理 proof。proof 候选间仍由 `withoutModifyingEnv` 隔离；每个候选的期望表达式 wire 与 proof wire分别输出；第三阶段仍是独立进程，只接收数据并执行 Kernel 检查。没有缩短依赖闭包、跳过原步骤或放松公理检查。真实集成测试还确认了 Lean 的错误恢复占位 `sorryAx` 会使固定命题失败，不会继续成为可接受的 statement。

用相同保存的 `new_real_square_correct` MathIR/proof 输入、零 Provider 请求重跑后，当前完整 `verify_v2` 与独立 Kernel 在 27.0545 秒完成，`kernelVerified=true`，2 个 Lean 进程组串行通过：statement/proof export 13.39 秒，独立 Kernel replay 13.23 秒。结果文件为 `reports/mathir-v2-stage6-process-converged-combined-20261013.json`。此前同一保存输入的历史记录为：批处理前 5 组、68.38–69.75 秒；批处理后 3 组、40.62–41.18 秒。跨日期运行的缓存状态不完全可控，时间差仅作为观测；减少一个 Mathlib 启动以及当前 2 个独立阶段的进程数是直接记录的事实。新记录有 4 行 process metrics，其中只有 2 行带 `processGroupPid`；`scripts/benchmark_mathir_v2_processes.py` 已修正汇总，分别报告 Lean 进程组数与指标行数。

另对本轮初始 `d9` 真实成功样本的同一 SQLite MathIR artifact（ID `ef2bcee6-4d84-4824-9946-d8032c41ccb4`，SHA-256 `e9d094c9a6b3e219f19b327265aa71abd0770504c89eb55607fbc32347492d4a`）再次通过当前 `verify_v2` 跑完 Lean/Kernel，未调用 Provider 或 Mathlib Retriever。固定命题与 `route_original` 完整原路线都通过，statement hash 保持 `311869be6e177086642a8dc16e3e624b72edea1dd27f85e8269c566f483e470e`，Lean 进程组从此前记录的 3 个变为 2 个，峰值并发仍为 1。当前 Lean 阶段 25.245 秒，其中合并的 statement/proof 导出为 12.02 秒、独立 Kernel replay 为 13.22 秒；包含 Python 编排的总耗时 25.293 秒。详细结果在 `reports/performance-convergence-20261013/current-runtime-kernel-replay/d9-saved-mathir-combined.json`。此前同一输入的 64.959 秒 Lean 记录中，命题 elaboration 单阶段为 39.11 秒，明显受冷启动影响；因此这里把 3→2 进程组视作确定改善，耗时变化只作跨缓存状态观察，不宣称为严格同条件延迟 A/B。

这项结果只证明本地 Lean/Kernel 阶段的实际减少，不等于新鲜 DeepSeek 请求的 Token 或端到端耗时下降。其后的单次新鲜 smoke 已使用最终保留完整 Schema 的 `compact-json-v1` 版本，真实 DeepSeek MathIR 与 formalization 均通过，Lean/Kernel 原路线通过；请求与结论细节见 [全链路工程收敛与真实 Smoke 最终结果](全链路工程收敛与真实Smoke最终结果-2026-10-13.md)。这仍不是与旧提示词同条件的 Token/延迟 A/B。
