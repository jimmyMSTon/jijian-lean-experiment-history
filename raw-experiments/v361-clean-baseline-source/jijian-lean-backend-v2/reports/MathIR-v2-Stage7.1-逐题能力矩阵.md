# MathIR v2 Stage 7.1：逐题能力矩阵

本矩阵把 Stage 7 原始模型/Lean 运行与 Stage 7.1 本地确定性重放分开。Stage 7.1 没有调用 Provider。DeepSeek token 和 API 时间来自已保存的 request audit；Python/子进程内存来自原 case snapshot；Lean RSS 与 peak memory footprint 是 `/usr/bin/time -lp` 对 Lean 子进程组的不同计量值。空值表示证据没有保存，不代表 0。

MathIR 状态列只表示**当前保存结构的确定性编译结果**，不等同于模型结构语义正确或 Lean 证明通过。C06/C09 的原始 provider 结构没有持久化，不能回放，也不能猜测具体无效字段。

| Case | 当前 MathIR v2 编译 | Stage 7 实际 Lean / Kernel 结果 | 最早已知阻塞或错误节点 | DeepSeek tokens in/out | API 时间 | 已保存 Python / Lean 内存 |
|---|---|---|---|---:|---:|---|
| C01 | 通过；原文完全匹配；9 个路线节点 | 未进入 Lean | 旧编译器：goal 不在 root scope | 3,973 / 18,870 | 73.03 s | 未保存 |
| C02 | 通过；原文完全匹配；4 个节点 | 未进入 Lean | 旧编译器：`and` 被建成非二元表达式 | 3,913 / 12,362 | 45.91 s | 未保存 |
| C03 | 通过；原文完全匹配；6 个节点 | 首次 proof 输出未持久化；Lean/Kernel 结果未知 | 旧类型检查拒绝 Nat literal / Real 上下文；旧运行器约 12 GiB RSS 事件缺少阶段 checkpoint | 24,804 / 100,283 | 365.03 s（请求时间合计） | 最新保存捕获：Python 54.95 MiB、child 0 MiB；旧 12 GiB 事件无法分阶段归因 |
| C04 | 通过；原文完全匹配；15 个节点 | 原运行未进入 Lean | 旧编译器：归纳变量与锁定目标 binder 未关联 | 4,075 / 28,532 | 146.60 s | Python 55.47 MiB；child 0 |
| C05 | 通过；原文完全匹配；8 个节点 | 原运行未进入 Lean | 旧编译器：归纳 binder 不匹配 | 3,946 / 21,713 | 79.43 s | Python 54.44 MiB；child 0 |
| C06 | 不可回放；provider 输出未保存 | 未进入 Lean | 仅保存通用 schema 错误；具体字段不可知 | 4,045 / 39,590 | 131.87 s | Python 53.59 MiB；child 0 |
| C07 | 通过；原文完全匹配；10 个节点 | 原运行未进入 Lean | 旧编译器：`Nat` ascription 被用于 `Prop` 目标 | 4,023 / 44,707 | 141.44 s | Python 54.61 MiB；child 0 |
| C08 | 通过；原文完全匹配；5 个节点 | 原运行未进入 Lean | 旧编译器：多项加法 arity 被拒 | 3,979 / 17,349 | 62.91 s | Python 52.62 MiB；child 0 |
| C09 | 不可回放；provider 输出未保存 | 未进入 Lean | 仅保存通用 schema 错误；具体字段不可知 | 4,083 / 26,375 | 95.52 s | Python 51.55 MiB；child 0 |
| C10 | 通过；原文完全匹配；7 个节点 | 原运行未进入 Lean | 旧编译器：`Real` literal 与 `Polynomial[Real]` 上下文不匹配 | 3,995 / 17,914 | 64.65 s | Python 52.09 MiB；child 0 |
| C11 | 通过；原文完全匹配；4 个节点 | 固定命题 Kernel=false；原路线 Kernel=false | 首轮 `n_step1` proof 有 Type mismatch；repair 后仍因缺失局部名称（`h_pr_user_n_assume_eq`、`h_pr_user_n_step2`）失败 | 9,910 / 36,249 | API 149.43 s；workflow 227.26 s | Python 55.08 MiB；child peak 5,770.52 MiB。Lean footprint：首次 933 MB，修复后 934 MB |
| C12 | 通过；原文完全匹配；6 个节点 | 原运行未进入 Lean | 旧编译器：`Real` ascription 被用于 `Prop` 目标 | 3,864 / 20,622 | 78.93 s | Python 52.14 MiB；child 0 |
| C13 | 通过；原文完全匹配；5 个节点 | Stage 7.1 本地重放：固定命题 Kernel=false、原路线 Kernel=false；4 个有 proof 的局部步骤通过，整条路线不成立 | 原路线首个问题是 step 1 假设了目标；目标节点缺少可连接的原稿推导 | 6,666 / 26,051 | Stage 7 请求 102.68 s；workflow 167.36 s；Stage 7.1 Lean 回放 43.81 s | 原归档 Python peak 4,162.53 MiB、child 5,861.48 MiB。Stage 7.1：Python peak 511,524,864 bytes；Lean RSS 6,050–6,163 MB，footprint 936–1,039 MB |
| C14 | 通过；原文完全匹配；9 个节点 | Stage 7 repair 后固定命题 Kernel=false、原路线 Kernel=false | `c_factor` 首个未证明节点；Lean 报 `Unknown constant Nat.Coprime.mul_dvd`，`c_divisible_6` 也失败 | 20,820 / 88,322 | API 321.98 s；workflow 414.18 s | Python peak 918.83 MiB、child 5,945.19 MiB；Lean repair 阶段 RSS 6,049–6,234 MB，footprint 935–1,120 MB |
| C15 | 通过；原文完全匹配；2 个节点 | 固定命题 Kernel=false、原路线 Kernel=false；无 proof，Lean 子进程数 0 | formalization 没有给出 proof；Kernel=false 不构成反例证书 | 5,029 / 11,477 | API 47.62 s；workflow 47.69 s | Python 52.75 MiB；child 0 |

## Stage 7.1 对旧阻塞的复测

从已保存的 MathIR 结构确定性回放：**13 compiled，2 unavailable，0 compile errors**。旧记录中的 C01/C02/C04/C05/C07/C08/C10/C12 编译阻塞在当前旁路中已被确定性结构处理；这不表示重新调用模型或重新验证了这些样本的 Lean proof。C06/C09 不是失败通过修补解决，而是证据缺失，所以无法回放。

C13 使用原保存 MathIR 与 proof patches 运行本地 Lean/Kernel，没有 Provider 请求。当前复跑仍显示固定命题 Kernel=false、完整原路线 Kernel=false，4 个已保存 proof 片段通过；完整证据 AST 没有截断，按 SHA-256 gzip 对象保存。过程数据和恢复命令见[结构回放与资源诊断报告](MathIR-v2-Stage7.1-结构回放与资源诊断.md)及[C13 本地 Lean 回放 JSON](mathir-v2-stage7-C13-local-replay.json)。

## 资源异常的可证边界

C13 归档的约 1.79 GB JSON 中，四个唯一 proof evidence 对象 compact 编码约 20.7 MB；对其逐个 `indent=2` 展开后约 398.3 MB，四份展开估算约占原归档 89%。这支持“研究结果保存阶段的深树缩进与重复嵌入造成主要文件膨胀”的判断。Stage 7.1 C13 新回放还直接观测到：Lean proof-export stdout 25,060,688 bytes；JSON/wire 解析阶段 Python high-water 467,927,040 bytes；写入独立 Kernel 输入文件 23,040,766 bytes；Kernel Lean 子进程约 14.27 s。SHA-256 gzip 证据可完整恢复。

这组结果**没有精确定位 C03 旧约 12 GiB Python RSS 发生的阶段**。C03 当次 proof response、stdout 和阶段 checkpoint 不存在；C13/C14 的阶段测量说明了相同代码路径中可观测的开销，却不能冒充对 C03 的精确复现。不能因此声称 C03 峰值已完全修复或证明其由 JSON 保存单独导致。

Token / API 时间按保存的 DeepSeek request audit 求和；workflow 秒数和内存只在对应 case 文件中存在时报告。Kernel false 表示没有得到独立 Kernel 接受的固定命题或原路线 proof，不表示 theorem 已被反证。所有 Lean source mapping 目前最高为步骤级，表中错误节点不代表原图字符级坐标。
