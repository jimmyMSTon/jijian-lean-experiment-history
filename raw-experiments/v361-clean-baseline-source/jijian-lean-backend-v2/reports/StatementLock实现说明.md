# Statement Lock 与测试边界

MathIR 的 formal.expressions 保存数据式数学 AST，包含变量引用、类型、量词、前提及结论。canonical_plan 生成固定符号表、canonical specification；Compiler 生成 Lean statement 和 statement_hash。Flash 只填写 proof：首次用固定顺序 proof 数组合并一次请求，repair 每个选定片段仅返回一个 proof。历史 MathIR 可读取，但缺少结构的记录不能通过新版生产 formalization 冒充已锁定 statement。

结构检查包括代码生成声明的解析树比较与真实 Lean elaborated Expr 比较。变量名称使用绑定索引处理，允许 alpha-renaming；类型、外部前提、量词及结论变化拒绝。绑定表包含原义、Lean 类型和标识符、scope、kind、dependencies。repair 只包含 fixed_statement、statement_hash、binder_map、current_proof、lean_goal、local_context、diagnostics、mathlib_candidates，返回 schema 仅 proof。STATEMENT_DRIFT/BINDER_DRIFT 会令 Kernel 结果为 false，即使旧证书为 true。

本次没有恢复全局 live 开关、pytest 网络阻断、环境自动 fixture 替换，也没有改变 DeepSeek 模型或增加产品重试次数上限。生产 Provider 正常调用 deepseek-flash；开发缓存命中复用实际录制，未命中正常访问。fixture/stub 由具体本地测试显式选择，不全局拦截 Provider。

本地回归：296 passed（1个第三方弃用 warning）。包含新 statement/schema/type/alpha-renaming/前提变动/绑定遮蔽/Kernel 成功不得覆盖 drift 测试；这些使用 fixture/stub，不代表实际 AI 成功。TypeScript 使用本机已有 TypeScript 编译器通过。Lean Export 模块已真实编译；三题实际 AI/Kernel 结果另见 statement-lock-three 目录，不把本地替身测试当成真实验证。

边界：锁定对象是结构化 MathIR 的数学陈述；自然语言到 MathIR 是否完全忠实仍需核对来源。Kernel 验证形式化命题，不证明自然语言识别正确。表达式类型支持当前数据式 AST 的运算和复杂对象；无法确定类型时报告绑定错误而非让 proof 模型猜类型。

批量 jj_expected 现在使用首次命令的 import-only baseline，后续复用的数值/类型类辅助声明也包含在导出闭包。原始 Expr 比较先展开导出辅助；如仍有提取/内联或 proof irrelevance 差别，独立 Lean 环境在 Kernel replay 前验证实际声明 type 与固定目标的 definitional equality，并要求证书 statementMatched=true。源码/MathIR/binder/hash 的 drift 仍在 proof 运行前拒绝，不能由 Kernel 成功覆盖。实际 altered-declaration 检查使用同一平方题 proof 数据，把声明 type 改为 False 后被真实 Lean 标记 STATEMENT_DRIFT，0 AI 请求。
