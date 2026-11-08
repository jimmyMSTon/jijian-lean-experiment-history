# Lean-first V3.4：正式验收反馈后的系统性修复

## 一、问题实录
V3.3 曾在已保存原稿和模型结果上，以 **19 个原文锚点**获得一次真实、完整 Kernel 证书（来源 `v33-high-repair-mandatory/result.json`）。但是随后从签名、安装的 V3.3 正式后端 `/api/v3/jobs` **从零重复同一题**时，模型划出了 18 步、用 Fin n 表达原题，最终仅报 `No goals to be solved`，模型单轮技术修复也未成功；完整任务 `whole_formal_kernel_not_verified`，不是成功。正式版此次 DeepSeek 4 次实际请求（第 4 次失败、usage 缺失），共输入 11,027 / 输出 111,647 token，正式任务耗时 539.28 秒。无法把之前的候选回放成功当成正式重跑保证。

## 二、数学证明忠实性漏洞的反例
一条正确数学定理 `∀ n : ℤ, (3 : ℤ) ∣ n ^ 2 → (3 : ℤ) ∣ n` 的原稿推理只写了“因为 3 整除 n²，所以 3 整除 n”。V3.3 的 DeepSeek 给出一份经真实 Lean Kernel 通过的**替代完整形式证明**，补入了原稿没有写的 `have hprime : Prime (3 : ℤ)` 和 `hprime.dvd_of_dvd_pow`。这一 Kernel 证书仅确认正确形式定理，**不认证作者原推理的充分性**。早期单纯给每一步加 source_step_i 标记并不能保证没有数学补写，原稿中的“跳步”可能被模型改写。原文证据在 `v33-adversarial-generalization/invalid_modular_reason/report.json`。

### V3.4 所做的处理
- 新 `backend/lean_first_source_audit.py`：在完整形式定理获得 Kernel 证书后，增加独立的模型来源审计；每个原稿步骤必须带严格原文引文和 Lean 代码连续子串，引文不匹配立即拒绝审计，不自动视为没有风险。
- 专门要求区分普通程序层代数化简与**新增关键数学事实、取代作者理由、欠缺推理步骤**。对于数学来源缺口，状态 `suspected_proof_reconstruction_or_gap`、保留逐条证据及风险解释。没有发现具体风险的结果只能叫 `no_specific_mismatch_identified_by_model`，**绝不是“原稿证明认证”**。所有状态 `originalProofCertified=false`；Kernel 不能自动证明自然语言与 Lean 等价。
- 真实独立审计：对上述缺少素数理由的原稿，DeepSeek 模型指出补入 `Prime (3 : ℤ)` 的替代路线；完整代数证明的单独审计没有找到具体替代推理，两条均保存模型调用和引用证据。
- 原稿忠实性审计对长高联证明三次收到上游 HTTP **402（计费拒绝）**，其中一次重复因脚本环境覆写，所以审计状态保持 `unavailable`。不能宣传长题来源审计通过；服务未恢复前不再重复发起收费请求。

## 三、真实 Lean 技术修复
- 高联 V3.3 正式重跑只存在 `No goals to be solved` 的 Lean 编译错误，全部其它诊断为 warning。失败根因是前一个 tactic 已结束目标，随后程序又执行 `rw/simp/ring/linarith/nlinarith/omega/norm_num`。
- 新 `protective_tactic_guard`：仅在上游 Lean **所有 error** 均为上述明确诊断时，把这些行的 tactic 语法保护成 `all_goals <原 tactic>`，避免已解决目标报错。保留完整作者 source_step_i、整题 formalStatement、原 proofTerm、自动修改次数和二次 Lean 证书。没有 Kernel 通过，仍判未完成；其它错误不得改写。
- **真实 Lean 回放**原失败 proofTerm，经保护后得到 `status=verified`，Kernel `checked=true`、`statementMatched=true`、无新增公理。该 Kernel 回放是使用之前已有的模型候选；仍需在最新签名版做从零全线验证，不作为新一次独立 DeepSeek 泛化测试。
- 对来源不确定的代码仍运行独立风险审计；即使真实 Kernel 通过，也不自动允许原稿变绿。

## 四、产品状态和UI
- 稳定式结果分为：整篇形式证明 Kernel 通过；原稿数学理由来源审计疑似补写／未找到具体风险／审计不可用；最终原证明未取得独立忠实性认证。
- Mac 原生结果页将仅有来源锚点的步骤展示为中性，而不是误当作每项数学错误。显示真实 Kernel 证书、来源审计引用、具体技术修复来源。
- 真实模型上游 HTTP 402 时原有 Kernel 证书不会被撤销，来源审计明确为不可用，且不会编造审计成功。用户可选择自行恢复 AI 连接再重试。
- 不恢复 V1/V2，保留历史、single-flight 和请求审计，不使用全局离线 Gate 代替正常真实模型请求。

## 五、验证数据与发布原则
- 真实陌生题：代数、归纳法与整除正确样本获得整个形式定理 Kernel 证书，明显假命题与错误证明没有得到原证明认证。
- 独立对抗负样本“真命题但作者遗漏了素数理由”，V3.3 样本确实得到形式证书，V3.4 的单独真实来源审计成功准确报警。
- 自动测试覆盖来源引文一致性、模型拒绝证据、额外 Lean 理由报警、整体命题锁定及自动 tactic guard。UI SwiftUI 类型检查、全项目测试结果另行记录。
- **不能承诺任意陌生复杂证明一次通过**。任何未经真实 API + Kernel + 来源复核的状态都不得声称产品完全可用。
