# 本机整合与启动

原 ZIP 保留在用户提供的下载位置；原始 Stitch 导出保留在工作区 `stitch-original/`，逐屏包含 screen.html 与 screen.png，screens.json 保存 MCP 元数据及下载地址。V2 合并源码位于 `jijian-lean-backend-v2/`。补丁 40 个文件无冲突，原包 SHA-256 与清单一致。

实际 App 位于工作区 `dist/极简 Lean.app`。这是 arm64 本机开发构建：AppKit 原生窗口、菜单、文件选择、摄像头授权、WebKit 和打包的 Python/FastAPI 后端。使用临时本机端口，同源加载 Stitch 页面。退出应用会结束其后端；验证取消通过“文件 → 取消当前任务”或 ⌘. 使用既有取消 API。

该 App 使用当前机器外置的固定 Lean 4.34 / Mathlib 4.34 环境，路径记录于 Resources/runtime.json；约 8GB 的库和缓存没有装入 92MB App。移动整个工作区后需要重建路径配置。当前有 ad-hoc 本机签名，无 Developer ID 签名和 Apple 公证，没有声称可直接分发到任意 Mac。

## 服务端配置

开发源码使用根目录 .env（已忽略 Git）；Mac App 使用 `~/Library/Application Support/JijianLean/server.env`，或启动环境的 `JJ_ENV_FILE`。供应商密钥仅由服务器加载，不放入网页、Resources/runtime.json 或应用包。App 数据与日志分别位于同目录下 data/ 和 backend.log。

已确认生产适配器为 DeepSeek。请求模型来自服务器 `DEEPSEEK_MODEL`（默认 deepseek-flash）；真实凭据与账户可调用模型未在没有凭据时猜测。2026-10-06 用户更新：第一版正式 AI Provider 仅 DeepSeek，不依赖 Mathpix、OpenAI 或第三方 Gateway。当前真实联调直接使用服务端 DeepSeek 配置，不等待其他凭据。生产 DeepSeekProvider 固定直连，旧 AI_GATEWAY_URL 不会转发第一版请求。原包中的历史兼容源码保留，未作为正式 Provider 使用。

## Stitch 接线

ui/*.html 由 scripts/build_stitch.py 从保留的原始导出生成；原来页面布局、配色与区域作为来源。静态示例结果、统计和旧引擎标签替换为待验证状态，首页排版例子明确标记未执行验证。client/stitch-app.ts 导入现有 LeanBackend 与输入桥；不导入生产测试替身。

已接：原文编辑、文字/LaTeX 路径、文件/拖放/粘贴图片/PDF、摄像头选择与捕获、原始 Canvas 笔顺与时间压力、识别修订、jobs/events/cancel、历史读取、Mathlib 源码检索、实际步骤与依赖图、步骤级来源/诊断、主动展开 Lean 代码、导出数学文本或 LaTeX 片段。数学输入修订会清除旧结果显示；运行中旧输入的结果不会被当作当前新输入通过。

判定读取验证记录的 kernelVerified、status、originalMeaning、unresolvedAmbiguityIds 与步骤 established/status。任务完成不等于证明通过。数据使用 textContent、textarea 和 SVG 数据属性渲染，不把模型/用户文本作为 HTML。不会替用户增加前提或自动采纳新证明。

原导出中没有对应实现/后端契约的“示例库/文档/工具箱/帮助”独立页面未另造；对应入口说明缺少接口。图像裁剪选区与识别字符级框、复杂项目文件管理、识别置信度统计没有伪造实现。原图与诊断只报告已支持的步骤级映射。摄像头与连续互通是否能取得实际设备由 macOS 权限与硬件决定，未在无人选择设备时强行开摄像头。

## 开发工具

Python 依赖隔离在工作区 .venv。构建附加依赖见 requirements-build-mac.txt；Node 构建依赖记录于工作区 tools/package.json。

运行后端：在 V2 根目录使用工作区 .venv/bin/python -m backend。网页入口 /ui/home.html。

重新生成网页：scripts/build_stitch.py，然后 node scripts/build_ui.cjs，再运行 scripts/vendor_ui_assets.py 缓存原导出字体与图标以供离线加载。TypeScript 检查：工作区 tools/node_modules/.bin/tsc -p client/tsconfig.json。

Mac 构建：使用隔离 Python 运行 scripts/build_mac.py。当前环境 Swift 编译器与 SDK 不匹配，所以实际构建使用 macos/App.m；App.swift 保留为未使用的最初尝试，不是二进制构建输入。构建脚本使用 PyInstaller --clean，避免旧导入模块字节码残留。

运行环境：scripts/prepare_runtime.py。先获取缓存，再实际补建 Mathlib 根模块及 Jijian 模块；不在用户每次验证时下载。候选进程直接执行固定工具链 Lean 与 manifest 内的 LEAN_PATH，避免 Lake 在隔离 HOME 下由于主机 Git URL 重写缺失而尝试更改依赖。

实测记录详见 reports/Mac整合实测报告.md。没有执行的外部能力不得计入通过。
