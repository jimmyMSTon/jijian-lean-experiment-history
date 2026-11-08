# 已撤销：禁止执行下文合并任务

用户最新明确决定：极简 Lean 必须以产品内部 LLM（当前 DeepSeek）+ Lean/Mathlib/Kernel 为核心，不接受任何以 Codex/开发代理充当产品证明引擎或运行依赖的设计。之前生成的 `221883a` 是研发工具桥接，不能证明 App 通过 lean4-skills 自动生成 proof。**此前要求下轮 Codex 合并该提交的安排已经撤回，不得照下面的旧交接任务执行。** 该提交保留在独立研究分支，仅供历史复核；不修改当前 V2 主线或用户软件。若要复用上游某个独立可调用的底层工具，必须单独评价其实际价值，不按此交接自行并入。

---

以下为已经失效的旧任务，**仅为历史记录**：

# 下一轮 Codex｜极简 Lean 架构提交合并

用户已要求：上一轮 ChatGPT 独立构建的 lean4-skills 研发桥接，下一次 Codex 工程任务纳入持续开发主线；**不要等所谓正式 App 才合并研发能力**。

## 来源

- 完整工作树：/[LOCAL_USER]/Documents/ChatGPT/极简lean-architecture
- 目标提交：221883a22cce524dfb7cf8205b2004da58efbdf3
- 来源分支：codex/lean4-skills-research-bridge（从 V2 作用域修复 5a54fd7 建立）
- 设计和真实证据：jijian-lean-backend-v2/docs/lean4-skills-研发架构桥接-20261011.md
- 已有实测：本提交相关 9 项轻量测试通过；整个 tests/v2 非 Lean-local 部分 97 passed、10 deselected；一条不经 Provider 的真实 Lean/独立 Kernel smoke 成功，证据：/[LOCAL_USER]/Documents/ChatGPT/极简lean-review/lean4-bridge-smoke/result.json。

## 下一次 Codex 的执行要求

1. 先读取上面设计文件，以及当前活跃 V2 分支的 AGENTS.md、CODEX_READ_FIRST.md、最新审计结论；检查当前分支是否已有同等工具，避免重复合并。
2. 将提交 221883a 通过 git cherry-pick（或等价的非破坏性 Git 合并）纳入当前实际持续开发的 V2 工作主线。该提交只增加研发侧工具/测试/文档及一行本地 skill ignore，不改变生产 MathIR/Kernel/DeepSeek/SwiftUI 源码。
3. 有 Git 冲突就逐段保留两边内容；不要 reset --hard、git clean、覆盖其他任务的未提交文件、强推 GitHub。仓库当前 stable main=8c7e525 是旧存档版本，不能仅为制造“已并主线”而覆盖已有较新 V2 开发工作；与实际 V2 主线对齐后再按用户现有 Git 流程更新 main。
4. 在集成后的工作树重跑相关轻量回归，确认本地 .agents/skills/lean4 可通过 scripts/setup_lean4_skills_dev.py 建立；不自动修改 ~/.codex 全局配置，也不启用外部 agent 作为正式证明判定。
5. 继续保留 Statement Lock、ProofLock、来源步骤依赖和独立 Kernel，拒绝把外部模型生成的 proof 或带 sorry 的 scratch 当成 Kernel 通过。
6. 报告最终合并 commit、路径、测试和未完成项；明确这次合并是工具链接入，不等于通用自动形式化能力已完成。任何新产品逻辑/成本限制/门槛，仍需用户明确批准。

## 上游

- https://github.com/cameronfreer/lean4-skills
- pin：b6243b85b9b0a0ddff5bb6773889044daf687f8e
- 当前本地独立源码：/[LOCAL_USER]/Documents/ChatGPT/极简lean-external/lean4-skills
- OpenGauss 不接入（其多代理层与现有工作流重复）。

本交接文件只供下一轮执行，不是新增数学规则或验收 Gate。
