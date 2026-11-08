# 极简 Lean 原生三色窗口按钮专项修复记录（2026-10-09）

## 用户反馈
正式 SwiftUI App 左上角红、黄、绿原生窗口按钮缺失。

## 实际诊断
- 此前使用过 `.windowStyle(.hiddenTitleBar)`；当前 `macos/Native/NativeApp.swift` 已移除该设置。
- 2026-10-09 07:22 实测时，旧正式 App 进程启动于 00:23，而磁盘上的正式 App 已在 00:43 更新；旧进程不会因为构建后更换 .app 文件而自动更新。
- 截图设备所处可见桌面当前为独立的 UI fixture；无法从当前远程截图确认正式 App 窗口外观。未把视觉结果标成通过。

## 已实施的最小客户端修复
- 新增 `macos/Native/NativeWindowChrome.swift`：在 SwiftUI 内容附着至真实 NSWindow 后，恢复原生 `.titled/.closable/.miniaturizable/.resizable` 样式，显示系统标题栏并取消三个系统窗口按钮的隐藏状态；不绘制仿制按钮。
- 修改 `macos/Native/NativeApp.swift`：将窗口配置视图绑定到 WindowGroup 根视图背景。
- 没有修改业务、DeepSeek、MathIR、Lean、Mathlib、Repair 或 Kernel。
- 执行 `python3 scripts/build_mac.py --reuse-backend` 完成 UI-only 重新构建，退出码 0；本轮复用原有后端打包资源。
- `codesign --verify --deep --strict` 检查通过。
- 新构建 `/[LOCAL_USER]/Documents/ChatGPT/极简lean 2/dist/极简 Lean.app` 可执行文件修改时间：2026-10-09 07:27。
- 新版 App 实例在 07:28 启动且进程存活；旧用户实例仍存在，未强制关闭以免丢失未保存草稿。

## 尚待用户实际窗口验收
保存旧 App 草稿后，正常退出所有旧版本极简 Lean（非 UI fixture），然后使用 Finder 打开上述 dist 下新构建的正式 App。检查左上角红黄绿按钮是否可见、分别可关闭/最小化/缩放/全屏，且不遮挡侧栏或顶部工具带。若仍不可见，记录可见的正式 App 窗口截图并进一步检查 NSWindow 生命周期/系统桌面空间。无需调用 DeepSeek。

## 与当前其他问题无关
此前 Python 回归 `jsonschema` 未安装导致的测试收集失败不代表测试通过；应由后续开发任务在隔离依赖环境中补齐再执行，不使用本次窗口签名检查代替完整回归。

## 2026-10-09 13:13 再核对（真实正式 App）
- 当前正式进程 PID 81453，启动于 12:50；构建产物的时间 12:50:30，已通过严格代码签名验证。
- 使用 CoreGraphics 窗口列表确认正式 `极简 Lean` 主窗口处于 on-screen 状态（窗口 ID 4839）。
- 对 ID 4839 执行系统原生 `screencapture -l` 捕获正式窗口：`reports/traffic-light-window-current.png`。预览 `reports/traffic-light-window-current-preview.jpg`。
- 截图在左上角清楚显示三个系统圆形按钮，但它们是**灰色**；与此同时 `NSWorkspace.frontmostApplication` 返回的是 `Google Chrome`，正式 App 处于非前台激活状态，这与 macOS 未激活窗口按钮灰显的正常表现相符。
- 本轮不把“灰色按钮存在”冒充“红黄绿激活态且三个操作均通过”。仍建议由 Codex 在 App 实际获得焦点后再捕获一次照片并分别核验关闭/最小化/缩放。
- 当前结论：问题表现更接近截图窗口未激活，而不是标准按钮完全缺失；没有新的业务/后端改动。
