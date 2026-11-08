# Design QA — 当前 Stitch → 极简 Lean Mac App

2026-10-07；完成 UI 后的最终比较。使用 product-design image-to-code / design-qa 工作流。此次目标是按用户明确要求把 Stitch 技术常驻面板变为数学稿纸与渐进披露，并非逐像素复制 IDE 三栏或占位业务。

## 来源与比较证据

- 视觉真值：`../stitch-current/<screen-id>/screen.png`、`screen.html`；15 份 ID/来源见 `UI_INVENTORY.md` 和 `validated-download-manifest.json`。
- 源码重渲染：`reports/ui-completion/screenshots/source-*.png`，1280×900。移除远程脚本、以已缓存字体和本地 Tailwind 渲染设计代码；仅用于比较。原始 hosted 图最大 512 像素，不能据此宣称高精度字形像素一致。
- 实现：`reports/ui-completion/screenshots/{workspace,recognition,verifying,success,failure,step-detail,mapping,ambiguity,editing,import,camera,preferences,system-error,welcome,formal-details}.png`。
- 同一输入的并排比较：`comparison-<state>.png`，15 组，2560×930（两侧各 1280×900，上方 30px 证据标签）；总览 `comparison-contact-sheet.png`。
- 局部比较：`focused-workspace.png`、`focused-success.png`、`focused-step-detail.png`；保留原始分辨率以检查字号、图标、公式、信息层级。步骤详情整幅配对也检查了原文/条件/目标/说明。
- 真实 App：`native-welcome.png`、`native-result.png`、`native-step-detail.png`、`native-formal-details.png`、`native-dependencies.png`，来自最终包实际 WKWebView，不是网页模拟 Mac 窗口。

浏览器 CSS viewport 为 1280×900，截图密度 1。IAB 可视面板截图曾裁切为 1095×889，已改为 fullPage 捕获并截取完整 900px 区域；因滚动条内容宽 1265，右侧 15px 补背景，不放大或横向拉伸。高级详情以实际文档 y≈1290 为裁切起点，明确是展开后的次级区域。弹窗 fullPage 捕获有固定层位置差异，只评估内容与可用性，不做虚假精确对齐。原生 App 是 1360×928 CSS 窗口、2720×1856 @2x 含标题栏；单独判读，未直接当成 1280×900 像素配对。原生窗口放大到 1728×1015 也检查，600×800、800×800 窄窗另有截图。

源码案例包含柯西积分不等式，当前 UI QA 为已记录代数案例/合成失败状态，动态数学内容不同，不能把案例差异记为视觉漂移。正式文字 smoke 的 4 步来自本次实际结构化，fixture 的 6 步来自此前真实记录，未冒充同一运行。

## 五项必查表面

| 表面 | 比较结论与证据 |
|---|---|
| 字体与排版 | 本地 Inter 与 Material Symbols；中文使用 macOS 系统中文 fallback，数学 KaTeX 本地字体。源码部分标题声明 Manrope，源码比较采用可用 Inter fallback，因此不声称 Manrope 字形一致。正文稿纸默认 18px，行距充分；24px 切换无横向溢出。原文保留换行，步骤标题/说明层级可读；失败详情的公式及 x/y 条件可读。图标已使用实际字体，没有 literal `edit_note` 等落入视觉界面。 |
| 间距和布局 | 源码浅色稿纸/左导航/青色选中态保留；常驻三栏、状态卡和代码按用户要求移至折叠详情。结果页通过折叠原稿避免结果被推至多屏之后，宽度受控、行间分隔轻。600/800/1280 下正文与持久控件不重叠，无文档横向溢出；长证明可纵向滚动。依赖图仅在自己的可滚动区域出现。 |
| 颜色与 token | 主色 #006874、强调 #00e7fe、浅稿纸 #f9f9f9，与实际导出方向相同；选中导航浅青 #95f1ff。通过为青色，未证/系统错误为浅红，歧义为浅黄，均同时有文字语义。未引入无关 Stitch theme metadata 中的零售品牌。 |
| 图像与资产 | Σ 为源设计 Material functions 字体图标；其余按钮同源 Material Symbols，不用手画 SVG 代替设计图像。原稿图像以真实文件资产加载、保留比例，可缩放/旋转；映射明确步骤级。数据依赖图的 SVG 仅画实际数据连线，不代替装饰资产。未生成装饰插画、头像或替代品牌。用户相机画面未保存为 QA 图；相机截图是明确 fixture 权限等待状态，真实硬件预览另以操作证据记录。 |
| 文案与内容 | 数学输入和原推理居中；结果是“当前数学解释的证明已验证”，说明形式命题与原意区别。未证、形式化、歧义、服务故障分别表达，未宣称所有失败都是数学错误。源码中的示例耗时、版本、账户、自动补前提没有复制为真实能力。业务按钮与说明为中文、无开发诊断面板或 prompt 文本泄漏。 |

## 比较迭代与已修问题

| 级别 | 早期发现 | 修复 | 最终证据 |
|---|---|---|---|
| P1 | 成功页完整编辑器常驻，把验证步骤挤到多屏之后 | 结果返回后折叠原稿和系统理解，保留“修改当前证明” | `comparison-success.png`、`native-result.png` |
| P1 | WK 事件流断开后丢失 jobId，重新尝试可能再次提交付费任务 | 保留已有 jobId；读同一 job/结果；双击提交前同步 guard | `final-ui-request-checks.json`：POST jobs=1，GET jobs=2；`stream-recovery-full.png` |
| P2 | 图标字体漏载，显示英文 icon 名 | 加载本地 Material Symbols 真实样式/字体 | workspace/success/step-detail 配对与原生图 |
| P2 | 步骤详情漏掉作用域内变量条件 | 从 scope parent 链列出可见变量 | `native-step-detail.png`：x∈ℝ、y∈ℝ |
| P2 | 历史显示 UUID、根据不足元数据称验证通过 | 使用实际保存时间与中性“数学证明记录” | 最终 App 历史操作；结果状态由 artifact 决定 |
| P2 | 长证明滚动时丢失进度提示 | 轻量 sticky 状态区 | `long-800.png`、verifying 状态 |
| P2 | 折叠原稿后的 innerText 可能丢失换行，影响导出/提交 | 持续保存精确稿件，提交/导出读取 draftText | `export-check.json`：190/190 字符、逐字相等 |
| P2 | 关闭权限等待/设备切换失败可能留下迟到流或旧可拍画面 | capture epoch；停止旧轨道；失败仅局部提示，禁用拍摄直到 loadeddata | 最终源码/包；fixture 关闭等待；真实相机预览已检查 |

本次最后比较未发现需继续修复的 P0/P1/P2。上述技术常驻面板、自动补前提、示例统计的差异是用户要求的实现约束，属于预期，不是未解决的设计漂移。

## 交互、状态及范围

已检查欢迎、输入、识别、验证中、成功、未证明、形式化失败、歧义、系统错误、步骤详情、修改、导入、相机、偏好及高级细节。原稿修订、编辑后撤销旧结果、文件选择、手写入口/清空、LaTeX、导出、历史、折叠、依赖、窗口缩放已验证。浏览器错误日志最终为空；刻意断开 SSE 的测试随后通过 GET 恢复。普通预览/导航/详情不调用 AI。

`final-state-checks.json`：各可见状态文档宽等于 scrollWidth；welcome 的隐藏状态节点不用于可见结论。600 成功页 585/585、800 长稿 785/785；长稿高度 17913px，正常滚动。正式包不含 fixture 服务脚本，正常 Provider 未替换。

覆盖限制：图片/PDF/手写这轮以明确 fixture 验证 UI，未再跑大规模真实视觉。步骤原图映射的 `mapping-result` fixture 人工将原图关联到记录，验证资产读取，不能用它声称数学识别正确。相机 FaceTime 实际预览已操作，iPhone 设备列出；未发送画面、未验证 iPhone 拍摄识别闭环。浏览器 QA 是浅色；源设计没有另一个深色目标。以上是实测范围，并非缺失页面或新增发布 Gate。

## 实施检查单

- [x] 15 份源图/代码保留，受保护代码出处单独记录
- [x] 源与实现合并比较、局部文字/图标检查、修复后复查
- [x] 数学默认，Lean/MathIR/diagnostics/依赖次级披露
- [x] 真实接口绑定与实际 Kernel 结果显示；fixture 不进正式 Provider
- [x] 长稿、窄窗、字号、错误与加载状态
- [x] 同一 job 恢复、重复点击去重、导航不发 AI

final result: passed
