# 校对识别文本 → MathIR → Kernel 闭环回归（2026-10-13）

## 目的与范围

从统一基线 `97311e7c22701e535bcd00a0c887ff9d0154a89e` 新增一条后端合同回归，针对“用户已校对的识别全文是否真的成为结构化输入和 Lean 核验来源”。没有修改 SwiftUI/Native、Provider、数学规则或现有来源恢复实现。测试使用确定性 Provider 夹具和真实隔离 Lean/Kernel，不调用 DeepSeek。

## 可复核链路

新测试 `tests/v2/test_corrected_recognition_kernel.py::test_corrected_recognition_text_flows_into_mathir_and_real_kernel` 执行：

1. Store 保存一个本地 PNG 字节 fixture 和图像 asset hash；初始 recognition 保存 raw 文本 `l = 1`。
2. 通过真实 `RecognitionService.correct` 产生不可变识别修订：首字符 `l` → `1`，结果 `1 = 1`。
3. 调用真实 V2 pipeline 的 `structure`；Provider fixture 断言其实际收到 raw=`l = 1`、normalized=`1 = 1`、对应 block Unicode 长度以及用户 correction 记录。模型输入的 block 引用精确指向 normalized 文本。
4. Provider fixture 对这个已明示结构返回 proof-only `by rfl`；没有改变 MathIR、statement、SourceRefs 或原步骤。
5. 真实 Lean 4.34.0 + 独立 Kernel 验证固定 statement 和完整原路线。最终 MathIR 保留 raw、校对后的 normalized、修订后的 block 文本及相同 assetId；structure artifact 保留 `revisionOf` 和人工 correction；从 Store 按 assetId 读回原始字节，SHA-256 相同。

本次测试结果：**1 passed，25.92 秒**。Kernel 的成功只证明夹具所给 `1 = 1` 形式命题及 proof，不证明 OCR 正确性，也不证明自然语言/图片语义与 MathIR 等价。固定 Provider 夹具不计作 DeepSeek 能力证据。

## 其余回归与边界

- 当前非实时回归：**458 passed，23 deselected，0 failed**；新增用例带 `lean_local` 标记，已单独在源码锁定 Runtime 上真实执行，并非作为 fixture-only 测试通过。
- 本轮 DeepSeek 请求 **0**、模型 token **0**、真实视觉模型请求 **0**。没有可报告的新鲜用户样本识别率、盲测数学正确率或模型 proof 能力结果。
- 目前已有 `scripts/run_mathir_v2_novel_audit.py` 的冻结哈希文本样本审计和完整 V2 结果保存能力；它不能代替用户图片、人工校对、独立答案记录及真正盲测。ChatGPT 的真实样本/独立参考结论尚未交接，故本轮不运行样本实测，也不把测试夹具称为用户验收。
- `dist` 下本轮只核验了同步主树对应的签名包，不重建、不安装、不覆盖其他 App。Native 页面/图片导入历史修改仍由 ChatGPT 负责。

## 待真实样本交接后执行

对每个样本先将原图、SHA-256、识别记录、用户 correction 和独立参考结论分别保存。首次模型请求只接触原图及用户确认后的数学来源，不接触独立参考答案；先写入机器结果与请求审计，再做盲测对照。需报告识别忠实性、MathIR statement/sourceRefs、每步 Lean expectedType/ProofTerm/diagnostics/dependency usage、独立 Kernel、first blocking step、请求与 token、耗时。未经 Kernel 的结论或无法证明均保持 `not_established`，不能改称数学反例。
