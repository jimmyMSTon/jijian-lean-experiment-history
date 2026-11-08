# 极简 Lean · MathIR v2 第五阶段报告

基线 `f5dd230`。本阶段只修改 v2 研究旁路及其测试，没有改正式 v1 App、Mathlib A、DeepSeek Provider、MathIR v1、正式 Repair 或 Kernel 可信边界。新输入通过独立流程 `DeepSeek Flash → proof-free MathIR v2 → 固定 theorem statement → proof-only patches → Lean → 独立 Kernel`；生产验证路径没有切换。

完整逐请求审计、输入 MathIR、statement/structure lock、proof patch、Lean diagnostics、Kernel 证书摘要、资源数值见 [机器可读证据](mathir-v2-stage5-audit-evidence.json)。该附件保留了新 live 输入的核心证明材料，不包含大型 Lean AST wire dumps。原始本机运行记录仍在 `reports/mathir-v2-stage5-live-e2e.json`，不纳入 Git。Stage 4 历史矩阵见 [第四阶段研究报告](MathIR-v2-stage4-live-sidecar-study.md)。

## 结论

固定 theorem 的 Kernel 通过与用户原推导路线完整通过现在是两个独立字段。`fixedStatementKernelPassed` 只回答锁定的最终命题是否有 Kernel 证书；`anyRouteKernelPassed` / `completeOriginalRouteKernelPassed` 还要求原路线的所有 claim 有证据、路线连接到目标、声明依赖被 proof expression 实际使用、组合检查通过。局部命题 Lean/Kernel 通过不能弥补缺失步骤或断裂依赖。没有证明的步骤和被 Lean 拒绝的 proof 均是 `incomplete` / `not_established`，不等于已证明数学上为假。

原反例已经以本机 Lean/Kernel 集成用例编码：`2=2` 与 `1=1` 是两个无依赖的 `by rfl` claim。最终 theorem `1=1` 的独立 Kernel 证书仍保留，路线由于无关步骤 `2=2` 不在目标依赖闭包而为 incomplete。额外用例覆盖声明但未使用依赖、错误推导关系、有效依赖链，以及一条错误路线和一条正确路线并存。测试不会删除这些步骤以提高通过率。

## 真实新输入能力矩阵

两个新文本样本均直接发给 DeepSeek Flash，MathIR 阶段强制 `proofTerm=null`。之后模型只收到固定 statement 与原步骤，为缺失步骤给出 `{nodeId, proofTerm}` patch。所有 theorem statement 和结构在应用 patch 前后均由 hash 锁定。AI 返回的 proof term 明确标成系统形式化结果，不称作用户原稿 proof。

| 新样本 | 来源与 MathIR | 首次 Lean 结果 | Repair | 最终 Lean/Kernel 与路线 |
|---|---|---|---|---|
| 正确：`x=1`，两边平方得到 `x²=1` | 原文字段完全一致；结构输出没有 proof term；一步 claim 来源指向平方推导，显式依赖输入条件 `x=1` | Flash proof-only 生成了该 claim 的 proof；Lean 验证通过；依赖使用审计为 true | 无 Repair 请求 | 固定 theorem Kernel 通过，独立证书 `checked=true`、`statementMatched=true`，无额外公理；完整原路线 `passed`。结构/来源的语义对应仍是 AI 与 sourceRefs 提供的证据，不由 Kernel 证明。 |
| 错误推理：`x=1`；原稿称两边加 1 得 `x+1=1`，再推出 `x=0` | 原文字段完全一致；保留了错误中间 claim 和它到结论的依赖；没有删除或改写原步骤 | 中间 claim 没有 proof；结论 proof 第一次被 Lean 拒绝，diagnostic 为函数式局部上下文与预期 `x=0` 类型不匹配 | 有 1 次真实 Repair，理由是该结论 proof 的新 Lean diagnostic；statement 与结构 hash 不变。Repair 后局部结论 proof 通过，但错误中间 claim 仍缺 proof | 固定 theorem Kernel 未通过，因整条路线未构成 theorem proof；路线 `incomplete`。这不是 Kernel 对 `x=0` 的反证，而是原路线至少有一个必要步骤未证明。 |

正确样本耗时 113.589 秒，2 次真实 DeepSeek 请求（MathIR 45.473 秒，formalization 2.807 秒）；Lean 5 个 subprocess stage，累计 65.138 秒。错误样本耗时 158.182 秒，3 次真实请求（MathIR 41.411 秒、formalization 12.694 秒、repair 9.006 秒）；首次 Lean 3 个 stage/39.964 秒，repair 后 4 个 stage/54.924 秒。各阶段 HTTP 时间与 token 分项在机器记录中。

两样本共 5 次真实 API 请求，输入 11,112 tokens、输出 26,922 tokens，HTTP 等待时间合计 111.391 秒；无 retry。另有早期两个 MathIR 契约调试请求，分别暴露 `dependsOn` 引用了 theorem assumption 而非 route node，以及把 `targetType` 放到非 `ascribe` 节点。后者共 2 次真实请求、输入 7,372 / 输出 24,176 tokens；其输出仅用于离线重放和确定性修复，没有继续 Lean 或 Repair。故本阶段所有研究活动合计 7 次真实 DeepSeek 请求：输入 18,484、输出 51,098 tokens、无 retry。两次调试失败是 schema/归一化问题，不是模型数学能力样本。

## 路线与 proof provenance 实现

`backend/v2/verify.py` 分别保留步骤结果、固定 theorem Kernel 结果、路线组合与连接性。目标节点依赖闭包之外的 claim 会被标为 unconnected；所有源 route claim 都保留独立 Lean 结果。声明依赖是否实际出现在数据式 proof expression 中，使用既有 fresh-environment Kernel dependency-use audit。归纳结构的 base/step 显式结构边继续纳入组合图。各路线单独判定；一条正确路线只使该路线及 any-route 通过，错误路线保留 incomplete。

本地 Lean Runner 在每次 `verify_v2` 响应附加 Lean 子进程数量与累计耗时。将一组 expected proposition 在同一个 Lean statement probe 中 elaboration 后，将 probe 得到的表达式传给每个独立 proof check，避免每条 proof 再重复解析 statement；每个 proof 仍单独导出，并在独立的新 Lean 环境里进行 data-only Kernel replay。可信边界未改变。

新旁路中的 MathIR 阶段使用严格的 `StructureOnlyMathIRV2`，不让模型在结构输出中写 proof term。`proof_only.py` 将后续模型响应限制为 proof patches；`ProofLock` 同时锁 theorem statement hash、proof-term 清空后的完整 MathIR 结构 hash，并保护运行前已经存在的 proof。Repair 仅替换该轮记录为 AI 生成的 proof term，输入必须包括当前 Lean diagnostics。报告区分 source slice、输入 proofTerm、formalized proof term 与每次生成/修复来源，避免将系统生成物标成用户原稿。

`source_normalization.py` 处理当前模型会把定理前提 ID 直接放进 `dependsOn` 的契约错位：在 route 内创建表达式与来源引用完全相同的 `local_assumption` 节点并改用其 route ID；原 theorem assumption 和 statement 不变，并由 statement hash 检查。此自动映射仅适用于 ID 明确对应的 theorem assumptions，其他未知依赖仍报验证错误。

## v1 历史对照

第四阶段五个历史样本由真实 Flash 结构输出产生，随后对保存结果本地回放：正确等式原路线完整通过；错误等式缺目标 proof；从 1 归纳缺 step proof；有理数有限和缺最终目标 proof；相依多项式 fixed theorem 与各 claim proof 通过但两项定义依赖没有被 proof expression 实际使用，故路线 incomplete。历史样本记录于 [第四阶段报告](MathIR-v2-stage4-live-sidecar-study.md)。

这些历史五题不是本阶段两条新样本，调用条件、MathIR 产物和输入类别不同，只作纵向案例并列，不能计算成 paired A/B 或一般成功率。早期两条契约调试输出也不算新的数学能力结果。

## 工程缺陷与待定契约

已修复的确定性工程问题：当 AI 把 route 依赖写成顶层 theorem assumption ID 时，v2 之前拒绝了可无损映射的显式前提；现在显式复制为 route-local assumption，保留同一假设与 statement。之前非 Kernel 通过会被输出为 failed，容易被误读为数学错误；现在统一 `incomplete` 并保留 `proofAttemptStatus`、Lean diagnostics 和 Kernel 证书。原路线判定增加目标闭包、每个 claim 的局部验证、dependency-use 和 route composition 的组合条件。长路线 statement 重复 elaboration 的 Lean subprocess 数量也通过批量 probe 降低，没有复用 proof 环境。

需要 MathIR/UI 契约决定的事项没有被工程逻辑猜测：一个 route 中的旁注、被放弃尝试、无关演算行是否为 claim，及如何明确标记；多路线的原稿范围；定义展开何时属于推导步骤、何时只是背景定义；每个步骤 sourceAssessment 的依据和语义强度；归纳 base/IH/step 与结论行在原稿中的精确组合；行间计算省略时是否可作为“系统形式化推导”呈现，但不能归为原稿已写步骤。当前 schema 无 annotation/discarded-attempt typed node，因此本阶段不会推测这些角色或自动删除行。

## 资源与验证

两次 live workflow 的 Python 进程峰值 RSS 分别为 53.25 MiB、98.47 MiB。`getrusage(RUSAGE_CHILDREN)` 记录到的最大单个 Lean checker 子进程峰值 RSS 分别约 5,772 MiB 与 5,789 MiB；该值不是整机内存，也不是各 Lean 进程求和。本阶段 Lean 调用顺序运行，没有并行启动验证进程。运行结束后需确认没有遗留 Lean/proof checker 子进程。

当前已完成：`nice -n 15 .venv/bin/python -m pytest tests/v2 -m 'not lean_local' -q`：**34 passed, 4 deselected**；`compileall` 与 `git diff --check` 通过。Stage 4 五份实际模型响应的本地 v2/Lean/Kernel 回放全部执行，结果如上。两个新输入是真实 DeepSeek + 本机 Lean + 独立 Kernel 的新旁路样本，不是 fixture。没有开启大规模 live 测试，也没有执行图片识别或 macOS App 构建。

纯 Lean/Kernel anti-counterexample 集成用例实际执行 **1 passed, 4 deselected in 353.43 秒**；其中同一用例依次检查独立 `2=2`/`1=1`、unused dependency、有效依赖链、错误推导关系。其余 4 个被选择器排除的 Lean 专项测试没有算作通过。

## 接入建议

v2 适合继续作为隔离研究旁路。现有证据表明：无损依赖归一化修复了可确定转换的 schema 错位；正确新样本完成了原路线 Kernel 闭环；错误新样本被明确标为 incomplete，且局部 proof 通过没有覆盖缺失的错误中间步骤。语义路线是否完全等同于用户心中的证明仍依赖 MathIR 对原稿角色与推理关系的表达准确性。建议在决定产品接入前先明确上节契约项；现阶段不替换正式 v1 结果、不改变 Kernel 结论，也不把有限样本作为普遍能力率。
