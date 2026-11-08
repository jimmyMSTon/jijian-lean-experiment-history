# MathIR v2 安全收尾记录（2026-10-11）

本记录以工程检查点 `2d94820ffd657b3af6b8f9311b292e29979593e9` 为代码基线。此次只做收尾验证与证据清单维护；没有启动 DeepSeek 请求，没有继续 C01–C15 逐题开发，没有改正式 App、Lean Runtime、Kernel 信任边界或证明语义。

## 本轮实际回归

在项目 Python 3.12 虚拟环境中，串行运行以下三项本机 Lean/Kernel 回归：

```text
nice -n 15 .venv/bin/python -m pytest -q \
  tests/v2/test_v2_kernel.py::test_real_lean_and_independent_kernel_route_matrix \
  tests/v2/test_v2_kernel.py::test_real_lean_completes_proof_only_style_nat_inequality_route \
  tests/v2/test_v2_kernel.py::test_real_lean_rejects_disconnected_and_unused_route_evidence
```

结果：**3 passed in 489.85s**。这是真实本机 Lean 与独立 Kernel 路径，不是 fixture 成功标记。覆盖了正确和错误命题、两条候选路线、从零归纳、有限有理数求和、proof-only 不等式路线，以及断裂依赖与未使用依赖拒绝。没有调用 AI Provider。

最近一次完整默认 pytest 仍以检查点报告中的基线结果为准：**429 passed, 2 failed, 1 skipped, 2 deselected**，耗时 1,058.86 秒。两个失败是已知的归纳问题：`test_induction_obligations_close_root_definition_binders_without_promoting_sum_index` 在 Lean 前以 `V2_INDUCTION_BASE` 失败；`test_real_lean_composes_induction_route_with_base_and_transitive_helpers` 在真实 Lean 组合时引用未绑定的 `v_n`，因此固定命题 Kernel 未通过。基线工作树本轮没有重跑全量套件或这两个已知失败测试。完整记录见 [上一份检查点复核](mathir-v2-checkpoint-recheck-20261011.md)。

## 独立修复工作树的额外全量回归

收尾期间，已存在的隔离修复工作树 `5a54fd77dc3bc5b325eb7b332e42cca9181a6081` 完成了一次串行默认回归（共享本机 Python 3.12 环境，`JJ_ENV_FILE=/dev/null`，不配置 DeepSeek 凭据）：**433 passed, 1 failed, 1 skipped, 2 deselected，1015.94 秒**。失败项是 `tests/v2/test_mathir_v2.py::test_compiled_statement_elaborates_in_local_mathlib`：该工作树没有可导入的已编译 `Mathlib.olean`；`lake env lean` 尝试检出依赖后仍返回 `unknown module prefix 'Mathlib'`。因此这是 Lean/Mathlib 构建环境失败，不能记作 MathIR/kernel 数学反例，也不能记作通过。被跳过项要求显式的真实 macOS runtime；2 项 live AI 测试被项目默认 pytest marker 排除。此次运行没有 DeepSeek 请求。该额外结果来自隔离修复工作树，不替代上面的基线检查点结果；本次安全收尾没有针对失败继续开发或重跑。

## 已有完整原路线 Kernel 证据

以下为保存的当前编译器/Lean 回放报告，不是本轮重新对每个 C 样本发起验证：

- C01：固定命题和原路线 Kernel 均通过，零新增 DeepSeek 请求，见 [C01 回放](../reports/mathir-v2-C01-current-compiler-replay.json)。
- C07：8/8 义务、固定命题和原路线 Kernel 均通过，零 Provider 调用，用时 78.881 秒，见 [C07 回放](../reports/mathir-v2-C07-current-compiler-kernel-replay-20261011.json)。
- C08：最终 diagnostics-cleanup 当前工作流回放中，固定命题和原路线 Kernel 均通过，零 Provider 调用，见 [C08 最终回放](../reports/mathir-v2-C08-current-diagnostics-cleanup-rerun-20261011.json)。该报告也保存了较早阶段失败快照；应以其最终结果字段为准，不能把旧快照计为通过。

这些结果只证明保存的固定 Lean 命题和相应原路线证明项通过 Kernel；它们不证明图像识别或中文原文到 MathIR 的语义等价。

## 当前结构性限制与工作流共性问题

- MathIR v2 是封闭的类型化表达式 AST。它支持 `Nat`、`Int`、`Rat`、`Real`、部分逻辑与算术、有限和、三角函数及多项式求值，但没有一般函数应用/高阶函数节点；例如 `T(n)` 不能作为普通函数调用无损表示。
- 声明 ID、binder ID 与 scope ID 承担符号身份。输入若把声明身份复用于另一个量词绑定，可能产生结构合法但语义绑定错误的命题；已有 C06 证据记录此类碰撞。
- 归纳结构已显式表达，但通用的多变量、嵌套或互递归归纳组合尚未建立。上一轮实际 Lean 失败显示，即使较简单的带 helper 归纳路线仍可能在 binder 重命名后逃逸引用 `v_n`。
- `sourceRefs` 能校验来源块范围并提供步骤级追溯，不能证明自然语言/手写原文与 AST 语义相同，也不能定位到图像中的某个字符或笔画。Kernel 只核验锁定后的 Lean 命题与证明项。
- 结构解析成功、固定命题可证、局部步骤有证书、依赖闭包正确、路线可组合、完整原路线通过，是不同结果。独立证明目标命题不能代替用户原推导路线；局部 Lean 通过也不能代表全路线通过。
- 反复出现的薄弱边界是原文到受绑定 MathIR 的语义翻译，以及局部假设/依赖到完整路线的组合。Repair 只能修固定命题下的 proof term；它不能补救错误作用域、错误语义或不忠实的 MathIR。

## 已有直接证据支持的基础模块

- MathIR v2 schema 校验、支持子集内的确定性类型/作用域检查、来源范围校验和 theorem statement 渲染；13 份保存结构曾完成确定性编译。编译成功不等于语义正确或证明成功。
- Statement/Proof Lock 与哈希检查会拒绝改变锁定命题或 MathIR 结构的补丁。
- 本机 Lean Runner 支持批量陈述式 elaboration、proof wire 导出与独立隔离 Kernel 复核；本轮三项实际回归通过。
- 路线连通性、依赖闭包/绑定使用审计、Mathlib 候选 `#check`、Lean diagnostics 解析及 proof-only patch 应用，在既有测试或保存执行记录中有通过证据；这些基础能力不保证所有表达式可表示或所有路线能组合。
- `/api/v2/pipeline`、`/api/v2/jobs` 的服务层接线和序列化有 stub 测试覆盖；其 Kernel 标记是测试替身。当前证据不构成真实 DeepSeek → MathIR v2 → Lean → Kernel 的端到端证明。

## 保留但未提交的原始证据

本轮结束时工作区没有未提交源码或测试改动。**171 个 Git 未跟踪证据文件共 9,453,725 字节**，均原样保留；逐文件路径、大小和 SHA-256 见 [证据清单](mathir-v2-uncommitted-evidence-manifest.tsv)：

| 位置 | 文件数 |
|---|---:|
| `reports/mathir-v2-stage7-proof-evidence/` | 140 |
| `reports/proof-wires/` | 17 |
| `reports/mathir-v2-stage10-proof-evidence/` | 4 |
| `reports/mathlib-retrieval/` | 3 |
| `reports/mathir-v2-live-structured-responses/` | 2 |
| `reports/mathir-v2-scope-evidence/` | 2 |
| `reports/mathir-v2-stage10-inputs/` | 1 |
| `devtools/research/mathlib_candidate_evidence/generated/live_v6/requests.sqlite3-shm` 和 `requests.sqlite3-wal` | 2 |

`requests.sqlite3` 主数据库已由 Git 跟踪（最初记录于 `ba8a597`），文件保持不变；只读 `PRAGMA quick_check` 返回 `ok`，含 `requests` 表。WAL/SHM 两个旁文件仍未跟踪并由证据清单登记。清单包含 **2,080 个非 Git 文件，共 1,054,327,290 字节**；它只记录元数据和摘要，不复制证据内容或密钥。

## 检查点边界

收尾提交只记录本报告。以上原始证据仍保存在本机工作区并列在清单中。正式 V1 Mac App、DeepSeek Provider、MathIR 语义、Lean Runner 与 Kernel 可信边界均未改动。下一阶段等待统一架构决策，不继续 C01–C15 专项补丁。
