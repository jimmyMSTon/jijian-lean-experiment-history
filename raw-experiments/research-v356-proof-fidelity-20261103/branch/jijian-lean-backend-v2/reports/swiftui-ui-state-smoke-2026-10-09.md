# SwiftUI UI 状态 E2E Smoke（2026-10-09）

- 正式 App：`../dist/极简 Lean.app`（`python3 scripts/build_mac.py --reuse-backend` 构建）。
- 签名完整性：`codesign --verify --deep --strict` 通过。
- 本地 UI fixture 目标：`python3 scripts/build_native_preview.py` 编译通过；fixture 状态菜单显式声明不启动 Provider。
- 真实样本：`设 a,b 为实数，已知 a=b。等式两边加1，得到 a+1=b+1，故 a+1=b+1。`
- 正式 SwiftUI 窗口从“正在准备证明”切换到“证明已通过核验”，显示 `2 / 2 已核验`。
- 同一 job `43587326-e6e5-4491-9de3-6fa3c51b2c59` 从提交到 completed 用时约 5 分 25 秒。后端返回 `status=formal_verified`、`kernelVerified=true`，两步的 `established` 均为 `true`。
- 当前 workflow 的真实 DeepSeek 调用共 6 次：MathIR 1、LibraryPlan 2、formalization 1、repair 2；没有 recognition 或 feedback 请求。所有 `retry_index=0`。审计器对每个 request_id 记录开始与响应两行，因此 12 条审计事件对应 6 个真实调用；重复 `input_hash` 是同一 request_id 的开始/响应配对，不代表请求重发。
- 预览样例覆盖空白输入、已输入未验证、导入处理中/失败、识别处理中/失败、无法形式化、历史无记录/有记录/读取失败；成功、部分失败、步骤详情、修改待验证等由已保存 fixture 记录呈现。fixture 不是 Kernel 成功证据。
- 未运行大规模 AI 回归或视觉 live 专项。该次真实 smoke 是本轮唯一新建验证 job。
