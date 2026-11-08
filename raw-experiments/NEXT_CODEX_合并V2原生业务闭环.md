# 极简 Lean V2 原生业务闭环｜实际工程交付及下一轮 Codex 合并

本报告仅汇总已经实际完成的工程与实测结果；不是新产品规范、额度门槛或停止条件。

## 已实现并 Git 提交

- 开发分支：codex/v2-native-user-loop
- 独立工作树：/[LOCAL_USER]/Documents/ChatGPT/极简lean-native-v2
- Git commit：326c7df95142c49573346f2fd56e8eb552fcf4d0
- 来源：V2 审计工作树的历史 3161f37。Codex 后续在原工作树做出的改动需要另行合并。
- 变更：原生 SwiftUI 六个文件，以及 V2 HTTP 合同测试文件。
- 具体实现：NativeStore POST /api/v2/jobs；读取 V2 run 和 MathIR artifact，不伪造 V1 verification/formalization ID；步骤级 SourceRefs、route 和 Kernel 诊断映射；历史同时保留 V1/V2，并按实际 ISO8601 时间排序；V2 原文歧义不送入旧 V1 专用歧义页面；修改后重新提交沿用实际编辑路径。
- UI 明确声明 Kernel 只能证明锁定的形式化命题与依赖路线，不能证明原稿文本语义完全对应。多路线 any-route 当前内核契约未变；若一条路线通过，其他未通过步骤仍显示为未证明。
- 没有引入 Codex、lean4-skills、OpenGauss 或其他 Agent 作为用户产品运行依赖。DeepSeek + Lean/Kernel 仍是 App 运行路径。

## 实际验证和构建

- SwiftUI 所有 Native Swift 文件完整类型检查通过；完整机器码编译通过。
- V2 轻量测试：90 passed，11 deselected。
- 实际 V2 HTTP API → 真正 Lean 4.34.0 → 独立 data-only Kernel 回放：1 passed，40.17 秒。该测试的 LLM 是 fixture，不能称为真实 DeepSeek 成功。
- 全项目轻量回归：419 passed，1 failed，20 deselected。失败是继承来的 tests/test_ai_test_architecture.py 对 Codex 新增 run_mathir_v2_novel_audit.py 的 install_dev_ai( 硬编码检查冲突。不要把 419/1 冒充全绿，也不要未经分析擅自改变现有实际 DeepSeek 路径。
- 独立签名 App 包：/[LOCAL_USER]/Documents/ChatGPT/极简lean-native-v2/dist/极简 Lean.app
- App 签名 codesign --verify --deep --strict 通过，Info.plist 记录源码 commit 326c7df，117 MB。
- 实际启动上述包内 PyInstaller 后端；/api/v2/jobs、/api/v2/pipeline、/api/jobs 均存在；Lean Runtime ready。测试进程正常回收。证据：/[LOCAL_USER]/Documents/ChatGPT/极简lean-review/v2-native-app-packaged-smoke.json。
- 没有覆盖已存档 ~/Applications/极简 Lean.app、main 或任何正式用户数据。

## 一次真实 DeepSeek + 签名 App 后端的当前证据

- 用户式原文：原题：证明 1 = 1。证明过程：根据等式的自反性，可以得到 1 = 1。
- 独立本机 job：46c36ef8-e135-459c-842c-c3fd64a23ded
- 真实 DeepSeek / DeepSeek Flash 已返回 StructureOnlyMathIRV2（约 21.3 秒）、初轮 Mathlib LibraryPlan（约 3.7 秒）、Proof Generation FormalProofs（约 1.6 秒）、诊断修复的 LibraryPlan（约 2.0 秒）；合计四个真实已收到响应的 Provider 请求。结构生成了与原文目标相符的 Nat 等式 1 = 1，原文 raw 被保留。
- 首次 Lean verification 不具完整证书（当时还没有 ProofTerm）；Proof Generation 后第二次 Lean verification 仍报告 fixedStatementKernelPassed=false / originalRouteKernelPassed=false。
- 后续进入诊断修复的 Mathlib retrieval，但测试脚本从 /api/jobs 读取时在 HTTP 10 秒超时。任务数据库最终是 status=running / stage=lean_verification；未取得完成的 Run、proof patch、最终 Kernel 证书。测试进程在超时后回收。此结果是“真实业务未完成”，绝不标记为数学命题错误或成功。
- 证据目录：/[LOCAL_USER]/Documents/ChatGPT/极简lean-review/v2-native-live-smoke-20261012/
- 包括 result.json、data/backend.sqlite3、data/ai-audit.jsonl 和 backend.log。请保持文件不删除；只对这个保留结果进行离线分析，勿自动向 DeepSeek 再次提交同一题。

## 下一轮执行事项

1. 先读取本报告、已有证据、当前 V2 审计结果与源码。把 326c7df 通过非破坏性 cherry-pick 纳入实际持续开发 V2 主线，处理与审计代码的差异；不要 reset --hard、git clean、force push，也不要覆盖用户的代码和数据。
2. 对上述简单 1=1 真实业务进行一次严格故障归因：查看已存结构、审核 Proof Generation 阶段输出和 Lean/依赖证据（有持久证据才引用），解释第一次生成后的 Kernel 为什么仍 false；解释进入二轮 LibraryPlan 后缺乏业务结果和状态读取超时的原因。区分模型 proof 质量、MathIR/Compiler、Lean 执行、后台任务进度响应和测试 HTTP 客户端超时。不能凭一次失败武断怪罪模型。
3. 将系统效率与 App 能实际完成任务作为首要工程交付事实，不得只修固定题并反复重跑相同输入，不得把初始端点接线和 UI 编译当作完全可用。
4. 复核并解决唯一遗留测试契约冲突，不允许为造全绿禁用真实 DeepSeek 或新建 LIVE_AI_TESTS Gate。
5. 独立保留源文语义未核证的显式状态，不改变原证明、声明依赖、Statement Lock、ProofLock、Kernel 可信边界与已经确认的 DeepSeek 模型策略。
6. **禁止合入此前已经撤销的 221883a Codex + lean4-skills 产品桥接**。它只属于历史试验，不是这次交付。

本次已交付真实 SwiftUI 接线、独立签名 App、V2 HTTP 和 Kernel 集成通过；真实模型自动完整闭环尚未通过，具体阻塞证据已经保留。

## 2026-10-12 更新：上一轮失败根因已修复，真实 DeepSeek 端到端通过

这部分替代前文关于“1=1 未通过，需要再调查 DeepSeek / Compiler”的推测。

1. 根因确证：Mac 构建脚本旧逻辑在本机存在 ~/Library/Application Support/JijianLean/lean-runtime 时直接复用。该 Runtime 于 10 月 7 日构建，Jijian.Export 的 jj_export 宏只接受三段字符串，而最新 V2 Runner 使用四段字符串（额外 candidateName）。运行时报 Unknown identifier JJBatchCandidate_0。之前失败主要是我们自己的二进制版本和协议不一致。
2. 对照测试：从首次失败任务 SQLite 提取原封不动的 DeepSeek MathIR，用人工 by rfl 做两次真正的独立 Lean Kernel 测试。旧 Runtime 原路线和定理都失败；匹配当前源码的 Runtime 两者均通过，零额外公理。对照记录：/[LOCAL_USER]/Documents/ChatGPT/极简lean-review/v2-native-live-smoke-20261012/isolated-rfl-result.json 和 matched-runtime-rfl-result.json。
3. 工程修复已提交：4e8e36a5c37f956b4f70e8f714fd433d8ea96f6e（含前序 UI/V2 接入提交 326c7df）。scripts/prepare_lean_runtime.py 按当前 Lean 4 源码指纹生成独立版本化本地 Runtime，重用已安装 Mathlib 并重新 lake build Jijian。scripts/build_mac.py 不再因为旧 Runtime 存在而跳过重新构建。2 项构建回归通过，本机 6 job Lake 编译成功。新独立 Mac App 完整编译/签名已验证。
4. 真实 DeepSeek 业务验证：同一道原稿“证明 1=1，理由是等式的自反性”，在修复并重新打包的独立 App 内真正调用 DeepSeek Flash、Mathlib、Lean 4.34.0 和独立 Kernel。job 19091b23-c0a0-4d5d-afeb-9cb67414c7e2，终态 completed/verified/original_route_kernel_passed，fixedStatementKernelPassed=true、originalRouteKernelPassed=true，checked=true、statementMatched=true、axioms=[]、additionalAxioms=[]。模型实际生成的 Lean proofTerm 是 Eq.refl (1 : ℕ)。没有 fixture，没有 Pro，没有人工替代模型 proof。
5. 总耗时 161.9 秒，3 次真实模型响应。结构化 MathIR 约 35.6 秒；Mathlib 规划、扫描和声明查询约 78.7 秒（其中 LibraryPlan HTTP 16.0 秒）；模型 proof 生成约 2.0 秒；Lean/Kernel 约 43.4 秒。故正确性障碍已解决，但高频用户体验仍不合格；主要性能瓶颈是我们的提前 Mathlib 检索工作流，不是本例 Flash 写不出 Lean 证明。
6. 真实证据目录：/[LOCAL_USER]/Documents/ChatGPT/极简lean-review/v2-native-runtime-fixed-20261012/，包含 result.json、真实 sqlite、ai-audit.jsonl、模型 proofTerm 的内容寻址 gzip 证据、backend.log。MathIR 的通用表达覆盖尚未证明，Kernel 不证明文字原文与形式化语义相同，系统仍标记 semanticAlignmentKernelProven=false。
7. 下一轮 Codex 需要合入 4e8e36a 及其前序 326c7df，而非只合入原 UI 提交；不得合入已撤销的 221883a Codex+lean4-skills 方案。优先减少不必要的 Mathlib 检索、重复 Lean 启动及耗时，但改变通用数学流程前做陌生正确/错误原证明对照；不能放宽 Statement Lock、原路线/依赖审计、Kernel 或自动改模型。
