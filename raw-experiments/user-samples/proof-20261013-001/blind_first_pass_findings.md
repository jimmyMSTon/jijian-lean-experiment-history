# 真实用户证明样本 2026-10-13｜第一次盲测结论

## 样本
- 问题照片原件 SHA-256: 4a0ab1ef8edff48bff3017fd68d282d4e781f83ac38a2e403e524b216311c5fd
- 手写证明原件 SHA-256: a5f25c2e34a2c89f566af68931e455285785ad3e9d834d049e59b2cec0f3d530
- 本地 Mac 当前只有人工根据照片重建的 `blind_transcript_approx.txt`。原始 JPEG 仍在 ChatGPT 当前会话附件/容器中，**尚未自动进入 Mac**；不允许把此轮记录称为真实视觉模型识别通过。
- 本轮没有给 DeepSeek 模型任何参考答案、错误位置或修订后的证明。独立评价留待结构数据/模型输出固定后单独比对。

## 实际调用
- 使用用户配置的 DeepSeek V4.1 Flash (API model: deepseek-flash)，正常 Provider/default Thinking 不变。
- 只运行一次 `MathIRV2Service.structure`：1 次真实 DeepSeek 请求，0 网络重试，0 Mathlib、0 Repair、0 Lean/Kernel。
- 3517 输入 tokens，44146 输出 tokens，HTTP 176065.949 ms；这是实际用户级复杂结构化任务，不是缓存重放。此指标暴露显著延迟成本。
- 结构化返回了 MathIR v2 草稿，但确定性校验在 `assumptions[0].expression.binderId` 拒绝：`V2_BINDER_UNKNOWN` / `bind:m_cond`。AppError=MATHIR_V2_INVALID。该错误是模型结构/类型契约问题，不能算学生原数学证明错误。
- 已永久保留独立样本 SQLite 中 `mathir_v2_draft` 一条，原始 provider usage/audit 以及盲测输入文本与哈希。定位：`/[LOCAL_USER]/Documents/ChatGPT/极简lean-review/user-samples/proof-20261013-001/isolated_backend_data/backend.sqlite3`；结果 `/[LOCAL_USER]/Documents/ChatGPT/极简lean-review/user-samples/proof-20261013-001/blind_text_structure_result.json`。

## 离线根因分层
在存储的 Draft 上执行纯结构遍历，无额外模型请求：
- 28 个原稿路线节点、28 个 SourceRef 记录（仅数量，不意味着全都忠实或范围有效）。
- 6 个量词 binderId 未声明，同时相应 6 组 symbolId 指向缺失 ID：`bind:m_cond`, `bind:n_cond`, `bind:n_goal`, `bind:n_conj`, `bind:n_defP`, `bind:k_hyp`。
- 56 个 `eval` 节点使用了 1 个参数，且附带 `symbolId=decl:a`；当前 Typed MathIR 的 `eval` 只允许 Polynomial.eval 的两参数形态；`MathType` 不支持 Nat→Real 一般函数或 Sequence 类型。模型把数列 `a_n` 强行表示为非法 Polynomial.eval，**不能**通过补某一个 binder 或删除原稿步骤来伪造成功。
- 此草稿还尝试用 `decl:a : Real` 表达原题的数列 `a : Nat → ?`，数学类型不符。完整证明含二阶递推/较强归纳，属于需要通用索引函数表示的真实能力缺口。
- 存在一次 `NatLowerBoundInduction lowerBound=0`，但学生应用 `a_n=2a_(n-1)-a_(n-2)+2` 时须处理 n≥2 的合法索引范围；应由来源忠实性检查单独评价，不允许模型改写原归纳段以掩盖缺口。

## 交付给数学后端的下一步
1. Codex 在自己的独立 branch 对当前 schema/typechecker/compiler 支持一般数列索引表示做**通用数学类型**设计；不得为 `a_n=n²` 单题硬编码或滥用 Polynomial.eval。
2. 不能只消除首个 `V2_BINDER_UNKNOWN`，否则 56 个不合法 eval 还会阻断；准确区分无法表达与生成错误。
3. 先用此保存 draft 做离线确定性回归，不再次调用 DeepSeek；再在通过结构和来源锁后决定是否值得进一步付费跑真实 Proof/Lean/Kernel。
4. 中文/手写原文与 MathIR 语义等价依旧不由 Kernel 自动证明，本次用户原证明尚未经过 Lean，不允许显示 verified。
5. 如果需要真实图片 → Vision model 的新鲜端到端，必须先将原始上传 JPEG 的确切 bytes 安全移交 Mac；目前这一项有输入文件交接阻断，别用人工转写假装 OCR。

*注意：这份报告是已完成的模型盲测与确定性代码审计，不包含给 Provider 的数学参考答案。*
