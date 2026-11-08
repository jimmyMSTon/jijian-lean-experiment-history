# 极简 Lean 非 CMO 泛化攻坚：Codex 证据报告

日期：2026-10-31（Asia/Shanghai）  
研发仓库：`/[LOCAL_USER]/Documents/ChatGPT/极简lean 2`  
分支：`research/long-proof-compiler-20261031`  
起始提交：`b98fd42e5e968476a367986c216dee293533752e`  
本轮提交：`3e678f7` — `fix: compile wrapped scaffold bodies against locked goal`

## 本轮结论

本轮修复了源步骤证明 scaffold 的 theorem/lemma 外壳恢复：模型给出完整声明时，只取回声明中的 `by` 证明体，要求完整且编号一致的来源步骤与唯一孔位；原锁定命题仍由调用方传给 Lean 检查。声明头内的目标不会替换锁定命题。恢复后的完整证明必须在原命题上通过 Lean，才能进入 Kernel 证书流程。

修复由一个真实故障形态驱动：保存的 DeepSeek 响应是 5,824 字符的完整 `theorem problem : <locked proposition> := by` scaffold，7 个来源步骤使用 1-based 编号。原先工具只接受 `by` term，因而报告 `scaffold_not_a_by_expression`，没有推进到填孔。现 HEAD 已对这份真实保存输出做离线结构重放，恢复为 `by` term、完整转换 7 个索引，`scaffold_issue` 返回 `None`。这只是缓存模型输出的解析/结构重放；没有填孔、没有 Kernel 证书，绝不计作新证明成功。

更一般地允许声明头中的 proposition 有排版差异，是安全的，因为抽出的 body 仍以未经修改的 `locked_statement` 为最终目标。新增记录字段 `wrapperStatementMatchesLocked` 可区分字面相同与不同的声明目标。目标不相同时也不作数学等价判断；Lean 必须直接检查完整证明体是否能证明锁定命题。

## 修改文件

- `jijian-lean-backend-v2/backend/lean_first_modular.py`
- `jijian-lean-backend-v2/tests/test_lean_first_modular.py`

提交只含以上两个文件。未纳入工作区已有的未跟踪用户文件 `GENERALIZATION_ATTACK_20261031.md`。

## 可重复验证

在 `jijian-lean-backend-v2/` 运行：

```sh
PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=. .venv/bin/pytest -q \
  tests/test_lean_first_modular.py \
  tests/test_lean_first_whole.py \
  tests/test_lean_first_locked_repair.py \
  tests/test_lean_first_goal_repair.py \
  tests/test_lean_first_official_job.py
```

结果：**55 passed, 1 skipped**（14.51 秒）。跳过项是 `test_mismatched_theorem_wrapper_body_gets_fresh_locked_goal_kernel_check`：`LeanRunner.info()` 报告 `runtimeBuilt=false`、`runtimeAttestation=runtime_attestation_missing_or_invalid`、`ready=false`，原因是 `lean-runtime/.jijian-source-lock.json` 缺失。未伪造此运行时证明或官方 Runner 收据。

同一测试模块单独运行的先前结果：`13 passed, 1 skipped`（14.15 秒，包含真实 Lake/Lean 测试）。另一次对不存在路径 `tests/test_lean_first_repair.py` 的 pytest 调用未收集任何测试；实际存在并已运行的相关模块是 `tests/test_lean_first_locked_repair.py`。实现过程中的中间回归曾暴露 1-based marker 检测遗漏；条件已修复，最终上述回归全通过。第一次手工 Lean 集成命令给的是已填孔 term，因此没有触发 scaffold 恢复，Lean 如实报错；随后改为实际 scaffold 输入并通过。以上中间失败均未冒充产品验证结果。

## 真实 Lean 集成

新增的 `test_normalized_wrapper_body_elaborates_at_locked_goal_with_real_lean` 通过 Lake 调用安装的 Lean 4.34 / Mathlib，对从声明外壳中抽取的证明体生成完整 theorem，并保持锁定目标 `∀ n : ℕ, n = n` 不变。Lean 退出码为 0，`#print axioms` 输出：`normalized_body does not depend on any axioms`。这是实际 Lean elaboration/Kernel 检查的通用机制集成样本，不是奥林匹克题成功，不使用模型，也不算新的泛化数学题通过。

原始命令等价于：

```sh
/[LOCAL_USER]/.elan/toolchains/leanprover--lean4---v4.34.0/bin/lake env lean WrapperNormalization.lean
```

（测试从 `Settings.from_env().lean_project` 作为工作目录运行。）真实官方 Runner 认证仍因上述 source-lock 缺失不可用，因此不把这条 Lake 检查伪装成应用层 certificate。

## 独立未见题 / fresh unseen 计数

尝试启动一题新来源：官方 BMO 2025 Round 1 第 2 题（三元实数方程组），以完整题面和一份逐步代数解作为自然语言原稿。题目来自 [UKMT BMO past papers PDF](https://bmos.ukmt.org.uk/[LOCAL_USER] `/private/tmp/jj-fresh-bmo1-2025-r1-q2-20261031` 数据目录。

调用尚未发出：`Settings.from_env()` 检查到 normal DeepSeek provider 无 API key，于服务初始化前返回配置错误；也没有可复用的本机后端 API 服务。这次不曾向 DeepSeek 发送请求，不能算 fresh AI response 或 Lean 测试。

- Fresh unseen 奥林匹克端到端尝试：**0/1 完成**（1 次启动尝试在 DeepSeek 请求前因缺配置中止）。
- Fresh unseen AI 生成并交 Lean 的完整命题：**0**。
- Fresh unseen 完整命题 Kernel 通过：**0**。
- 可报告的“新题通过率”：**没有成功样本，0/1 尝试完成；不能声称有 fresh unseen proof 成功**。

DeepSeek 配置未被改写、禁用或降级；缺少凭证时没有离线模型代跑。BMO 2025 R1 Q2 的题源分类与年份只作为独立测试选择，不代表自动形式化结果。

## 真实失败与可修通类别

下列判断基于当前工作区和已保存的 Mac 实测记录；fixture、历史缓存回放与真实新模型请求分开计数。

1. **模型返回包装声明而不是要求的 term**：R2 Q2 scaffold 解析失败 `scaffold_not_a_by_expression`，这次通用恢复已覆盖该结构故障。真实输出路径：`/[LOCAL_USER]/Documents/ChatGPT/极简lean-review/gaolian-2024-r2q2-V368-parser-recovery-real-live/gaolian-2024-r2-q2-terminal-job.json`。当前重放只通过结构校验，填孔与 Kernel 未验证。
2. **来源步骤索引基数不同**：真实 wrapper 的 `source_step_1`…`source_step_7` 与相应 holes 使用 1-based 编号。只有来源 marker 和 holes 均连续且一致时才转换为内部 0-based；缺失、混杂或越界时保留失败，不猜编号。本轮单测覆盖连续、缺号、错误目标及嵌套来源步骤。
3. **数学内容远超语法修复**：2024 高联二试 Q2 的记录明确未完成从几何角平分/凸性推出坐标变换、平行条件推出共同参数、切圆条件变成圆方程、共圆 determinant 判据与最后圆心半径构造。七步中这些证明义务没有完成。不能因 scaffold 现在可填孔而宣布整题成功。
4. **局部 / 整体证明不完整**：四道高联独立题 2026-10-31 V3.6.2 实测完整 Kernel 为 0/4；2024 R2 Q1、Q2、Q4 的真实测试也均未得到完整 Kernel 证书。历史结果参见 `olympiad-20261031-four-unique-V362-real-live/` 与其逐题 `*-summary.json`。
5. **来源证明本身错误或来源规划错误**：已保存的 BMO2 2025 Q1 原稿末步声称 `2(1/n−1/(2n−1))=1/n`，该恒等式不成立；系统把它报告为原稿错误并未证明原命题。这不是 Lean tactic 可安全修复的问题，必须保留反证结果。证据位于 `/[LOCAL_USER]/Documents/ChatGPT/极简lean-review/2025-BMO2-V342-四题真实全线验证/bmo2-2025-q1-summary.json`。BMO2 2025 Q3 旧测试被记录为 `whole_invalid_source_plan`，也需继续单独审查，不能算目标通过。
6. **Mathlib API / Lean 记法漂移**：旧 `ZMod` 名称不存在、`inner ℝ` 标量参数与求和成员记法不匹配会造成模型证明编译失败。此前已有通用的 API `#check` 证据修复与记法标准化；9 次重复旧 `ZMod` API 的修复仅为真实 Lean 编译样本，不是 BMO 整题成功。参考 `20261031-V368-engineering-handoff.md` 中 `real-nine-duplicate-obsolete-zmod-api-kernel-result.json`。
7. **生成后的解析异常与结果留存**：历史付费模型 scaffold 曾让异常直接中止任务；现有提交 `ae1c473`、`5c61980` 已记录 regex/schema 失败并持久化原始模型响应。本轮没有复用或覆盖这些实现。
8. **缓存/重放边界**：同原文历史 Lean proof replay、已保存 DeepSeek 候选的重新编译、fixture、局部 lemma 都不计作 fresh unseen。V368 handoff 中的 4/4 是历史已认证证明的当前 Kernel 重放（AI=0），并非新模型泛化；此前 BMO1 Q5 再生成失败与缓存重放成功也必须分开。

## 既有基线、环境阻塞与未完成项

- V368 交接记录的全量旧回归基线为 **1100 passed、72 skipped、6 failed**。这 6 项是已知 legacy V2 接口/工作流测试失败，不能归咎于本提交或改期望掩盖。本轮没有跑全量 pytest，已跑的 55 个相关测试未新增失败。
- 当前官方 Lean Runner 因 source-lock 缺失 `ready=false`；因此真实完整题 `verify_whole_original` 无法签发本机应用层 Kernel 证书。没有重建/伪造 source-lock，也没有覆盖正式 App。
- 本机新 DeepSeek 调用未开始，因为标准环境没有 provider key；未更换模型或伪装缓存。
- 定向结构修复不解决模型数学推理不完整、错误来源证明、长链几何/数论形式化与 Mathlib theorem 搜索能力。目标“除 CMO 之外奥林匹克题尽量全部 Kernel 自动通过”本轮**没有达到**，报告不宣称成功。
- 本轮确切 Git commit：`3e678f7`。`git status` 只保留用户已有未跟踪 `GENERALIZATION_ATTACK_20261031.md`；它未被编辑或提交。
