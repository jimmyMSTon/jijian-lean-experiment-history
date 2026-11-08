# UI_INVENTORY

更新：2026-10-07。当前 15 张 Stitch 设计均已取得图像与实际代码，原件保存在 `../stitch-current`，旧五张在 `../stitch-original`，两个原始 zip 保留。11 份 HTML 直接下载，4 份受保护 HTML 从已登录 Stitch 实际渲染 srcdoc 取得；错误登录页另存，不冒充设计。每份出处和校验见 `../stitch-current/validated-download-manifest.json`。

实现以当前 Stitch 的 Σ 标识、青色主色、浅色稿纸和数学层级为视觉来源。按本轮明确要求收起常驻 Lean/MathIR/诊断/依赖面板，避免三栏 IDE。源码中的账户、社区、占位时间、计数及自动补前提没有转为产品逻辑。当前源码只包含浅色目标，未新增深色方案。

| Stitch ID | 状态 | 设计/代码 | 已实现 UI | 真实后端/数据绑定 | 缺 UI / 缺状态 | 是否仅 fixture | 可操作与验证证据 |
|---|---|---|---|---|---|---|---|
| `6245364fd70c4585a7a02958ec2fa0f5` | workspace | 已有，图/代码均保留 | 文字/LaTeX 编辑、排版预览、验证 | POST /api/jobs；MathInput | 无 / 无 | 正式否；QA 明确 fixture | 真实 App 已输入并提交；fixture 编辑/LaTeX/导出/窄窗 |
| `7a7625c9be104027a283d2a5bee6ced4` | recognition | 已有，图/代码均保留 | 原图与识别文本校对、保存修订 | GET recognition；PATCH correction | 无 / 无 | 正式否；QA 明确 fixture | fixture 读取/校对/文件导入；本轮未新增真实视觉请求 |
| `a88d7c66ad8a411d8ec765ac9a255f0a` | verifying | 已有，图/代码均保留 | 简洁进度、取消、恢复同一任务 | SSE events + GET job；POST cancel | 无 / 无 | 正式否；QA 明确 fixture | 真实 App 提交后显示进度；fixture 断流与双击去重 |
| `aade4d47c3a94439a72dbffdffd4a91d` | success | 已有，图/代码均保留 | 原证明逐步结果、整体解释范围 | GET verification；真实 kernelVerified/status | 无 / 无 | 正式否；QA 明确 fixture | 真实 App 4/4 + aggregate Kernel，通过 |
| `2feaaf08a73d4aec85452cc9054b752f` | failure | 已有，图/代码均保留 | 尚未证明的步骤与原文详情 | verification.steps / feedback | 无 / 无 | 正式否；QA 明确 fixture | 合成失败 fixture；正式使用同一渲染与接口 |
| `23d08e342737439b9983abcd2e2943bd` | step-detail | 已有，图/代码均保留 | 原步骤、条件、目标、说明、折叠 diagnostics | SourceRef / MathIR / verification | 无 / 无 | 正式否；QA 明确 fixture | 真实 App 步骤、变量 x/y、数学目标；fixture 失败详情 |
| `572475286f1e47eabe0b859baca2de7a` | source-mapping | 已有，图/代码均保留 | 原图与识别稿对照、步骤来源 | recognition blocks；SourceRef→asset | 无 / 无 | 正式否；QA 明确 fixture | fixture 原图加载及步骤 asset 映射；仅步骤级定位 |
| `fd82a1525ba64343bb8dc632ab306fbc` | ambiguity | 已有，图/代码均保留 | 不同读法、返回原文修正 | unresolvedAmbiguityIds / originalMeaning / ambiguities | 无 / 无 | 正式否；QA 明确 fixture | 合成歧义 fixture；不会仅凭 Kernel 隐去歧义 |
| `917799af0caf4a87b769a77dac11a5b7` | editing | 已有，图/代码均保留 | 修改当前稿纸、撤销旧结果、重新验证 | 当前 MathInput / recognition revision / jobs | 无 / 无 | 正式否；QA 明确 fixture | fixture 修改使旧结果失效；同一稿纸重提验证 |
| `beedb0783ff343d780172f97cb10c32d` | import | 已有，图/代码均保留 | 图片/PDF 选择与拖入、粘贴、相机、手写 | input-bridge → assets → recognize | 无 / 无 | 正式否；QA 明确 fixture | fixture 文件选择上传/识别接口；真实 App 菜单与导入入口 |
| `fbfbedfe949c4a21a1fd2637c6df531e` | camera | 已有，图/代码均保留 | 实际设备选择、预览、明确拍摄后识别 | getUserMedia / enumerateDevices → assets/recognize | 无 / 无 | 正式否；QA 明确 fixture | 真实 Mac FaceTime 预览可用，列表出现 iPhone；未拍照发 AI |
| `00af0d3a9b7f45c9a1a1c1ae92c3db78` | preferences | 已有，图/代码均保留 | 字号、数学排版显示 | 本机 localStorage，无 AI | 无 / 无 | 正式否；QA 明确 fixture | fixture 24px/18px 切换及显示；正式相同本地逻辑 |
| `a49fa5f2d7c34742b9fe35851ceb6a18` | system-error | 已有，图/代码均保留 | 无数学结论、保留原稿、手动恢复 | BackendError / engine_error / current job | 无 / 无 | 正式否；QA 明确 fixture | 真实事件流故障已定位；fixture 恢复同一 job，POST 仅 1 次 |
| `c3ce8a585e084d12a1fcf63e43cfd89e` | welcome | 已有，图/代码均保留 | 空稿纸入口、导入入口 | 本地状态，无 AI | 无 / 无 | 正式否；QA 明确 fixture | 最终真实 App 已启动并截图 |
| `d18fce13b44e46208ea1729f22244793` | formal-details | 已有，图/代码均保留 | Lean、MathIR、依赖关系折叠入口 | GET formalization + existing MathIR | 无 / 无 | 正式否；QA 明确 fixture | 最终真实 App 展开当前 Lean 与 4 节点依赖图，无 AI |

## 页面与状态的对应关系

`ui/stitch-screen-map.json` 保存 15 状态与来源 ID。既有 home/quick/pro/recognition/graph 路由共用同一数学稿纸、真实客户端连接；状态和导入/步骤/相机/偏好弹窗不新增产品页面。界面编译来源为 `scripts/build_stitch_current.py`、`client/stitch-app.ts`、`ui/desktop.css`。原旧构建器保存在 `scripts/build_stitch_legacy.py`。

输入文字或 LaTeX 后点击验证才提交 `/api/jobs`。图片、PDF、画布或当前相机画面经 `client/input-bridge.ts` 上传，识别结果可在原图旁校对；修订使用 Unicode 位置转换与原接口。结构化完成后展示人类数学，最终显示原文步骤，用户可以回到同一稿纸修改并重验。没有添加必须审核确认才能继续的条件。

进度只订阅/读取同一个 job；断流不会重复 POST。原稿改动会使旧结果失效。只有用户明确提交、识别或重验才启动相应业务调用；导航、预览、详情、历史和偏好不调用 AI。历史的 feedback(explain=false) 只整理已有验证数据。

结果读取 `kernelVerified`、`status`、`originalMeaning`、`unresolvedAmbiguityIds` 和步骤状态，不以 HTTP 200 或 completed 判断通过。步骤定位是原文 → MathIR → 证明义务 → diagnostics，精度为步骤级。用户/模型文本使用 textContent 或 trust=false 的本地 KaTeX，未作为任意 HTML 执行。

## QA 与剩余验证范围

已完成全部目标状态的浏览器渲染与源码配对比较、600/800/1280 CSS 宽度、长稿滚动、字号、识别校对、编辑失效、固定结果/失败/歧义、高级折叠、导出和断流去重检查；正式 App 的欢迎、真实输入/进度/结果、历史、步骤、Lean 与依赖图已操作。详见 `design-qa.md` 与 `reports/ui-completion`。

没有尚缺的已要求页面或状态实现。覆盖范围限制：此次只执行一次真实文本 E2E；图片/PDF/手写的 UI 输入与状态 QA 使用明确 fixture，不算真实识别能力成功；相机硬件预览已检查，未发送画面。拖入接入真实 DOM drop 与输入桥，本轮没有额外执行真实拖入视觉全链。没有新增大规模视觉测试。

最终 App 正常操作使用真实 Provider，不含预览服务，不依赖离线/live Gate。开发 fixture 服务器仅手动运行用于 UI QA。
