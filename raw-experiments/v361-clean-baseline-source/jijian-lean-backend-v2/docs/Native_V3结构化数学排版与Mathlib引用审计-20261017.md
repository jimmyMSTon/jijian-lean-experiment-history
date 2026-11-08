# 极简 Lean｜MathIR V3 通用数学结构渲染与 Mathlib 声明引用审计

日期：2026-10-17。开发工作树：`/[LOCAL_USER]/Documents/ChatGPT/极简lean-typed-math-visual`，分支 `codex/native-typed-math-visual`，从已提交 Native `20b8b70` 出发，独立于 Codex 正在开发的数学后端及打包工作。合入之前不得将源码视为用户已安装版本。

## 这次解决的功能断层

V3 后端已支持开放的 Mathlib 声明、显式类型参数、依赖 Π 类型、高阶匿名函数、分段值、数值转换与来源闭合引理；原生客户端过去大多把 MathIR Expr 递归串成纯文字 `op(...)`，复杂矩阵、分式、函数等不能复用已经建成的原生公式网格。用户难以区分自己写的原文与系统真正尝试验证的结构化数学表达。Mathlib 常量及其模型填写的类型声明和来源也未形成可审阅的汇总。

## 本轮主体实现

1. **NativeMathIRPresentation.swift（纯 Foundation）**：实现只读 MathIR → `NativeMathAtom` 原生数学布局。处理加减乘除、等式/不等式/集合关系、嵌套分数和根号、指数、组合数、平方范数与内积、复数、矩阵转置/行列式、类型明确的矩阵与向量字面量、实数区间积分、含真实开闭端点信息的求和/连乘、条件分段值、量词和声明约束、lambda、Mathlib 常量及类型参数、ascribe/cast/coerce、参数化 TypeApplication、依赖 Pi、抽象与未定载体。原语义无法安全投影时保留原操作名并显示原因；绝不从矩阵元素个数猜维度、从缺失的求和 upperInclusive 猜端点、把多项式除法当普通数域分式、或者凭 UI 认定一个 Mathlib 常量已存在。
2. **NativeMathIRProjectionView.swift**：结果页、工作台、原稿对应页、步骤详情、验证中界面共享的可展开数学解释。原稿对应 SourceRefs 仍来自保存的真实 Unicode 区间；结构化视图在独立标题下显示模型数学解释。步骤复合 ID 按实际 `routeId + "/" + nodeId` 唯一求解，同时检测相同键可能对应两个不同的 route/node 组合或重复 ID，不随便选第一项。已保存 Lean 目标仍由原 verification 行独立提供，不被排版器替换。
3. **NativeMathIRReferenceIndex.swift + NativeMathIRReferenceAuditView.swift**：只读遍历当前 MathIR 声明、前提、目标、原证明节点、依赖类型参数内的 Mathlib 常量使用。按严格 name + declared type + 显式类型参数分组；每次使用保留独立路径、SourceRef 和原文对应情况，显示无来源区间与重复来源 ID 的警告。这里的类型是“模型记录的声明类型”，不是 Mathlib 的自证类型或 Kernel 结论。
4. **NativeProofReport.swift**：已有 Markdown/PDF 核验报告补充 Mathlib 名称、模型声明类型、显式参数与来源链接覆盖，文本始终写明需要真实 Lean elaboration；不触碰报告原有逐步 Kernel 状态和历史保存。
5. **NativeMathTypesetting.swift**：类型化表达式复制菜单单独标记“复制 MathIR 结构化数学解释”，原数学稿复制操作继续称“复制原始数学公式”，不会将两者混为一谈。

## 实际回归入口

- `scripts/check_native_rich_math_presentation.py`：真实 Swift 可执行数学结构测试，覆盖分式/矩阵/向量/分段/求和端点/Π/Mathlib 类型参数/来源索引；同时对 Codex 的 `mathir-v3-linear-map.json` 和 `mathir-v3-case-scopes.json` 运行跨层合同检查。
- 原 `scripts/check_native_math_document.py` 继续负责已有原稿/编辑/来源/证明路线/历史/PDFKit 本地实测；其报告回归已纳入新的 Mathlib 来源索引。
- 全部 `macos/Native/*.swift` 类型检查，以及完整 Native 优化编译与正式 App 构建均以实际编译回执为准。以上“已实现”描述不代表实际用户 GUI、真实 DeepSeek 识别或新一轮 Lean/Kernel 证明链路已通过。

## 数学安全边界

所有新功能只读取 **已保存** 的原文、MathIR、SourceRef 和 Kernel 结果；不重写 MathIR、不插入 Lean proof、不猜数域/维度、不提升模型自称状态、不触发 DeepSeek。视觉排版正确、语义翻译忠实、Mathlib 符号实际存在、Lean 代码类型通过、独立 Kernel 证书通过，分别是不同的命题。必须由各自证据证明，不能互相取代。

与 Codex 的后端数学语言扩建并行推进。已有示例是受控合成数学文本，不代表所有真实手写输入都能成功识别或形式化。此次只提升新数学语言在 Mac 上的完整承载和来源解释能力，不创造新的数学业务 Gate、次数限制或默认条件。
