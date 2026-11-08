# 极简 Lean UI 状态矩阵

本表对应当前原生 SwiftUI 客户端。正式 App 使用 `NativeStore` 与 `BackendClient` 的真实响应；`UI_FIXTURE` 预览是单独编译的 UI 样例，不会启动后端或调用 Provider。

| 状态 | 完成 | SwiftUI View / 文件 | 数据来源 | 已接真实后端 | Fixture 预览专用 |
|---|---|---|---|---|---|
| 空白输入 | 是 | `NativeWorkspace`、`NativeDraftEditor`，`NativePages.swift` / `NativeDraftEditor.swift` | 本地 `draft` 空值 | 否，提交前本地状态 | 有“空白输入”样例 |
| 已输入、未验证 | 是 | `NativeWorkspace` | 本地 `draft`；输入支持普通文本与 LaTeX | 否，点击验证后创建任务 | 有“已输入未验证”样例 |
| 文件/图片导入处理中 | 是 | `NativeImportProgress`、`NativeStore.importFiles/importImage` | 本地 `isImporting` | 图片会先上传至本机服务；此状态不调用识别 | 有“导入处理中”样例 |
| 导入失败/不支持 | 是 | `NativeInputStatus`、fileImporter 回调 | 本地文件读取/内容类型错误 | 不依赖 AI；可重新选取 | 有“导入失败”样例 |
| 正在识别 | 是 | `NativeRecognition` 简洁 loading | 本地 `isRecognizing` | `/api/recognize`；只在显式导入/识别动作触发 | 有“识别处理中”样例 |
| 识别完成、可编辑 | 是 | `NativeRecognition` | recognition 返回的 `text`、`blocks` | 是 | 已有 `recognition_success.json` 和手写录制响应 |
| 识别存在歧义 | 是 | `NativeAmbiguity`、`NativeRecognition` | MathIR ambiguity / recognition blocks | 是 | 有 `recognition_ambiguous.json` 等录制响应 |
| 内容未能识别 | 是 | `NativeInputStatus` | 本地捕获的识别/解析错误类别 | 是；错误由识别请求返回，不把它当作证明失败 | 有“识别失败”样例 |
| 正在准备证明/验证/整理结果 | 是 | `NativeVerifying` | `/api/jobs` 任务事件和任务状态 | 是；只观察同一任务，不因 UI 重绘重新提交 | 页面路由可用录制状态预览 |
| 全部验证通过 | 是 | `NativeResult(success: true)`、`ProofCard` | `kernelVerified`、verification status、`originalMeaning`、ambiguities、steps | 是；只按严格后端字段判定 | `verification_success.json` / `recorded-proof.json` |
| 部分步骤失败 | 是 | `NativeResult(success: false)`、`UnprovedStepCard`、`NativeEstablishedStepFold` | verification steps 与 feedback items | 是；颜色与解释逐步绑定实际返回值 | `verification_failed.json` |
| 暂时无法形式化 | 是 | `NativeResult.resultDescription`、`NativeFailureSummary`、`NativeStepDetail` | `statement_not_elaborated` 与后端 message | 是；明确说明不等于证明错误 | `formalization_failed.json`，另有 UI 注入样例 |
| 尚无可验证的证明 | 是 | `NativeResult.resultDescription`、`NativeFailureSummary`、`NativeStepDetail` | `missing_proof` 与后端 message；说明不能据此判定数学结论错误 | 是 | 保存的错误证明结果；fixture preview 可复现 |
| Kernel 未通过 | 是 | `NativeResult`、`NativeStepDetail` | 后端 kernel/step 状态与人类可读 message | 是；不由 HTTP 成功或任务完成推断 | `verification_failed.json` |
| 系统异常 | 是 | `NativeSystemError` | 本地后端、Provider、Lean Runtime 等错误类别；界面使用安全摘要 | 是；保留原稿，不展示 stack trace 或诊断码 | `.systemError` 页面 fixture |
| 点击问题步骤查看详情 | 是 | `NativeStepDetail`、`NativeStepContext` | `ProofRow.original/math/message/dependencies`、步骤来源映射 | 是；当前条件与目标由已存记录生成 | `.stepDetail` 页面 fixture |
| 修改问题步骤 | 是 | `NativeEditing` | 本地 `draft`；记录在本地失效并保留 previous record 作对照 | 不会自动调用后端/DeepSeek | `.editing` 页面 fixture |
| 主动重新验证 | 是 | `NativeEditing` / `NativeWorkspace` 主按钮、`NativeStore.verify()` | 用户主动操作后创建 `/api/jobs` | 是；保留 cache、single-flight、去重、request audit | 预览编译里 `verify()` 被短路，仅作 UI 呈现 |
| 查看原稿图片 | 是 | `NativeSourceMapping`、`NativeRecognition`、`NativeStepDetail` | 后端 asset 与步骤级 sourceRefs | 是；原图与规范化数学内容来自已存来源记录 | 有本地原图 fixture |
| 原稿与规范化内容差异/歧义 | 是 | `NativeRecognition`、`NativeAmbiguity`、`NativeSourceMapping` | recognition blocks、ambiguities、用户 correction 记录 | 是；仅显示后端已有差异，来源精度仍是步骤级 | 有 recognition 录制样例 |
| 历史无记录 | 是 | `NativeHistory` | `/api/history` 返回空列表 | 是 | 有“历史：无记录”样例 |
| 历史记录列表 | 是 | `NativeHistory` | `/api/history` 与已保存 artifact | 是 | 有“历史：有记录”样例 |
| 打开历史证明 | 是 | `NativeHistory` → `NativeStore.openHistory` → `NativeResult` | 保存的 verification/formalization/recognition artifacts | 是 | 预览编译中打开动作不会访问后端 |
| 历史记录/原稿读取失败 | 是 | `NativeHistory` 的行内错误信息 | artifact/来源读取错误 | 是；不会误显示为证明错误 | 有“历史：读取失败”样例 |

## 预览与正式数据边界

- `build_native_preview.py` 编译独立的 `UI_FIXTURE` 目标。工具栏“状态样例”只设置本地 `NativeStore` 状态。
- 预览目标中的 `verify`、识别、导入、历史读取和解释入口不会访问 Provider；历史样例从随预览包携带的记录读取。正式 App 没有 `UI_FIXTURE` 编译标记，使用真实 API。
- 正式 UI 不把 MathIR JSON、Lean source、raw diagnostics 或 provider/token 信息作为默认内容。形式化细节仅由用户主动打开。
- 识别进度、导入进度、编辑状态和错误摘要是 SwiftUI 本地状态；验证结果、证明步骤、歧义、任务进度及历史记录来自实际后端；录制响应只在 fixture 预览中展示。

## 本轮实测（2026-10-09）

- 已构建 `build/NativePreview.app` 并通过无 Provider 的本地状态样例逐项检查：空白输入、已输入未验证、导入处理中/失败、识别处理中/失败/完成、识别歧义、验证中、全部通过、部分失败、失败步骤详情、修改状态、无法形式化、系统异常，以及历史无记录/有记录/打开历史证明/读取失败。历史条目和证明结果均带有 fixture 标记，不能作为正式验证证据。
- 修复了两个仅影响 fixture 的状态切换问题：输入状态切换时默认成功记录会覆盖空白/草稿样例；识别处理中样例会继承上一状态的识别错误。`UI_FIXTURE` 下的历史样例现在可打开随包录制证明，正式历史逻辑未改变。
- 正式 App 由 `python3 scripts/build_mac.py --reuse-backend` 重建，复用未改动的已打包后端；`codesign --verify --deep --strict` 通过。
- `MathPresentationChecks` 与 `TextRevisionChecks` 使用项目 Swift VFS overlay 实际编译并通过。Python 全量回归本次未执行通过：系统 Python 缺少 `jsonschema`，测试在收集阶段失败，未调用 DeepSeek。
- 当前同日的真实简单数学证明端到端记录见 [DeepSeek smoke 报告](reports/swiftui-final-proof-smoke.json)：用户提供的等式推理通过 DeepSeek、MathIR、Mathlib、Lean diagnostics/repair 和 Kernel，`kernelVerified=true`。此项是之前已完成的真实 smoke；本轮 UI fixture 检查没有新增真实模型调用。

## 后续原生 UI 复核（2026-10-09）

- 正式 App 中 `NativeDraftEditor` 已启用 AppKit undo manager；实测原稿选择、复制、粘贴与 ⌘Z 撤销可用，且原文恢复后未提交 AI 请求。
- 首页和工作区已减少重复的本机服务状态显示；普通输入页仍从正式 `NativeStore` 状态呈现，fixture 仍只用于预览。
- 正式 App 搜索 `add_sq` 得到本机 Mathlib 源码候选（50 条），不调用 AI；候选不是 Lean 核验结论。
- Python 3.12 隔离环境依据 `requirements-dev.txt` 安装依赖后，`pytest -q --ignore=tests/test_live.py` 实跑 `305 passed, 1 skipped`。唯一跳过项要求显式 macOS live runtime。
- 正式 App 由最终 SwiftUI 源码重建，`codesign --verify --deep --strict` 通过。没有运行真实 AI 或 Lean 端到端 smoke；当前 UI 代码未改动后端或 Lean 核心。
- 最终正式 App 窗口截图：[official-app-home-refined.png](reports/swiftui-functional-audit/screenshots/official-app-home-refined.png)。

## UI 状态补齐复核与真实 E2E（2026-10-09）

- 复核当前原生 SwiftUI 实现：空白/草稿/本地导入进度与错误、识别中/完成/歧义/识别失败、验证进度、成功/部分失败/无法形式化/Kernel 未通过/系统异常、失败步骤上下文、修改后待验证、原稿查看及历史状态均已有对应 View 和本地/后端数据绑定；未发现需要新增产品规则的缺口。
- UI fixture 预览目标重新编译成功，顶部标明“UI fixture / 已保存响应 · 不启动 Provider”；状态菜单覆盖空白输入、已输入未验证、导入处理中/失败、识别处理中/失败、无法形式化、历史无记录/有记录/读取失败。验证结果与失败步骤详情由随包录制证明驱动。正式 App 使用独立构建目标，不使用 fixture。
- 正式 Mac App 通过 `python3 scripts/build_mac.py --reuse-backend` 重建；后端二进制按脚本说明复用，`codesign --verify --deep --strict` 通过。
- 在这次重建的正式 SwiftUI App 中提交了一次简单等式证明。UI 经历“正在准备证明”并在同一 job 完成后切到结果页；真实审计为 6 次 DeepSeek 请求：MathIR 1、LibraryPlan 2（归为 other）、formalization 1、repair 2；没有图片识别，retry index 均为 0。最终 job `completed`，verification `status=formal_verified`、`kernelVerified=true`，两步均 `established=true`，App 显示“证明已通过核验”。详细记录见 [本轮 UI E2E smoke](reports/swiftui-ui-state-smoke-2026-10-09.md)。
- 本轮未运行视觉专项或大规模 live 测试。Python/Lean/MathIR/Provider 核心代码未改动。

## 本轮状态与构建复核（2026-10-09）

- 发现并修复了预览构建脚本仍引用已移除录制报告的问题。现在从 `tests/fixtures/ui/verification_success.json` 与 `verification_failed.json` 载入实际保存的响应；问题步骤页会使用失败记录，避免把两步全通过的记录误显示成失败状态。预览 HTTP 夹具也改为同一份已保存成功记录，正式 App 数据路径未变。
- `build_native_preview.py` 本轮实际编译成功并已打开。通过预览菜单实际检查了空白输入、已输入未验证、导入处理中、导入失败、识别处理中、识别完成（连同原图）、识别失败、正在验证、全部通过、部分失败、失败步骤详情及系统异常。夹具服务的请求记录只有本地素材加载，没有 Provider 请求。此前记录的歧义、无法形式化和历史夹具状态仍可通过同一预览工具复现。
- 正式 SwiftUI App 本轮重新构建并通过构建脚本内的严格签名校验；实际从 App 输入“设 a,b 为实数，已知 a=b。等式两边加1，得到 a+1=b+1，故 a+1=b+1。”后，页面依次进入验证中和成功结果。后端任务为 `completed`，Verification 为 `formal_verified`、`authority=lean_kernel`、`kernelVerified=true`，两步均已核验。此为本轮唯一真实 smoke，不是图片识别专项。
- 该 smoke 的审计按唯一 `request_id` 计 6 次真实请求：MathIR 1、Mathlib 检索计划 2、formalization 1、repair 2；全部 `retry_index=0`。修复请求均由真实 Lean 诊断触发。没有原图上传。UI fixture 状态遍历不调用 DeepSeek。
- 构建环境原 Python 3.9 缺少 PyInstaller；改用隔离 Python 3.14 环境完成构建。配置索引未提供项目锁定的 `uvicorn==0.48.0`，该构建环境使用可获取的 `uvicorn==0.39.0`，源代码的依赖声明没有修改；因此这个发行包的后端依赖版本与项目 pin 有差异，后续正式打包应先在可提供 pin 的构建环境重建。
- 本轮只修改了预览夹具装载与预览服务脚本，没有改动 SwiftUI 正式数据流程、DeepSeek、MathIR、Mathlib Retriever、Lean、Repair 或 Kernel 实现。

## 真实错误证明与修改闭环（2026-10-10）

- 真实 App 曾将 `missing_proof` 错显示为“暂时无法形式化”。已修正 SwiftUI 映射：`statement_not_elaborated` 表示“暂时无法形式化”；`missing_proof` 表示“尚无可验证的证明”，并说明不能据此判断数学结论错误。UI fixture 预览已实际构建，使用 `verification_failed.json` 中的 `missing_proof` 记录核对了新文案。
- 官方 SwiftUI App 中提交原证明 `a=b; a+1=b+1; a+1=b+2`。MathIR 保留原文及步骤来源映射；Lean 核验第一步通过、目标 `missing_proof`，`kernelVerified=false`。系统没有把原证明替换成另一份证明，也没有声称找到数学反例。
- 用户改成 `a=b; a+1=b+1; a+1=b+1` 后，编辑期间没有 AI 请求；主动点击验证后，第二个任务经真实 DeepSeek 与 Lean diagnostics/repair，最终两步 Kernel 均通过、`kernelVerified=true`。历史可分别打开未通过的原记录和已通过的修改记录。
- 两个真实任务共 14 个 DeepSeek 请求（原证明 5，修改后 9；其中 repair 共 5），无图像请求、无 retry。累计 Provider HTTP 用时 234.573 秒；细节见 [真实错误证明与修改闭环报告](reports/真实错误证明与修改闭环V1-2026-10-10.md)。
- 已将旧 Web/Stitch fixture runner 从普通 SwiftUI regression 入口隔离。它使用已过时的 HTML 选择器，不代表官方 SwiftUI 客户端；正式状态预览使用独立 `UI_FIXTURE` SwiftUI target。
- `scripts/check_offline.py` 实跑 309 passed、1 warning，TypeScript 检查通过；provider audit delta 为 0。已将旧 Web fixture 从此普通 SwiftUI 回归入口隔离。
- 正式 Mac App 从稳定 main 完整重建（重新打包后端，不复用旧二进制），SwiftUI 编译和 `codesign --verify --deep --strict` 通过，已安装至 `~/Applications/极简 Lean.app`。源提交完整 hash 记录在 App Info.plist 与本机安装收据。原打开进程仍在运行，需退出后重开以加载新版本。
- 当前变更只调整 `missing_proof` 的 SwiftUI 显示分类与旧 Web 测试隔离；没有改动 DeepSeek、MathIR、Mathlib Retriever、Lean、Repair 或 Kernel 源码/逻辑。
