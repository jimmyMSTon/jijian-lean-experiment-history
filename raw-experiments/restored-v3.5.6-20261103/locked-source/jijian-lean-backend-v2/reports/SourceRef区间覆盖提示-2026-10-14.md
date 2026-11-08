# SourceRef 区间覆盖提示（2026-10-14）

## 本次改动

V2 验证结果新增 `sourceCoverage`，并由 `compact_verification` 原样保留在任务结果、历史结果和 Native 可读取的精简验证对象中。每个 ProofRoute 也包含自己的 `sourceCoverage`。

字段按经过 `compile_v2` 校验的 typed `SourceRef` 区间计算，索引单位是 Python Unicode 码点，与 V2 的 `start/end` 契约一致。相互重叠或相邻的区间在计数前合并；只计数非空白码点。整体与每条路线的 block 行列出未被引用的非空白区间；单个步骤与归纳 case 只列出其直接引用的块、SourceRef 数量和覆盖的非空白码点，避免将整段原文缺口重复复制到每个步骤。

主结果路径为 `sourceCoverage.structureBlocks` 和 `sourceCoverage.routes[]`；路线的 `steps[]`、`inductionCases[]` 可以检查直接来源范围。`allSourceRefsValidated` 表示进入 Lean 验证前，参与计算的 typed SourceRef 均通过了块存在、非空和边界验证。旧历史记录没有该字段时，读取端继续保留“字段缺失”，不会回填或伪造覆盖数据。

## 正确性边界

该信息是区间覆盖提示，不证明某个范围的文字在数学语义上支持其对应的 MathIR 节点。覆盖一个很宽的范围也可能错误地关联到某一步；`semanticEquivalenceProven` 固定为 `false`。它也不证明 OCR/转写文本与原始图片、笔迹或文件内容一致，不会自动推断遗漏步骤，更不参与 `fixedStatementKernelPassed`、`anyRouteKernelPassed`、`kernelVerified` 或 proof route 状态。

因此，完整区间覆盖只能说明当前结构的 typed SourceRefs 联合起来覆盖了多少 source block 文本；不能把它解释为原稿忠实性已经通过。未覆盖区间同样只是审阅提示，不自动意味着数学错误。

## 回归证据

- `tests/v2/test_source_coverage.py` 覆盖 astral emoji 的 Unicode 码点索引、重叠引用并集、路线与单步骤覆盖差异，以及 compact API 保留字段而不改 Kernel 状态。
- 定向验证：SourceRef 覆盖与 compact API `3 passed`；Native 历史/精简结果契约 `2 passed`，合计 `5 passed`。
- 完整非 live 回归：`478 passed, 24 deselected, 0 failed`；1 条 Starlette/AnyIO 弃用警告。
- `compileall` 与 `git diff --check` 通过。
- 本次 DeepSeek、视觉模型、Lean 子进程和 Kernel 调用均为 0。未执行真实图片识别或新鲜模型输入。
