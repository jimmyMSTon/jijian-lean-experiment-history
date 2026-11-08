# MathIR v2 Stage 7.1：结构回放与资源诊断

本报告记录 Stage 7 存档的 MathIR v2 结构在本地确定性编译器中的回放，以及 proof AST 资源膨胀的代码路径调查。没有调用 DeepSeek；没有修改正式 v1 App、DeepSeek Provider、Mathlib A 或 Kernel 审计实现。

逐样本 MathIR、Lean/Kernel、首错节点、Token、耗时和内存对照见[Stage 7.1 逐题能力矩阵](MathIR-v2-Stage7.1-逐题能力矩阵.md)。

## 本地结构回放

回放入口为 `compile_v2`，它会验证 MathIR v2 schema、运行确定性类型/作用域检查并生成固定 Lean statement 和路线 obligations。它不代表自然语言到形式命题的语义等价已由 Kernel 证明。C03 使用存档的 `C03-captured.json.gz`；C13/C14 的 MathIR 从大型 JSON 存档用 jq streaming 抽取 `cases.C13.inputMathIR` / `cases.C14.inputMathIR`，没有把 1GB 级完整文件装入 Python。C06/C09 的 provider 原始结构输出当时未存盘，只有通用 `AI_SCHEMA_INVALID` 异常，因此不能诚实回放或指认具体字段。

| 样本 | Stage 7 原始结果 | 本地结构回放 | 备注 |
|---|---|---|---|
| C01 | 结构有效；未到 Lean | 通过 | 根命题作用域中的声明已纳入 statement 编译上下文 |
| C02 | 结构有效；未到 Lean | 通过 | 三元合取按原操作数顺序左折为二元树 |
| C03 | 捕获结构有效；早先 proof 结果未持久化 | 通过 | Real 系数可按上下文解析为 Real；幂指数仍保持 Nat |
| C04 | 归纳结构曾被拒 | 通过 | 归纳变量绑定、自然数后继表达及间接 IH/条件依赖得到验证 |
| C05 | 归纳结构曾被拒 | 通过 | 同上；保留样本中的每个原稿节点 |
| C06 | schema-invalid；原始响应缺失 | 无法回放 | provider audit 有请求记录，但没有 `unvalidatedOutput` 或精确字段列表 |
| C07 | 归纳结构曾被拒 | 通过 | 从 1 开始的归纳基例与后继结构通过静态验证 |
| C08 | 结构有效；未到 Lean | 通过 | 结合律节点规范化保留操作数顺序 |
| C09 | schema-invalid；原始响应缺失 | 无法回放 | 同 C06，不能推测失败字段 |
| C10 | 多项式上下文曾被拒 | 通过 | 多项式定义中的数值常量编译为 `Polynomial.C`；标量 `eval` 结果保持 Real |
| C11 | Lean 首次/修复均未得到证明 | 通过 | Lean 报 `Unknown identifier`；不是结构编译失败 |
| C12 | 结构有效；未到 Lean | 通过 | 与声明完全重复的类型断言映射为类型上下文，原节点和来源引用保留 |
| C13 | 有 4 个局部步骤通过，固定目标和完整路线未通过 | 通过 | 完整路线不能由若干局部 proof 通过替代 |
| C14 | Lean 未通过 | 通过 | Lean 报 `Unknown constant Nat.Coprime.mul_dvd`；这是候选 API 名称问题 |
| C15 | Lean 未得到证明 | 通过 | 存档 proof 缺失；不是结构编译失败 |

回放结果为 13/13 个可用 MathIR 结构通过编译；C06/C09 的 2 项因存档缺口不可判定。这不是 13/15 的模型成功率，也不是证明通过率。可复现的本地命令为：

```sh
cd jijian-lean-backend-v2
../.venv/bin/python -m pytest -q tests/v2/test_mathir_v2.py -k 'not compiled_statement_elaborates_in_local_mathlib'
../.venv/bin/python -m pytest -q tests/v2/test_mathir_v2.py tests/v2/test_v2_kernel.py -k 'not real_lean'
```

结果分别为 **33 passed, 1 deselected** 和 **36 passed, 3 deselected**。第二条中的测试过滤排除了名称含 `real_lean` 的真实 Lean Kernel 子集，但包含本地 Lean theorem elaboration 测试；没有 DeepSeek 请求。额外的 Lean 诊断/记录解析回归为 **20 passed**。

针对 Lean/Kernel，本轮一次组合回归显示 3 项通过，随后在第 4 项路线/Kernel 回归仍运行时人工中断。之后单独重跑 `test_real_lean_rejects_disconnected_and_unused_route_evidence`，**1 passed in 148.82s**。macOS 实际执行覆盖固定命题可由 `rfl` 独立通过、断裂/无关步骤不能证明原路线成立，以及正确路线和错误路线的对照。组合回归的前三项记录仍有效，但不把被中断的第 4 项计入组合运行结果。

## 确认的结构缺陷与修复

- 归纳目标中存在显式 `∀ n` 和 theorem scope 中自由 `n` 两种合法表示。绑定验证现在识别两种形式；Lean 归纳 proof 会区分目标 binder 与 theorem-context variable。
- 归纳基例/步中，`(n + 1) + 1` 与 `n + 2` 的 Nat 加法树形不同。仅对生成的归纳比较式做确定性 Nat 常量归一；原 MathIR 节点和原 proof term 不被删除或改写。
- 归纳步可能经多个原稿中间节点间接使用 IH 和下界条件。验证改为沿 `dependsOn` 求传递闭包，仍要求真实依赖到达，不能以“目标单独可证”替代。
- 结合律操作符的 n 元表示按顺序左折；不交换操作数。减法、除法、幂等非结合运算仍拒绝错误 arity。
- 字面量区分固定类型与可由上下文确定的裸数字。Real 运算系数可按 Real 上下文解析，幂指数仍是 Nat；显式 ascription/cast 仍锁定其声明数域。常量幂只折叠可直接安全处理的 0/1 情形，避免巨大指数构造超大整数。
- 多项式类型上下文只作用于 polynomial-valued 定义/等式；不再从 `Polynomial.eval` 的子表达式向外错误传播 Polynomial 类型。
- 等同声明类型的纯 ascription 不会被当成逻辑前提；原路线节点保留为 `typing` 节点，来源引用与节点身份均保留。

用户提出的路线反例仍由 `tests/v2/test_v2_kernel.py::test_real_lean_rejects_disconnected_and_unused_route_evidence` 明确覆盖：独立 `2 = 2` 和目标 `1 = 1` 都可各自 `by rfl`，固定命题 Kernel 可通过，但无 `dependsOn` 的完整原路线必须报告未连接 claim。另有两条路线一错一对的对照：错误路线保持 incomplete，正确路线通过；整体状态由完整路线结果决定。Stage 7 之前的本地回归记录包含路线闭包检查通过；本阶段中断的组合 Lean 子集尚未重新完成上述具体测试，不能把它计作本轮实测通过。

## 资源膨胀：证据与判断边界

**直接观察到的存档数据：** C13 的 JSON 原文为 1,792,200,782 bytes，压缩为 46,978,014 bytes；C14 为 1,038,115,999 bytes，压缩为 26,688,255 bytes。C13 的 `firstVerification` 与 `finalVerification` 各含 3,702,430 个 JSON path events；C14 的 `finalVerification` 含约 4,013,128 个相关 events。C13 proof evidence 的 4 个唯一对象，紧凑编码合计 20,676,631 bytes；只对这 4 个对象逐个测量 `indent=2` 序列化，结果为 398,277,474 bytes，**增加 19.3 倍**。旧结果将同一证据重复放入 `steps` 与 `routes[].stepResults`，并同时保存 first/final verification；按四份展开估算为 1,593,109,896 bytes，已解释 C13 1.79 GB 原文的约 89%。剩余部分来自其余重复结果字段及 JSON 缩进。这证明主要落盘膨胀来自 pretty-print 深树和重复嵌入；它本身不能单独证明 C03 的 12 GiB Python 峰值。

**Lean 子阶段的已存实测：** 归档中的 `/usr/bin/time -lp` 同时记录 maximum RSS 与 peak memory footprint。C13 首次运行：proposition elaboration 6,047,956,992 / 934,850,944 bytes，proof export 6,145,867,776 / 1,021,866,176 bytes，Kernel replay 6,146,211,840 / 1,029,517,376 bytes。C14 首次运行三阶段分别为 6,050,529,280 / 936,096,128、6,074,580,992 / 950,350,144、6,048,284,672 / 935,342,272 bytes；修复后分别为 6,049,185,792 / 934,801,536、6,170,640,384 / 1,044,901,440、6,233,980,928 / 1,119,957,440 bytes。单位均为 bytes；这些是 Lean 进程组计量值，不能与 Python RSS 混为一项。

**C13 新版串行重放：** 未调用 Provider，从归档 `finalMathIR` 载入原有 proof patches；固定命题 Kernel=false、完整原路线=false，4 个有 proof 的局部步骤均为 Lean/Kernel passed。导出 stdout 25,060,688 bytes，proof wire 解析 1.264 秒、该阶段 Python high-water RSS 467,927,040 bytes；审计输入 JSON 文件 23,040,766 bytes，Kernel 子进程 14.27 秒，RSS 6,143,453,328 bytes、footprint 1,030,393,936 bytes；证书物化 0.3584 秒。完整 AST 没有截断：四个证据对象分别以 SHA-256 gzip 文件保存，合计约 20.7 MB 未压缩，报告只保留内容地址、字节数和摘要。实测报告：[C13 本地 Lean 回放](/[LOCAL_USER]/Documents/ChatGPT/极简lean%202/jijian-lean-backend-v2/reports/mathir-v2-stage7-C13-local-replay.json)。证据可逐文件 gzip 解压，sha256 校验与文件名一致。

**C13 新版回放的阶段峰值差：** Python 的 `ru_maxrss` 是进程生命周期 high-water，而非瞬时 RSS；runner 在阶段边界采样，所以以下增量表示该阶段结束时观测到的新峰值，不代表该阶段独占内存。基线 Lean 命题导出后是 57,573,376 bytes；proof export 后 145,604,608 bytes；解析并保留完整 proof wire 后 467,927,040 bytes，新增峰值约 **322.3 MB**，为本次各阶段最大增幅。随后 Kernel replay 输入物化后采样为 486,703,104 bytes（新增约 18.8 MB），证书物化后为 511,524,864 bytes（新增约 24.8 MB）。这将本次 C13 回放中最大的 Python 增长定位到**完整 proof wire JSON 解码及 AST 持有**，而不是 proposition stdout、Kernel 子进程或证书解析；Lean proof export 子进程自身另有约 6.16 GB macOS maximum RSS / 1.04 GB peak footprint。此处只是定位新版 C13 可重复路径的增长段，不能外推为 C03 旧 12 GiB 的已证实原因。

**Python 总峰值与 C03 边界：** 归档的阶段快照显示 C13 Python peak RSS 4,162.53 MiB、reaped child peak 5,861.48 MiB；C14 是 918.83 MiB 和 5,945.19 MiB。C03 最新已保存回放是 54.95 MiB、child 0 MiB（结构类型检查失败，未进入 Lean）；旧的约 12 GiB 事件没有响应、stdout 或阶段 checkpoint。C13 新重放的阶段内存观测是 55–512 MB Python high-water，证明去掉重复 stdout/缩进输出可显著降低同样存档 proof 的验证路径，但不构成对丢失的 C03 请求的精确复现。

**已实施的资源修正：** `parse_diagnostics` 逐行扫描并在切片前跳过协议 evidence；`extract_record` 对协议行直接从原 stdout 位置用 `JSONDecoder.raw_decode`，避免整行与 JSON 字符串副本。proof wire 解析后，在审计文件写入前清空已消费的原 stdout。Lean runner 新增 stdout/stderr 字节数、Kernel 输入 JSON 字节数、expected/proof/certificate 物化耗时和 Python peak RSS 阶段记录。Stage7 重放脚本现在支持从完整证据存档分块选择 MathIR，并将 wire evidence 以 SHA-256 gzip 对象引用，保留完整可恢复内容。JSON schema 仍由 Lean 的完整导出及独立 Kernel 路径验证；没有截断或绕过 Kernel。

## 尚需契约决策

- 对没有显式类型标注的十进制/整数裸数字，MathIR 应表达固定数域还是由唯一数学上下文确定的数域。当前仅保守处理可证明是 bare numeral 的上下文，显式类型标注保持固定。
- MathIR 的 `scopeId` 是否允许在 theorem 的后代 scope 中引入自由变量并视为 theorem binder。当前依照样本来源结构沿 goal scope ancestor chain 闭合；这改变编译语义，应由 v2 契约明确。
- 归纳 proof 的结构化关系是否正式要求 `dependsOn` 传递闭包包含 IH 与下界条件。现实现按“原步骤确实依赖这些局部前提”的语义执行；需在 v2 schema 文档中固定此契约。
- C06/C09 的具体无效字段只能由原始结构响应决定；旧输出未保存，不应通过猜测来修补。

正式接入建议：先冻结以上 MathIR v2 契约，再做一次不改 Statement Lock 的离线结构回归；proof evidence 的压缩/引用和分阶段 RSS 诊断应先在 v2 旁路实现并验证。固定 theorem Kernel 通过与用户原推导路线通过继续分别报告。
