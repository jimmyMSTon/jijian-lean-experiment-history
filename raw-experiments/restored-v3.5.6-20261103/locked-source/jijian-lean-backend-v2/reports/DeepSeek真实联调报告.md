# DeepSeek 真实联调报告

2026-10-06；本机 macOS 15.2 arm64；Lean / Mathlib 4.34.0。仅使用 DeepSeek，无 Mathpix、OpenAI 或第三方 Gateway 调用。

用户填写服务端 server.env 后显式授权本次 API 测试。密钥未显示、未写入源码/报告、未打进 Mac App。配置模型保持 V2 的 deepseek-flash：账户真实 /models 返回 HTTP 200 且包含该 ID，实际识别、生成与修复响应也为该 ID。响应未给出完整 V4.1 版本号，不额外猜测版本或切换模型。

## 严格分类的已完成证据

| 分类 | 结果 | 原始证据 |
|---|---|---|
| DeepSeek 真实 API | 成功，生成数学证明片段；不是 hello world | deepseek-live-first.json / deepseek-models-live.json |
| 单个真实 AI 片段的 Lean Kernel | 通过，实际独立证明对象复核 | deepseek-first-kernel-live.json |
| 自然中文数学 → MathIR → theorem statement → 检索 → proof → Kernel | 完整通过，两个步骤及整体证书；原文为实数等式两边加1 | flash-mathir-kernel-live.json / .log |
| 本地 Mathlib Retriever | 实际查证类型；批量测试4个真实声明成功、1个不存在声明失败；简单证明检索7项，手写例子139项 | mathlib-batch-live.json；上述流水线记录的 retrieval 与 statementChecks |
| 中文印刷证明图片识别 | 真实 Flash 识别成功，人工对照原图文字/公式正确 | deepseek-e2e-live.json 的 printedImage、live-printed-proof.png |
| 中文真实手写照片识别 | API 成功，但文本准确度部分通过；有乘积因子遗漏及难辨字形，不记作全文准确成功 | handwritten-flash-live.json、handwritten-audit-live.json |
| Flash 诊断修复闭环 | 完整通过：真实 Lean 拒绝 → 真实诊断回传同一 Flash → 修复 → 整体独立内核复核；1次修复，MathIR/类型哈希不变 | flash-repair-live.json / .log |
| Stitch 真实端到端 | 实际浏览器上传印刷证明图片、识别页面、快速模式、jobs/events、真实 AI/Lean 完成、验证记录渲染；无页面 JS 错误；保留 recognitionId 来源 | ui-flash-live.json、ui-flash-live-final.log、ui-flash-proof-live.png |
| 自然模型错误的片段修复 | 真实手写基始片段重复 intro 导致失败；诊断交给同一 Flash 后返回 by rfl，独立 Kernel 通过；非注入错误，仅该局部片段 | natural-flash-scope-repair-live.json / .log |
| Stitch 结果视图 | 真验证记录的依赖图、默认隐藏 Lean、主动展开才取代码；不是虚构验证结果 | ui-flash-result-views-live.json、ui-flash-graph-live.png |
| 来源与修订接线 | 实际后端记录切换页面保留来源，键盘及菜单编辑解除旧识别绑定；难辨项实际显示 | recognition-handoff-live.json、ui-handwritten-uncertainty-live.json / .png |
| Mac App | 最新源码 PyInstaller / clang 重建，codesign 本机验证通过，原生 WebKit 启动成功并读取服务端配置 | mac-build-flash-final.log、native-flash-final.json / .png |
| Mock / 测试替身 | 默认回归175通过、7显式集成项跳过；包含测试替身，不等于真实 API 或 Kernel 成功 | pytest-flash-mac.xml / .log |

内核证书 auditMethod 为 fresh_environment_data_only_kernel_replay，额外公理为空；不是把 HTTP 200、任务 completed 或模型解释当作证明通过。originalMeaning 仍为模型解释状态，不声称 Lean 能证明自然语言与翻译完全等价。

修复闭环的错误触发是测试者刻意替换一个 proof 为不存在的 Lean 标识符。数学原文、MathIR、类型未改变，真实诊断、模型修复与复核没有用替身。此项明确是注入编译错误测试，不冒充模型自然产生该错误。

## 实际修复与保留的失败记录

本地检索原先逐个启动 Lean 加载 Mathlib，遇到源码候选较多会很慢。已改为单个隔离进程逐项 #check，保留所有候选与位置对应类型/诊断，无候选数量上限。一个不存在声明不擦掉其他声明的真实类型报告；导入或全局错误会使全批失败。21项相关回归通过，另有上述真实批量查证证据。

旧串行测试任务被显式取消，取消不表示数学命题为假。已保存的真实 MathIR 用于接续编译；Stitch 又通过实际图片上传重跑完整真实流程。旧日志保留，不能把中断项报为通过。

修复识别 → 快速模式来源丢失以及原文/菜单修改后引用旧识别记录的问题。修订记录与原文仍保留，修改后的输入不沿用旧证明通过状态。增加难辨字符显示，仅渲染文字，不自动选一个解释，也没有新增审核 Gate。

生产 DeepSeekProvider 固定直连，旧 Gateway 配置不能转发第一版请求。环境模板不再要求 Gateway；原包历史兼容适配源码保留，未用于正式 Provider。

## 用户手写照片的独立结果

原始照片保留在用户提供的路径及实际后端资产中；首次识别没有被独立复核覆盖。真实结构化生成11个证明步骤，保留4项未解决歧义。首次 OCR 把 sinθ·sin(nθ) 遗漏为 sin(nθ)，复核仍对该行和整系数/整数次字形不确定。识别 API 成功不代表每个符号准确。

按蓝笔首项确实为2*cos((k+2)θ)的读法，k=1、θ=0构成该等式的反例；已由真实 Lean 数据式内核复核验证（handwritten-blue-counterexample-live.json）。这是一项条件式诊断，不是替用户改写原证明。

该手写例子的12项 theorem statement 已实际 elaboration；形式化返回若干 proof=null，反映识别/归纳结构未闭合，不能说原证明已通过。完整步骤验证已结束：kernelVerified=false，批量修复返回真实 HTTP 400，outcome=repair_not_completed。最终记录为 handwritten-mathir-kernel-live.json / .log。该整单未通过，不计入成功；独立诊断调用未复现 HTTP 400：LibraryPlan 与 FormalProofs 均真实返回成功；原失败原因尚未确定。新批次片段未再次整体编译或 Kernel 核验，不能计为整单通过。证据为 handwriting-repair-diagnostic-live.json / .log。

## 尚未实测/交付边界

实际摄像头、iPhone 连续互通、其他 Mac 安装与 Apple Developer ID/公证未执行。App 为本机92MB左右开发版，依赖外置当前 Lean/Mathlib 路径，不声称可在任意 Mac 直接安装。测试数据隔离在 .data-live，不把注入错误或测试样本默默插入正式 App 历史。

第一版没有 Mathpix、OpenAI 或 Gateway 凭据阻塞。此报告取代旧历史报告中“尚无 DeepSeek 密钥”的当前状态判断。

## 后续真实问题修复

手写形式化中出现模型把 expectedType 的整体绑定再次 intro 进已经绑定的 context，导致本可 rfl 的基始片段失败。已在正式提示中明确：proof 只证明 conclusion，context 名称已经存在，expectedType 供后端整体审计；只有 conclusion 本身仍有量词时才能引入新绑定。没有在后端自动删掉模型输出或伪造成功；上述自然错误片段的诊断、真实 Flash 修复和独立 Kernel 证据单独记录。

修复迟到的验证/识别读取覆盖用户新编辑原文的竞态；历史结果打开时恢复对应原文并解除此前识别绑定。input-revision-races.json 使用实际后端读取响应及真实证书记录，延迟传输以触发竞态；为只检查提交内容，该测试刻意中止 job POST，不调用供应商，不作为真实 AI 调用成功。没有伪造数学返回体。

连续识别修订按用户提交顺序串行写入实际后端，防止快速修改两个区块时丢失前一次修订；恢复记录时同步对应原图，防止旧图与新文字错配。recognition-edits-live.json 记录两次真实修订与原图一致性检查；不调用供应商。供应商失败只返回经过密钥脱敏的错误代码/说明，没有新增自动重试。

最终源码已通过 TypeScript 编译及 UI 构建；最终 App 已重新打包、通过 codesign --verify --deep --strict，并实际启动原生 WebKit 首页。包内检查未发现 .env/server.env 或开发数据目录。

最终 scripts/check_examples.py 实际执行通过（固定数学例题、无 AI 调用），独立内核复核额外公理为空；记录 examples-flash-final.log。
