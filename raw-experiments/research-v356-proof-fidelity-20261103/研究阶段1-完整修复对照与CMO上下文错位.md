# 极简 Lean：V3.5.6 恢复后的第一阶段实证研究
日期：2026-11-03 至 2026-11-04（北京时间）
范围：BMO 原题同证明候选的完整修复/局部补丁对照；2018 CMO 第五题源步骤编译错位。
研究证据，不是正式产品规则或未经确认的发布/验收条件。

## 一、研究环境与隔离
- 生产桌面软件保持恢复的 V3.5.6，签名安装包未修改。
- V3.5.6 源码：c37bfb5873e41a686271785d7ee2c717afaa08b2。
- 研究分支：research/v356-repair-causal-and-source-check-20261103，独立 Git worktree。
- Lean：v4.34.0，V3.5.6 runtime 8ed0581c17efdbc6c9f64ccb66dad3768b4feb21ce25f501aab79b229e7443bd。
- DeepSeek：deepseek-flash，使用当前真实 API；没有模拟。历史/新请求 systemFingerprint 都是 bc19ba97cbe016479903222bb1578db6。

## 二、同一数学输入、同一 Lean 候选的因果对照
样本：2024 BMO1 Q5。
原稿 SHA-256：a14959b2d283da18780f7015681ba9b45b6219ca0855d6e6b98fb4a73c0a2a39。
被测试的原始程序：V3.6.3 当时由 DeepSeek 生成、尚未修复的整篇 proofTerm。
程序 SHA-256 前 12 位：1a097e6d1b09。
冻结命题：V3.6.3 的 locked statement（原文未改），两组条件完全相同。
经 Python 比对：source SHA、formalStatement、original proofTerm 三项 **逐字相同**。

A. 先在 V3.5.6 LeanRunner 上重放两份已有证明：
- V3.5.6 旧完成代码 + V3.6.3 新冻结命题：Kernel 通过；statementMatched=true；additionalAxioms=[]。
- V3.6.3 原始未修复程序 + 相同冻结命题：13 个编译错误；首个缺少 Mathlib 声明 ZMod.natCast_zmod_eq_zero_iff_dvd。
结论：新版命题本身可以被旧证明证明，问题不是新目标不可证明。

B. 从同一 V3.6.3 **原始失败程序**出发比较修复路径：
| 方案 | AI 修复请求 | 错误数量轨迹 | 修复阶段 tokens | 最终 |
|---|---:|---|---:|---|
| V3.6.3 历史 LeanProofPatchBatch 局部补丁 | 6 | 13→5→6→2→2→3→3 | 43,848（输入 39,199，输出 4,649） | 未通过 |
| V3.5.6 真实 LockedProofRepair 整篇修复（本轮） | 4 | 13→10→10→1→0 | 106,770（输入 29,153，输出 77,617） | **Kernel 通过** |
两边 repair response 均来自 deepseek-flash、同一 systemFingerprint；历史与本轮调用时间不同且模型输出有随机性，所以这是强单样本证据，不是严格证明所有题型都应采用整篇修复。
新证书：fresh_environment_data_only_kernel_replay，checked=true，statementMatched=true，额外公理 []。形式化整个命题通过，但没有独立自然语言原稿语义认证。
全修复成功候选 SHA-256：5a1e446dfff075b5a0b9a35da3663f4d52617a74ca620e21676f0af3b3882d2e。
注意比较的是 **修复阶段**，不是从识别到终稿的全部产品成本。旧修复消耗更多 tokens，但成功；局部补丁成本较低但失败。

## 三、另一个不容忽视的长期失败根因：CMO 2018 P5
保存的真实 DeepSeek 模板是按照 source_step_0..20 编号的 21 个原稿步骤，20 个片段生成了内容但整篇仍未完成。
在 17、18、19 号上发生了真实的原稿/形式命题索引偏移：
- 来源 17：“若 t=0 ...至少 n-1 个 1”；对应 frozen Lean 却是 Bbad 初始矩阵行列和信息。
- 来源 18：“若 t=1 ...至少 n 个 1”；对应 frozen Lean 却是 t=0 分支的“n-1 个 1”，且只假设所有行和为 0，漏了列条件。
- 来源 19：“无论如何最终 ... N(n)=...”；对应 frozen Lean 却是 t=1 分支的行条件。
新编译器 scaffold_issue 实际接受此错位模板（返回 None）：现行结构核查检查编号/孔位/禁止项，不能核查数学含义是否和来源编号匹配。
独立 Lean 反例：取 n=3，Y=0，原 scaffold source_step_18 的“只知道行和为 0 就推出至少 n-1 个 1”是假的。已保存 Lean 证明 negation，#print axioms 仅有 [propext, Classical.choice, Quot.sound]，没有额外公理。
**这不反驳 CMO 正确原证明**，仅反驳 DeepSeek 生成的错误局部形式命题。
因果：错误数学义务已经冻结，后续任何局部 tactic 修补都无法把假命题变真。应先修复翻译/上下文错位，而不是无休止提高修补轮次。

## 四、当前结论与不确定性
1. V3.5.6 的完整证明修复能力可用于救回后来失败的真实奥赛候选，这次已从“历史结果对比”提升为“同一原始证明候选的受控对照”。
2. 在这个样本中，旧完整修复以更高 token 成本换取了真正的完成能力。不能据此声称其在所有题上更省钱或万能。
3. DeepSeek 本身生成了不存在的 Mathlib API，属于模型输出问题；但同一模型指纹下旧修复路径成功，说明不能把最终失败只归因于模型。
4. CMO 长证明的关键问题是原稿步骤 → Lean 命题的内容/依赖漂移，不能靠修复 Lean 编译错误解决。
5. “整题 Lean Kernel 证明通过”仍不等于“原稿所有自然语言推理步骤通过”。恢复的 V3.5.6 继续诚实区分两种状态。

## 五、可选研究方向（不实施为正式产品规则）
- **建议**保留完整证明修复路径，比较是否把局部补丁作为非替代性的另一路可选能力。原因：本次证实完全替换会丢失真实能力；影响：更强的恢复能力可能伴随较高 token 成本。
- **建议**在源步骤形式化时提供独立的“原稿片段、形式命题、依赖”对照诊断，遇到内容明显偏移应回到形式化层修复而非执行不可证明的 tactic。原因：本次 CMO 已由 Lean 证实生成的义务本身为假；影响：会增加表示层检查，需要避免新增未经用户确认的阻塞条件。
- **建议**对不同奥赛题重复同候选 A/B 对照，形成跨题型证据，不能把单题经验提升为泛化结论。原因：模型非确定性且成本不同；影响：会产生更多实测 DeepSeek 请求。

## 六、证据文件
位于研究目录 research-v356-proof-fidelity-20261103：
- cross-replay.log：旧证明在新 goal 下真实 Lean 通过；V363 原始证明真实 Lean 13 个错误。
- v363-initial-candidate-with-v356-full-repair-result.json：4 次真实模型修复、全候选与每轮 Lean 诊断、usage 及最终 Kernel 证书。
- legacy-whole-repair-live.log：真实调用过程日志。
- cmo2018p5_scaffold_step18_counterexample.lean：反驳错误 CMO scaffold step 的可重编译 Lean 代码。
- cmo2018p5_scaffold_step18_counterexample.lean.log：Lean 成功和 axioms。
- cmo-scaffold-source-index-mapping.json：用户原稿步骤与冻结 Lean proposition 的逐项对照。
- v363-rescued-proof-fresh-kernel-replay.json：后续独立重复 Lean 验证结果。
