# 极简 Lean — Git 工作树与开发入口

当前源码仓库根目录：`/[LOCAL_USER]/Documents/ChatGPT/极简lean 2`。稳定源码：`main`；后续开发目录：`/[LOCAL_USER]/Documents/ChatGPT/极简lean-next`，分支 `codex/next`。

- 用户正式 App 的唯一打开位置：**`~/Applications/极简 Lean.app`**。
- `极简lean 2/dist` 是稳定 `main` 的打包产物；`极简lean-next/dist` 只是开发测试包。两者都不是用户应该每天打开的路径。
- Codex 每轮改完现有功能并确认可交付：分别提交改动、同步 `main`、从 `main` 构建、调用 `jijian-lean-backend-v2/scripts/publish_local_mac.py --install` 更新用户入口。具体操作见 `jijian-lean-backend-v2/docs/本机版本管理与唯一App入口.md`。
- 遇到 Git 冲突、构建错误、签名错误或运行中旧 App 时不得覆盖或伪造结果；不要清理用户未提交的其他工作和已有数据。
- Git 只跟踪源码、SwiftUI、MathIR/Lean 契约、测试与必要无敏感数据的记录。密钥、运行数据库、模型审计、Lean/Mathlib 大型依赖、构建产物和备份不进入 Git。
- 本地 Git 提交不等于已推送至 GitHub；没有远端时不擅自建立/公开仓库。
- 品质与功能仍以 `PRODUCT_CRAFT_STANDARD.md` 和 `AGENTS.md` 为准；不得擅自增加产品规则、Gate 或数学范围限制。
