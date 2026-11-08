# 极简 Lean 非 CMO 泛化攻坚记录 — 2026-10-31 15:45（北京时间）

## 本轮目标
高联二试及 BMO 的人类证明自动转成原命题 Lean 证明并交由真实 Lean Kernel 审核。不得把 CMO、历史精确缓存重放、模型自评、模拟测试、人工独立定理证明或较弱命题当作新通过；不可通过题号/常数定制补丁拟合。错误的原证明不能被强行判为正确。

## 实际工程提交
- `3e678f7`：提取 theorem/lemma 包装中的证明体，最终仍用原冻结命题检查。
- `d957a31`：当模型认为 whole proof 不完整时，若候选确实保留全部来源步骤，允许实际 Lean 诊断和局部修补；修复后仍以完整固定命题 Kernel 检查。
- `094583e`：模型在 scaffold 阶段提前输出完整来源标记的证明项时，保留为待认证候选，不再仅因缺 JJ_SOURCE_HOLE 而丢弃。只给出候选，不自动计成功。
- 主研发分支：`research/long-proof-compiler-20261031`；HEAD `094583e`；未覆盖正式安装的 App。

## 真实测试证据
1. 2024 BMO Round 1 Q5：在全新独立数据目录、源 revision `3e678f7` 的实际 DeepSeek + Lean 全链路测试中得到 `kernelVerified=true`、`formalProofCertified=true`、`originalProofCertified=false`。13 个来源步骤；4 次真实 AI 请求；Lean Fresh Kernel 证书包含 `statementMatched=true`、`additionalAxioms=[]`。没有 `proofCacheHit` 标志，也没有运行精确缓存重放阶段。它是已知测试题的 fresh model regeneration，并非未见题型首次成功。
2. 使用正式已认证 Lean 4.34/Mathlib runtime 对真实 Runner 集成测试复验：2 passed（原先一个因缺 source lock 而跳过的测试已运行并发现/修复实际 bug）。无模拟 Lean 代跑。
3. HEAD `094583e` 的 pytest 全量：**1110 passed、6 failed、73 skipped、1 warning**。6 failed 与此前旧版 V2 API/结构接口不一致的已知失败相同；不宣称全量无失败。
4. 高联 2024 R2 Q1/Q2/Q4 的 fresh API battery、BMO2 2025 Q4 的 fresh battery：**此记录写入时尚未取得终态**，不能宣称通过或失败。以上测试均为独立数据目录，无 mockFallback，真实 DeepSeek 与 Lean；测试运行固定 revision 为 `3e678f7`，不是新 HEAD `094583e`。完成后的逐题终态以自动生成的 JSON 为准。

## 原始记录位置
- 高联三题日志：`~/Documents/ChatGPT/极简lean-review/olympiad-20261031-nonCMO-V369-source-fresh-real-runtime.log`
- 高联三题目录：`~/Documents/ChatGPT/极简lean-review/olympiad-20261031-nonCMO-V369-source-fresh-real-runtime-live/`
- BMO 两题日志：`~/Documents/ChatGPT/极简lean-review/bmo-20261031-two-unique-V369-source-real-runtime.log`
- BMO 两题目录：`~/Documents/ChatGPT/极简lean-review/bmo-20261031-two-unique-V369-source-real-runtime-live/`
- 已通过 BMO1 Q5 原始终态：上述 BMO 目录中的 `bmo1-2024-q5-terminal-job.json`。
- 全量回归：`~/Documents/ChatGPT/极简lean-review/generalization-full-regression-094583e-20261031.log`
- 独立工程证据：`~/Documents/ChatGPT/极简lean 2/GENERALIZATION_REPAIR_EVIDENCE.md`

## 结论
已取得真实非缓存 BMO 整题 Kernel 通过和一组跨样本通用修复，但尚未达到“CMO 以外全部通过”的目标。不得用测试尚未结束或部分改进冒充整题泛化成功。
## 15:46 增量结果（必须计入失败）
- **Gaolian 2024 R2 Q1**：固定源 revision `3e678f7` 的新隔离测试已正常完成，但 `whole_proof_translation_incomplete`，`kernelVerified=false`，7 个原稿步骤尚未整体证明。真实 DeepSeek 12 次请求；输出 tokens 202,350；约 1,082 秒。此次必须计为失败，不能因为编译器有所修复而掩盖。其逐题证据已写入高联测试目录的 `gaolian-2024-r2-q1-terminal-job.json` 与 `gaolian-2024-r2-q1-summary.json`。
- Gaolian 2024 R2 Q2 已自动开始；BMO2 2025 Q4 已进入 whole_proof_translating，均未获得终态。
- 上述真实 battery 是 revision `3e678f7`，最新研发源 `094583e` 的新增 partial-proof & completed-scaffold 恢复仍需另行真实复测；本轮不得把两种源码版本的结果混合。
