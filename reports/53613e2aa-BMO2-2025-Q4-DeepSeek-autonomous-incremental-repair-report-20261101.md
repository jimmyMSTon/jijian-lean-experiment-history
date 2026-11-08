<!-- Source: local experiment archive; paths and email addresses sanitized -->

# 极简 Lean：BMO2 2025 Q4 真实 DeepSeek 增量修复记录

日期：2026-11-01  
模型：DeepSeek Flash（真实 API 请求，simulated=false）  
Lean：Lean 4.34.0 + 当前锁定 Mathlib runtime

## 结果

**整题命题通过 Lean Kernel 验证。**

- 最终状态：kernel_verified
- kernelVerified=true
- statementMatched=true
- Lean 编译错误：0
- additionalAxioms=[]
- Kernel 审计报告存在，Lean 运行返回码 0
- 原始锁定命题未改写

## AI 修复过程

初始完整模块由此前的真实 DeepSeek 请求生成。进入本轮增量修复时，Lean 报告 7 个错误。

### 第六次真实 DeepSeek 请求

- 响应 ID：129110af-ae68-4430-8ef2-1bc3aceb0d44
- 输入 token：9,491
- 输出 token：1,299
- 返回补丁：5 处
- 补丁应用：5/5
- Lean 错误：7 → 2

模型生成的主要修复：
- 将两个高指数递推等式改成有理数等式推导与类型转换，避免对 2025 次幂做整体 ring_nf。
- 修正 Mathlib Set.ncard_coe_finset 标识符。
- 修复递推证明中的类型处理。

本轮编译观察到的内存占用约 1.2 GB；此前错误候选的 ring_nf 版本曾超过 13 GB，未完成编译。

### 第七次真实 DeepSeek 请求

- 响应 ID：e0e765e1-7c30-4613-bc66-aaa4ba1f5fca
- 输入 token：9,415
- 输出 token：223
- 返回补丁：2 处
- 补丁应用：2/2
- Lean 错误：2 → 0

模型生成的两处修复：
1. 使用 exact_mod_cast 处理 ZMod 中自然数幂与模数幂的类型转换。
2. 删除 rw [h3] 已经解决目标后多余的 ring。

这两处代码均来自真实 DeepSeek 响应，不是人工插入 Lean 证明。

## 验证边界

- 通过的是锁定后的完整数学命题，不是局部 lemma 的单独通过。
- additionalAxioms=[]，没有依赖额外公理或 sorryAx。
- originalSourceProofCertified=false：本次证书确认的是最终 Lean 定理及其命题一致性，不声称原始文字证明与生成的 Lean 证明逐步等价。

## 回归测试

- 增量补丁、模块修复、source-step recovery、verified-step composition 等相关测试：57 passed。
- 全后端测试：1171 passed, 6 failed, 73 skipped。
- 6 个失败集中在既有旧 API / Native V2 契约测试：旧接口测试仍期待 200/422，但当前接口返回 410（旧流水线已归档）；另有测试仍期待 schema 2.0，而当前 API 返回 3.6.1，以及一项旧状态期望不一致。它们不在本次增量修复模块的改动范围内，尚未处理。

## 可复核文件

- BMO2-sixth-live-AI-patch-proposal-before-Lean-20261101.json
- BMO2-sixth-real-AI-patch-Lean-result-20261101.json
- BMO2-seventh-live-AI-patch-proposal-before-Lean-20261101.json
- BMO2-seventh-real-AI-patch-Lean-result-20261101.json
- BMO2-seventh-real-AI-patch-Lean-result-20261101.log

最终 Kernel 证书中的模块源码 SHA-256：

1a9f723596bb259584cd5387bed7204a7a83adc9984f51366f00240ed21c4e96
