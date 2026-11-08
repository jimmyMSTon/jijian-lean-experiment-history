# 极简 Lean · MathIR v2 第六阶段：Lean 进程治理与 Mac 集成风险

基线：`dc854d5`。本阶段改动仅用于 MathIR v2 研究旁路的 Lean 进程治理、批量执行和资源诊断；未修改正式 v1 App、DeepSeek Provider/模型、MathIR 语义、Mathlib Retriever A、Statement Lock 或 Kernel 信任边界。历史真实模型结果只作本地回放，不重新调用 Provider。

## 实施

`LeanProcessScheduler` 用 `flock` 文件锁在共享 `JJ_DATA_DIR` 下管理 Lean 进程组，默认并发数为 1，配置值只能为 1 或 2。槽位覆盖计时器、macOS 沙盒启动器、Lean 及其后代，因此真实 Lean 进程也在并发计数内。等待槽位不占用文件锁。取消、超时和 `Services.close()` 会终止并回收当前 Runner 启动的进程组；API lifespan 先关闭任务，再调用服务关闭。

`verify_v2` 把所有固定命题的 elaboration 合并到一个 Lean 进程，把 proof term 导出合并到另一个进程，把独立 Kernel replay 合并到第三个进程。候选 proof 仍在彼此隔离的 `withoutModifyingEnv` 区域内编译；Kernel replay 仍发生在独立 Lean 进程，且每条证据 replay 后恢复到仅含 import 的环境。Kernel 进程只接收 proof wire 数据，不执行候选 tactic。为防止批次内候选互相引用，候选名称唯一且每条 Lean 命令之间恢复环境。

macOS Lean 阶段通过 `/usr/bin/time -lp` 记录进程组的墙钟时间、user/system CPU、maximum RSS 和 peak memory footprint。业务结果附带各 Lean 阶段、PID、排队时间、槽位、并发观测值及 Lean 返回码。API Key、原始证明和请求内容均不写入这些资源字段。

## 同一真实 MathIR 记录的前后对照

输入为 Stage 5 已保存、由真实 DeepSeek Flash 产生且曾通过 Kernel 的两步等式证明；本基准没有 Provider 请求。首轮为当日首轮进程，文件缓存不保证冷启动；warm 行是紧接着的第二次运行。

| 路径 | 运行 | Lean 进程组 | 总墙钟 | Lean user CPU | Lean system CPU | 峰值 RSS | 峰值 memory footprint |
|---|---:|---:|---:|---:|---:|---:|---:|
| 旧逐条 proof + 独立 replay | 首轮 | 5 | 68.51 秒 | 10.60 秒 | 56.79 秒 | 5,774 MiB | 该次记录未采集 |
| 旧逐条 proof + 独立 replay | warm | 5 | 68.10 秒 | 10.53 秒 | 56.81 秒 | 5,772 MiB | 该次记录未采集 |
| 新批量 proof + 独立批量 replay | 首轮 | 3 | 40.62 秒 | 6.28 秒 | 33.79 秒 | 5,770 MiB | 该次记录未采集 |
| 新批量 proof + 独立批量 replay | warm | 3 | 41.18 秒 | 6.29 秒 | 34.19 秒 | 5,772 MiB | 该次记录未采集 |

单轮配对资源测量也使用同一保存记录及同一 Lean 环境：旧路径 68.0947 秒、5 组进程；新路径 41.5203 秒、3 组进程。Lean 进程墙钟合计减少约 39.0%，启动组数减少 40%；user CPU 10.52→6.49 秒，system CPU 56.82→34.41 秒。最大 RSS 约 5,772 MiB，基本不变；macOS `peak memory footprint` 约 890.65→890.64 MiB，也基本不变。RSS 含大量 Mathlib 映射页，不能等同于私有物理占用；批处理降低了时间、CPU 和重复导入次数，但本次没有证据表明单 Lean 进程峰值 footprint 下降。

这台机器在重复运行时冷/暖文件缓存差异不到 1 秒，意味着主要成本来自启动 Mathlib 和 sandbox/process setup，而非磁盘冷读。历史 JSON 原始结果：`mathir-v2-stage6-process-before-batching.json`、`mathir-v2-stage6-process-after-batching.json`；含物理 footprint 的单轮结果：`mathir-v2-stage6-process-before-batching-physical.json`、`mathir-v2-stage6-process-after-batching-physical.json`。

## 真实 Lean、历史证据及新样本

Lean 4.34.0 / Mathlib 已在当前 Mac 实际运行。隔离批次集成用例验证第一条 proof 通过，第二条 proof 尝试引用前一候选而失败，第三条 proof 仍通过；两个有效证据分别取得独立 Kernel certificate。实际启动 3 个进程组：固定命题 elaboration、proof export batch、independent Kernel replay batch。

实际并发上限测试用并发数 2 启动三项 Lean `#check`。三项都真实执行成功，Runner 观测峰值为 2 个进程组；第三项在共享文件槽释放前等待。其余本机测试验证默认串行/最高两槽调度、超时、任务取消回收和服务关闭清理。

已保存的 Stage 4 真实 DeepSeek 输出在新代码上本地回放如下。0 次 Provider 调用：

| 样本 | 固定命题 Kernel | 原路线 Kernel | Lean 进程组 | 耗时 | 结果说明 |
|---|---:|---:|---:|---:|---|
| 正确等式 | 通过 | 通过 | 3 | 40.29 秒 | 与旧记录一致 |
| 错误等式 | 未通过 | 未通过 | 0 | <0.01 秒 | 无完整可检查 proof，不启动 Lean |
| 从 1 开始归纳 | 未通过 | 未通过 | 2 | 27.78 秒 | base 与 step 仍未被证明 |
| 有理数有限和 | 未通过 | 未通过 | 3 | 40.83 秒 | 目标仍有失败 proof |
| 相依多项式定义 | 通过 | 未通过 | 3 | 41.07 秒 | theorem 仍有证书，但原路线未使用声明依赖，保留 incomplete |

另一个未参与批处理方案设计的真实输入是：“设实数 x、y 满足 x=y。由等式的对称性，得到 y=x。证明：y=x。”原文被逐字保留，结构响应所有 proofTerm 均为 null。DeepSeek Flash 共 3 个真实请求：MathIR 1 次（输入/输出 3,758/7,760 tokens，31.54 秒）、formalization 1 次（1,328/1,426 tokens，6.19 秒）、repair 1 次（71,399/4,729 tokens，21.88 秒）；retry 均为 0。合计输入 76,485、输出 13,915 tokens，HTTP 用时 59.61 秒。首次 Lean proof export 失败，目标与中间 claim 两处有新的 Lean 诊断，因此只发起一轮诊断驱动 repair；之后 Lean 和 Kernel 均通过，目标依赖被证实使用，statement hash 未变化。最终 fixed statement 与完整原路线均通过。总 workflow 128.764 秒，Lean 首次尝试与 repair 后分别耗时 27.562 秒和 41.495 秒，共 5 个 Lean 进程组。Repair prompt 输入较大（71,399 tokens）；本阶段没有改 Mathlib A 或正式 Prompt，故此项只作为后续性能调查证据，不应隐藏。

完整真实调用审计、MathIR、statement hash、diagnostics、证书和阶段 metrics 在 `mathir-v2-stage6-live-e2e.json`；它是本机忽略文件。没有记录 API Key。

## 验证记录

- `.venv/bin/python -m pytest -q --ignore=tests/test_live.py -m 'not lean_local'`：**350 passed, 1 skipped, 6 deselected**，4.55 秒。`test_live.py` 未纳入本次回归；此前的一次未排除运行中，两个 `live_ai` 用例失败。该时段 `.data/ai-audit.jsonl` 的调用记录为 `real_request_attempted=false`，且项目默认 `.env` 未配置 Provider，因此未发送真实 DeepSeek 请求。
- `.venv/bin/python -m pytest tests/test_lean_process_scheduler.py -m lean_local -q`：**2 passed, 5 deselected**，66.60 秒；两个通过项都实际启动了本机 Lean/Mathlib，其中一项是三任务、两槽并发验证。
- macOS 计时包装器超时压力检查：连续 **40** 次 50ms 超时均返回 `LEAN_TIMEOUT` 并回收进程组，覆盖了发现的“超时和 finally 重复发信号”PID 复用竞态。
- `scripts/replay_mathir_v2_stage4_records.py`：5 条保存记录全部完成；逐条结果见表，无 AI 请求。
- 最终 task-local trace smoke：保存的 Stage 5 成功记录本地回放 **43.3216 秒、3 个 Lean 进程组、Kernel 通过**；0 次 Provider 请求。
- `lake build +Jijian.Export`、`lake build +Jijian.Audit`：实际成功。
- `compileall` 与 `git diff --check`：通过。
- 未构建或替换正式 macOS App；本阶段改动属于研究旁路的 Runner/调度层。

## macOS App 接入风险与建议

1. Mac App 启动后端时应明确传入 `JJ_ENV_FILE=~/Library/Application Support/JijianLean/server.env`、稳定的 `JJ_DATA_DIR=~/Library/Application Support/JijianLean/data` 和默认 `JJ_LEAN_PARALLELISM=1`。多个本地 worker 只有共享该数据目录才能共同遵守槽位上限。检查应用沙盒对目录创建、锁文件和 Lean 临时工作目录的授权。
2. 正式客户端默认使用 `JJ_LEAN_PARALLELISM=1`。如以后在设备内存压力验证后选择 2，应作为部署配置选择，不是用户界面里的设置，也不是产品请求门槛。
3. SwiftUI 窗口关闭、任务取消与服务退出应调用当前 API/job cancellation 和服务 lifespan 清理；不要由 UI 自己另起 Lean 子进程或轮询重触发验证。
4. 进程指标可保留在本地开发诊断日志；普通结果界面不应展示 RSS、PID、Lean 阶段或内部沙盒细节。
5. 计时字段是 macOS 子进程组统计；Linux fallback 未采集相同粒度的 footprint。`maxRssBytes` 不是 footprint，不能在 UI 或汇总中互换。
6. 同进程多命题批次的 `withoutModifyingEnv` 隔离已由真实对照用例验证；大型批次仍可能因 Lean heap 保留而增加峰值内存。本样本只证明当前小型批次稳定，不能据此声称任意大路线的内存峰值都有上界。

## 工程建议与契约决策

工程上可将批量命题 elaboration、proof export 和独立 Kernel replay用于 v2 研究旁路，并保留串行默认与跨进程槽位。调度/清理由 backend lifecycle 负责，SwiftUI 仅发起或取消业务任务。

尚无证据支持减少 Mathlib 导入、改变候选证据或按固定 Top-N 截断。新样本的 repair 输入达 71k tokens，后续研究应优先解释 prompt 证据重复与声明依赖的表达成本；任何正式 Prompt 或候选组织策略需另行确认。本次没有改变正式流程或可信边界。
