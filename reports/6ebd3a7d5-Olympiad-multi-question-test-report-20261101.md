<!-- Source: local experiment archive; paths and email addresses sanitized -->

# 极简 Lean 奥赛题实测记录

日期：2026-11-01  
环境：Mac / Lean 4.34.0 / 当前锁定 Mathlib runtime / DeepSeek Flash

## 本轮题目与结果

| 题目 | Lean 整题结果 | 局部来源步骤 | 当前结论 |
|---|---|---:|---|
| 2024 全国高中数学联赛二试 A3（3×n 棋盘染色） | 未通过整题 Kernel | 2 / 17 | 翻译不完整；有 4 个已 Kernel 验证的来源辅助引理 |
| 2025 全国高中数学联赛二试 A2（幂和不等式） | **整题 Kernel 通过** | 不适用 | kernelVerified=true、formalProofCertified=true、additionalAxioms=[] |
| 2023 全国高中数学联赛二试 A2（好数与 Fermat 数） | 未通过整题 Kernel | 1 / 23 | 翻译不完整；有 1 个已 Kernel 验证的来源步骤 |
| 2024 CMO 第1题（递推数列最终周期） | **整题 Kernel 通过（直接模块编译）** | 0 / 18 | 锁定命题通过；additionalAxioms=[]；originalProofCertified=false |
| 2025 BMO2 Q4 | **整题 Kernel 通过（完整模块 + 独立复核）** | 5 / 7 原文理由对应 | 2 / 7 使用替代推导；不冒称原文逐步等价 |

### 2025 高联 A2 的验证边界

完整锁定命题已由 Lean Kernel 验证，且没有额外公理。来源步骤审阅结果为：

- 5 / 7 步与原文理由相符；
- 2 / 7 步使用了能推出相同中间结论的替代推导；
- sourceEquivalenceCertified=false、originalProofCertified=false。

因此应计为“原题命题的 Lean 形式证明通过”，不应冒称“原文每一步已被形式化等价证明”。来源语义对应关系是单独的证据维度，不把无法绝对保证的语义一致性当作 Kernel 证明的替代物。

### 2024 CMO 的 AI 修复进度

- DeepSeek 首次生成的完整证明有 Lean parser 缩进错误，最初定位在第 406 行。
- 后续 10 次真实 DeepSeek 补丁请求中，9 次产生并应用了补丁，共应用 10 处精确局部修改；第 10 次没有提出可应用补丁。
- parser 错误位置由第 406 行推进到第 474 行，说明 AI 修复确实改变并推进了代码，但尚未通过。
- 随后另发起一次短上下文的定点 AI 修复请求，API 返回 HTTP 402，因此没有拿到模型补丁。
- 后续由 Lean 诊断驱动完成局部修复：修正第 468–478 行和第 666–724 行的布局；修复有限状态循环证明中的兄弟声明作用域；纠正 Fin.val、整数/实数 coercion、集合成员合取投影、冗余 tactic 和递推下标同余。
- 这些修复没有改变锁定命题，也没有增加数学假设。最终 proofTerm SHA-256：`ea8b43abd1cb4e34f6c9ab71a19b5a5e3446d84826de6b43b1d913bc7c49d6f3`。
- 最终直接模块编译结果：verified；Lean Kernel 通过；requiredAxioms 为 `propext`、`Classical.choice`、`Quot.sound`；`additionalAxioms=[]`；`sorryAx` 不存在；`runtimeReturnCode=0`。
- CMO 的完整 `verify_whole_original` 集成回放也通过，状态 `whole_formal_kernel_verified_source_unconfirmed`。该回放使用已保存的 proofTerm 和 fixture provider，不代表本轮重新生成了数学证明。
- CMO 18 个来源标记均通过结构校验，但独立来源步骤形式证明仍为 0 / 18；`originalProofCertified=false`、`sourceEquivalenceCertified=false`。整题命题 Kernel 通过，不等于原文每一步语义等价已被证明。


### 大型单体证明的直接模块验证路径

此前 `check_many_with_probes` 会把整题 proof expression 导出为 JSON wire 数据。对 CMO 约 75 KB 的 proofTerm，Lean 实际调用栈进入 `Lean.Json.compress_go`，内存峰值显著上升，序列化过程成为瓶颈，而非 Kernel 数学判定本身。

新增 `check_monolithic_whole_proof`：由主机先冻结完整命题，再将单体 proofTerm 直接编译成 Lean module，并对最终 theorem 执行 `#print axioms` 审计。若该路径未通过或本地服务不可用，原有独立 proof-export 路径仍继续，不构成阻塞 Gate。

已完成的真实验证：

- CMO 2024 P1：直接模块编译 verified；在全新 `JJ_DATA_DIR` 再次 verified；完整 `verify_whole_original` 集成回放 verified。
- 2025 高联二试 A2：同样通过直接模块编译；在全新 `JJ_DATA_DIR` 再次 verified；完整 `verify_whole_original` 集成回放 verified。
- 2025 BMO2 Q4：此前完整模块编译与独立 Kernel 复核均 verified。

两道单体证明在直接模块审计中均只有 Lean 标准公理 `propext`、`Classical.choice`、`Quot.sound`，额外公理为空。集成回放使用已保存候选和 fixture provider，仅验证工程路由，不计作新 AI 生成。

工程修改：`backend/lean_module_program.py`、`backend/lean_first_whole.py`；新增单体模块验证及拒绝后回退测试。回归：`pytest -q tests/test_lean_first_*.py tests/test_lean_module_program.py`，结果 **173 passed, 1 skipped**。

## DeepSeek 服务阻塞

已用真实 API 请求单独核实，当前 DeepSeek 服务返回：

HTTP 402 — Insufficient Balance

这不是 Lean 数学错误，也不是本地编译器故障。2024、2023 两题在来源辅助引理重组阶段也因同一 402 错误停止；两题的已验证来源引理及诊断均已保存。

### 本轮请求量与效率信号

| 工作流 | 成功请求数 | 输入 tokens | 输出 tokens |
|---|---:|---:|---:|
| 2024 CMO 第1题 | 31 | 648,414 | 338,886 |
| 2024 高联 A3 | 23 | 131,724 | 443,343 |
| 2023 高联 A2 | 26 | 229,657 | 376,005 |
| 2025 高联 A2 | 4 | 17,264 | 59,067 |

CMO 的 10 次增量补丁请求单独消耗 340,214 输入 tokens、2,156 输出 tokens。原因是每次补丁请求都携带了完整的大型证明，而模型大多只返回一个局部缩进修正。这是明确的 token 效率问题；下一轮应优先实验只向模型提供真实诊断附近的精确源码窗口，由主机在完整证明上校验唯一锚点，再交 Lean 复核。该项目前是工程优化建议，尚未写入正式产品行为。

## 回归测试

- 增量修复、模块修复、来源步骤恢复、来源步骤组合等定向测试：57 passed。
- 全后端测试：1171 passed, 6 failed, 73 skipped。
- 失败项中，5 项明显仍断言已归档的旧 API 状态码或旧 schema 2.0；另 1 项断言 provider 失败时 Job 必须为 failed，而当前 Job 状态为 completed，需要单独核对当前 Job/Result 状态契约。
- 73 项跳过主要因为对应测试要求的 source-matched isolated Lean runtime 未就绪；不能把跳过计为通过。

## 可复核记录

- BMO2-2025-Q4-DeepSeek-autonomous-incremental-repair-report-20261101.md
- BMO2-sixth-live-AI-patch-proposal-before-Lean-20261101.json
- BMO2-seventh-live-AI-patch-proposal-before-Lean-20261101.json
- BMO2-seventh-real-AI-patch-Lean-result-20261101.json
- gaolian-2024-r2-q3-full-workflow-20261101.json
- gaolian-2025-r2-q2-full-workflow-20261101b.json
- gaolian-2023-r2-q2-full-workflow-20261101.json
- cmo-2024-p1-full-workflow-20261101.json
- cmo-2024-p1-direct-module-v2-Lean-result-20261101.json
- cmo-2024-p1-direct-module-v2-proof-20261101.lean
- cmo-2024-p1-integrated-whole-pipeline-20261101.json
- gaolian-2025-r2-q2-integrated-whole-pipeline-20261101.json
- multi-proof-direct-module-crosscheck-20261101.json
- run-cmo-whole-pipeline-integration-20261101.py
- run-gaolian-2025-a2-whole-pipeline-integration-20261101.py
- cmo-2024-p1-parser-repair-next-AI-20261101.py
- check-deepseek-balance-20261101.py

## 续跑位置

1. CMO 2024 P1：整题命题已 Kernel 通过；保留 18 个来源标记及 source-equivalence 未认证状态，不再从旧 parser 错误位置续跑。
2. 2024 高联 A3：从 4 个已验证来源辅助引理及 2 / 17 局部证据继续重组。
3. 2023 高联 A2：从 1 个已验证来源步骤继续重组。
4. 2025 高联 A2、2025 BMO2 Q4：整题 Kernel 通过结果保留；不把来源语义未认证误报为 Kernel 失败。


## 独立 Kernel 复核

- 2025 高联 A2：在独立新 Lean 数据目录中重新提交同一锁定命题与 proofTerm，结果仍为 verified；statementMatched=true、additionalAxioms=[]。
- BMO2：在独立新 Lean 数据目录中重新编译完整 supporting module 与最终 proofTerm，结果 verified；statementMatched=true、additionalAxioms=[]、runtimeReturnCode=0。复核记录：BMO2-fresh-independent-kernel-recheck-20261101.json。
