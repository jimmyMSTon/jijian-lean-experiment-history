# Mac 与 Stitch 整合实测报告

实测日期：2026-10-06；本机 macOS 15.2 / Apple Silicon；Python 3.14.5；Lean / Mathlib v4.34.0。

## 交付内容

按 CODEX_APPLY_PATCH.md 使用补丁工具合并：40 个文件（17 新增、23 修改），无合并冲突。两个原始 ZIP 保持原样。原包校验、合并记录见 merge-mac.json。五个指定 Stitch 屏幕的实际 HTML、截图、MCP 元数据保存于工作区 stitch-original，未用替代设计。

实际网页通过原 client/backend-client.ts 连接 FastAPI，接入识别修订、结构化、长任务事件、取消、历史、Mathlib 候选检索、步骤诊断及依赖图。原文修改清除旧验证结果；判定读取 kernelVerified 等实际证明字段。Lean 代码由用户主动展开。位置只声明步骤级映射，不声称字符或笔画级定位。没有加入收费、账户、数量限制、审核 Gate 或新增自动重试策略。

Mac 开发 App 使用实际 AppKit/WebKit 与打包 Python 后端。原 UI 字体、图标和 Tailwind 样式已本地打包。运行依赖外置的本机 Lean/Mathlib（约 8GB）；App 中 runtime.json 指向本机路径。该构建不是任意 Mac 可直接使用的独立发行包；仅 ad-hoc 签名，未进行 Developer ID 签名或公证。服务端凭据不在 App 包中。

## 已真实执行

| 范围 | 结果与证据 | 解释 |
|---|---|---|
| 默认 pytest | 171 通过、7 显式选择项跳过；pytest-mac.xml / .log | 默认套件包含测试替身，不算真实 AI 或 Lean 集成成功 |
| Lean / Mathlib 工程 | prepare_runtime.py 最终执行成功；runtime-prepare-mac-final.log | 实际缓存、补建 Mathlib 根模块、编译 Jijian、Smoke.lean |
| 固定形式化例子 | check_examples.py 成功；examples-mac-final.log | 真 Lean 执行及独立数据式内核复核；不是 AI 从自然语言生成的例子 |
| 真实 Lean 核心集成 | 4 项通过；lean-live-mac.xml / lean-live-mac-final.log | 真/假、sorry 拒绝、Mathlib 检索、声明探测 |
| macOS 隔离集成 | 1 项通过；isolation-live-mac.xml / .log | 实际验证环境变量密钥隔离、工作区外文件读取阻止、网络访问阻止 |
| 实际 HTTP | 11 项通过；http-smoke-mac.json | 独立 uvicorn 与真实 TCP，无外部供应商请求；缺密钥明确失败 |
| 实际 Chromium 页面 | 7 项通过；ui-browser-mac.json | 五屏加载、错误不冒充证明通过、模式切换原文保留；无 JS 页面错误 |
| 固定例子贯通后端与 UI | ui-lean-mac.json、ui-real-lean-mac.png、ui-real-graph-mac.png | 实际 /api/verify、两步和整体证明内核审计、反馈渲染、3 节点/2 边依赖图；providerCalls=false |
| TypeScript / Python | tsc 与 compileall 执行成功 | 编译检查不是 AI 数学验证 |
| Mac 构建 | mac-build-final.log；native-smoke-mac.json / .png | 实际 clang、PyInstaller、签名校验、原生 WebKit 加载本机后端 |

真实 Lean 核心测试的那次记录还包含隔离测试源代码的 IO 类型推断失败。修正为显式 IO Unit 后，隔离测试单独重跑通过；因此最终为两次执行合计 4+1 通过，不把旧日志改成一次 5 项全过。早期失败日志保留，最终结论来自明确的重跑证据。

## 实际修复

修复 Lean Wire 中保留字构造器及记录布局；聚合证明显式标注原 expectedType，解决局部 lambda 推断错误而不增加前提。诊断解析支持 Lean --json 信息信封内的 nonce 记录，并保持独立证明对象与期望类型复核。

Mac 沙盒使用真实 Unicode 路径、精确祖先目录读取与 /dev/null；候选进程直接运行固定 Lean 二进制并从 manifest 构造 LEAN_PATH，避免隔离 HOME 下 Lake 因 Git URL 重写差异重新拉取依赖。环境清理与网络禁止保留。最初错误沙盒配置产生的两项 macOS 不可中断进程曾发送终止信号；它们的系统级清理未作为测试通过条件，最终修复路径的真实测试没有复现该挂起。

原生 Swift 构建遇到本机编译器与 SDK 不匹配，改用同一 AppKit/WebKit 能力的 Objective-C 构建；保留未使用的 App.swift，并未声称 Swift 编译通过。

## 未执行及边界

- 未提供真实服务端供应商配置，因此真实 DeepSeek Flash 调用、账户模型可用性、AI 自然语言结构化/形式化/诊断修复、Mathpix OCR 均未执行。没有请求或消耗 API 额度。默认模型配置不代表账户已验证。
- 摄像头桥、设备选择与原生权限代码已接入；用户实际摄像头、iPhone 连续互通、真实手写识别质量没有硬件实测。
- 网关部署、其他 Mac 安装、Developer ID、公证没有执行。
- 原设计入口中缺少后端契约的独立示例库/文档/工具箱页面未另造。图像裁剪与精确字符框、复杂项目文件管理和置信度统计未伪造。

下一项必需信息是服务端配置文件路径（例如 ~/Library/Application Support/JijianLean/server.env），无需把密钥贴到聊天。配置就绪后才可完成真实供应商联调；当前整体目标尚未全部完成。
