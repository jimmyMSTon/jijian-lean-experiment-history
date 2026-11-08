# 极简 Lean：非 CMO 泛化攻坚任务

用户最新目标：除 CMO 之外的奥林匹克级证明（包括高联二试、BMO）尽量全部实现真实 Lean Kernel 自动通过，不能针对固定题目拟合式修复。必须真实泛化并保留失败证据。

研发 Git repo：本目录，主要源码 jijian-lean-backend-v2/；当前 branch research/long-proof-compiler-20261031，HEAD b98fd42。Mac 实验记录在 ~/Documents/ChatGPT/极简lean-review/。此前完整记录：20261031-V368-engineering-handoff.md 和 gaolian-2024-r2q2-V368-parser-recovery-real-live。

具体工作：
1. 以真实失败样本和程序本身理解根因，而非只写 benchmark 适配代码。最新 2024 Gaolian R2 Q2 原始真实 DeepSeek scaffold 产生 theorem wrapper、1-based source markers，b98fd42 已做通用修复（真实缓存候选通过结构校验，未进入填孔/Kernel）；较早的 2024 Gaolian R2 Q1、Q2、Q4 及 BMO 各年份也有真实失败记录。全面梳理失败的可修通用类型。
2. 实现真正可泛化的数学证明 -> Lean4/Mathlib 自动编译和分解/Lean feedback repair 改进。优先解决“原模型返回部分证明/模型返回非法模板/修复过程无法推进”的一般性问题。不要针对任何题目 ID、年份、数学常数、模型答案或模板预存定理增加特判。不要替换用户给定命题，不允许 sorry/admit/axiom/native_decide/unsafe、假设结论、虚构/偷换来源步骤、降低题目难度/范围。
3. 对每个修改写可重复单元与真实 Lean 集成验证；整题成功只在真实 fresh Kernel 完整命题 certificate 且没有伪装缓存时承认，模型自评和局部 lemma 不算整题。保留全部未验证/失败输出。
4. 做独立未见题型/跨年份测试，尽量运行真实 DeepSeek + Lean（没有被用户禁止真实 AI 请求）。不同任务的缓存复用要明确；不可把 fixture、重放或人工形式化说成新的自动泛化成功。
5. 不新增用户未明确确认的产品 Gate、次数限制、验收门槛、状态机约束、固定预算、额外发布审核、模型离线开关。保留 DeepSeek V4.1 Flash 真实正常业务调用。不得覆盖用户正式安装的 App。
6. 回归已有通过案例防止退化；不要把 legacy V2 已知的 6 项 pytest failures 伪称新故障，也不要为通过测试而改测试期望。
7. 修改源码、运行实测、提交 Git，保存可追溯报告在 ~/Documents/ChatGPT/极简lean-review/20261031-generalization-codex-evidence.md；清楚列出 fresh unseen 通过率、所有失败、遗留问题、commit、原始测试路径。达不到目标必须如实报告，绝不能宣称成功。

可参考真实案例：~/Documents/ChatGPT/极简lean-review/olympiad-20261031-four-unique-V362-real-live、~/Documents/ChatGPT/极简lean-review/2025-BMO2-V342-四题真实全线验证、~/Documents/ChatGPT/极简lean-review/gaolian-2024-r2q2-V368-parser-recovery-real-live。

从现有工作继续，不重复推倒已有成功版本。开始实做，不要只给方案。