# Mathlib 候选证据离线研究工具

本目录是独立研究代码。它没有 Provider / HTTP 发送器，不会调用 DeepSeek，也没有接入正式后端。请求 JSON 是可核对的最终 request body 草案，`executionState` 明确为 `planned_not_sent`。

主输入 `fixtures/equation_v3_302_288.json` 是原始 V3 等式 retrieval、修复 diagnostics、形式化记录和历史通过结果的快照。fixture 保留完整 302 个声明、288 个来源行，以及历史修复请求的来源/usage。其重建 payload 的 fingerprint 必须与历史审计 `8979f0…` 一致。

代数、归纳、三角样例使用两份分开的数据：`*_saved.json` 保留当时实际存档；`*_local_reconstruction.json` 保存本机 Mathlib 源码树按同一存档 query 重新检索并批量 `#check` 的结果。重建记录不覆盖原始 retrieval。归纳旧记录因缺少显式 induction structure 被当前 Compiler 拒绝，所以不生成 request plan，也不在研究工具里修补 MathIR。

## 重跑离线流程

从仓库根目录运行：

```sh
.venv/bin/python devtools/research/mathlib_candidate_evidence/rebuild_sample_sources.py
.venv/bin/python devtools/research/mathlib_candidate_evidence/compare_evidence_only.py
.venv/bin/python devtools/research/mathlib_candidate_evidence/plan_requests.py
.venv/bin/python devtools/research/mathlib_candidate_evidence/plan_cross_sample_requests.py
.venv/bin/python -m pytest devtools/research/mathlib_candidate_evidence/test_research.py -q
```

`rebuild_sample_sources.py` 使用本机准备好的 Lean/Mathlib 4.34.0；它运行本地词法来源查找和 Lean `#check`，不发网络请求。其它脚本只在已有 fixture 上执行序列化和 fingerprint 自检。

`generated/requests/` 保存主 302/288 样本 A/B/C+ 三个最终请求结构；`generated/requests/cross-samples/` 保存代数与三角修复的计划体，manifest 记录被排除的归纳旧 MathIR。查看请求计划不会发送请求。主 A 的 input hash 和历史审计相同，B/C+ 的 hash 应各异；prompt/schema/model 与其它固定字段相同。

V6 经明确授权后执行了冻结计划；复查结果保存在 `generated/live_v6/`。`run_live_comparison.py` 默认只做重建、body/hash、statement 与候选证据预检，不发 HTTP；本轮运行时另加 `--execute` 才发送计划中的 9 个请求。每次先写 ledger 再请求，成功响应和 usage 到达后立刻持久化；网络错误记为 `outcome_unknown`，不会自动重发。`validate_live_comparison.py` 只读取已存响应，按 MathIR 固定顺序运行 Lean，并对完整 aggregate 使用现有独立 Kernel runner；它不访问 Provider。复现已完成的检查：

```sh
.venv/bin/python devtools/research/mathlib_candidate_evidence/run_live_comparison.py
.venv/bin/python devtools/research/mathlib_candidate_evidence/validate_live_comparison.py
.venv/bin/python -m pytest devtools/research/mathlib_candidate_evidence/test_research.py -q
```

## C+ 编码

C+ 保留每一条 source row 的所有字段。`sourceFiles` 对 module、相对路径和 SHA-256 去重；五个 `sourceTextTables` 分别去重 sourceName、namespace、declarationLine、declarationHeader、evidence；每条 `sourceMatchRows` 用声明索引、文件索引、行号和文本表索引表示。声明行仍保留到文件的来源引用。`decode_c_plus` 可以将 prompt evidence 逐字段还原为 A。原始 full retrieval 始终独立保存在输入 fixture。

## 请求恢复账本

`ledger.py` 仅提供可嵌入研究 runner 的 SQLite 账本，不发 HTTP。调用方先持久化 request body/hash，再将发送状态置为 `in_flight`；收到响应后必须先存储完整响应与 usage，再做 schema/Lean 检查。重启时 `response_saved` 可复用；停在 `in_flight` 的请求转成 `outcome_unknown`，不会被自动重发。tests 使用本地对象演练这两种恢复，不代表真实 API 调用。
