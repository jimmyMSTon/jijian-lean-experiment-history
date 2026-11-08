# Lean-first V3.5.1：BMO2 复杂证明分层判定攻坚报告

## 2025 BMO2 原始完整证明测试（V3.4.2）

四题真题的完整原稿和结果在 `~/Documents/ChatGPT/极简lean-review/2025-BMO2-V342-四题真实全线验证/`。其中 Q1 的伪证明有错误等式、Q2 几何、Q3 棋盘操作、Q4 数论递推的完整证明自动形式化均没有整篇 Kernel 成功证书。

V3.5.0 真实新功能已从正式原稿验收：Q1 的一个错误等式获独立 Lean 否定证书；Q3 锁定命题先前无效的 Lean 声明已改写为单个可成功 elaboration 的 Prop，仍没有编译出整篇棋盘证明。

## V3.5.1 通用改造（非特定真题特判）

- 新 `backend/lean_first_step_diagnostics.py`：整篇证明转换不完整时，由真实 DeepSeek **一次结构化请求**尝试将每个已锚定来源步骤转成单独闭合 Prop 与 `by` 项，批量送 Lean Kernel 复核。严格拒绝引文漂移、不完整索引、前置依赖索引错误、True 空洞形式命题、禁用命令。可表示 `complete=false` 并对原稿子串形式化某个明确原子断言。不把成功的局部命题合并成整题或原稿已验证。
- 通用校正真实 `LeanRunner.check_many_with_probes` 回包格式：Kernel 返回按输入顺序排列的复核字典，但**不含 stepId**。恢复按有序一一对应，若额外返回 stepId 则仍检查是否与原请求相符；还必须有 `status=verified`、`localVerified=true`、`certificate.checked=true`、`certificate.statementMatched=true`、`additionalAxioms=[]` 才计通过。修复之前的“源文本证书虽然 Kernel 通过，但本工具误判回包不匹配”。
- 新 `backend/lean_first_atomic_algebra.py`：只有**原稿明确写“代数恒等式／展开”等来源理由**且一般局部转换没有得到任一证书时，额外一次真实 AI 请求仅**精确摘录并编译原稿已有多项式等式的闭合 Lean 命题**。Lean proofTerm 不是 AI 生成，而由代码固定为 `by; intros; ring`，真正独立 Kernel 复核。由不属于原文的等式产生不了原子证书，也不会被算作对应段落全通过。
- 正式 Mac SwiftUI 的状态、失败检查和可导出报告分别显示：整篇 Kernel 是否通过、各段局部命题是否通过、每个原稿内原子等式是否通过，精确区分 Kernel 证书与人工自然语言语义认证。未通过步骤仍为待验证。

## 真实 Q4 递推样本实验（全部运行于真实 Lean/DeepSeek 环境）

1. 全六段局部诊断：1 次 DeepSeek 请求；输入 **2,963**、输出 **13,805** tokens，约 64.92s；6 段均仅给出声明/缺口，无独立 Kernel 通过。
2. 增加 `atoms` 字段后的单轮：1 次 DeepSeek 请求；输入 **3,333**、输出 **14,905** tokens，约 73.51s；模型仍未主动返回原子公式。
3. 在来源限定的恒等式提取路径上，1 次真实 DeepSeek 请求；输入 **2,298**、输出 **4,106** tokens，约 63.27s；独立找到 Q4 原文第四步精确子串：
   `b²F(d)=(bd)²+b(bd)+b²`
   并输出与原文一致的闭合形式命题
   `let F : Nat → Nat := fun t => t ^ 2 + t + 1; ∀ (b d : Nat), b ^ 2 * F d = (b * d) ^ 2 + b * (b * d) + b ^ 2`。
4. 用固定 `by; intros; ring` 真正送 Lean4/Mathlib：独立真实 Kernel 回包 `status=verified`、`localVerified=true`、`certificate.checked=true`，`statementMatched=true`、`additionalAxioms=[]`，0 errors。按原提取候选回放到修复后的 `inspect_source_algebra`，得到 `atomicFormalVerifiedCount=1`、`wholeFormalProofCertified=false`，无新的模型费用。区分“保存原真实模型结果重新核验”与“正式 App 从中文再次全流程调用”。

凭据目录：
- `~/Documents/ChatGPT/极简lean-review/2025-BMO2-Q4-real-source-step-fallback/`
- `~/Documents/ChatGPT/极简lean-review/2025-BMO2-Q4-atomic-source-diagnostics-live/`
- `~/Documents/ChatGPT/极简lean-review/2025-BMO2-Q4-real-atomic-identity-kernel/`

## 数学和产品能力严格边界

**整篇 BMO2 Q2/Q3/Q4 仍没有 Kernel 完整证明证书**。单个 `ring` 恒等式通过不能证明 Q4 最关键的同余、整除、互素不变量、强归纳和答案 2026，不能夸大为“BMO2 形式化已攻克”。模型对数学原稿到 Lean 命题是否完全忠实的确认不是 Kernel 能做的；不得将模型来源审计或源码内的精确引文锚点视为自然语言语义等价证书。

正式版以后只报告证书级别对应的准确结论；真实失败、成本和程序缺陷继续保留。
