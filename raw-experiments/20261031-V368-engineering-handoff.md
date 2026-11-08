# 2026-10-31 极简 Lean 本轮研究记录（V3.6.8）

本文件记录真实结果，不把合成回归场景当成新奥林匹克题的通过，不增加新产品 Gate、限额或发布门槛。

## 版本与隔离

- 研发源：`~/Documents/ChatGPT/极简lean 2/jijian-lean-backend-v2`
- 研发提交：`b5437ac (仅新增研发回归测试；V3.6.8 签名研究版核心代码已包含此前全部修复)`
- 签名研究 App：`~/Documents/ChatGPT/极简lean-ui-loader-release/dist/极简 Lean.app`，V3.6.8
- 签名研究构建源码：`3523981f26f2f0ebb4447ad10916d05bbf3f1df9`
- Mac 用户正式安装版：`~/Applications/极简 Lean.app`，未主动替换安装版本。

## 已实测成功的功能

1. **同一失效 Mathlib API 被使用 9 次**：实际 Lean/Mathlib 原候选 9 个错误、Kernel=False；自动检索并由 Lean #check `ZMod.natCast_eq_zero_iff`，替换 9 处后真实 Kernel=True，0 个编译错误；模型调用 0 次。原始证据：`real-nine-duplicate-obsolete-zmod-api-kernel-result.json`。合成证明结构针对真实 BMO 错误类型，不等于 BMO 整题复测通过。
2. **真实签名 App V3.6.5 端到端**：历史 2024 BMO1 Q5 相同原文，事先保存已通过的相同原文 Lean 证明，经 `/api/v3/jobs` 重放，Kernel=True，AI requests=0，耗时 43.83s，source steps=11。这是可靠的历史证书复用而非新模型重新生成。
3. 历史已通过的四份 BMO／高联证明，从缓存中重新交给当前真实 Kernel 均通过 4/4，0 DeepSeek 请求。证据：`four-exact-source-cached-kernel-replay-results.json`。
4. 2024 高联几何初次模型输出 `import + def formalStatement : Prop`：确定性展开为 Prop 并修正 3 处 `inner ℝ` 记法后，当前真实 Lean typecheck=True，0 错。证据：`geometry-original-goal-single-decl-unwrapper-real-Lean.json`。通用处理已写入 V3.6.6+。
5. 回归全集：6 failed, 1100 passed, 72 skipped, 1 warning in 118.38s (0:01:58)，仍存在先前已知的 6 个旧 V2 接口/工作流失败；此次未新增测试失败。

## 未通过和待解决的真实问题

- 原四道新竞赛题 V3.6.2：仍 0/4 完整 Kernel 通过，不能改写为 4/4。
- 2024 BMO1 Q5 原文在 V3.6.3 下**不采用缓存**、重新生成时 11 次真实 DeepSeek 请求，Kernel 未通过。生成的分段 Lean 出现 9 处旧 `ZMod` API 不存在和其他未闭合目标；当时软件没有保存生成的完整分段候选。V3.6.5 已修复保存和自动 checked API 替换；该原真实模型候选已无法离线追回，不得伪造结果。
- 2024 高联二试 Q2 几何 V3.6.5 重新生成：真实 DeepSeek 3 次，46,158 输出 token；直接进入 `source_proof_scaffolding` 后任务 `INTERNAL_ERROR`，异常类型 `error`（推断可能是 `re.error`，未取得 Python traceback，所以不能确定异常发生的精确函数）。未获得 Kernel 结果。V3.6.7-3.6.8 新增模板保存、正则解析异常分类与未验证响应持久化；目前通过模拟异常测试，但尚未在同一个模型输出上真实复现并完成数学证明。

## 技术原则

- 不把不可保证的自然语言语义完全等价当作整个产品的阻塞条件；真正的形式命题证明仍以独立 Lean Kernel 为准。
- 已验证历史证明复用与新的 DeepSeek 再生成必须区分计数。
- 再次真实测试时优先复用保存的模型候选和编译诊断，避免无意义重复请求；不禁用普通正常 DeepSeek AI 路径。
