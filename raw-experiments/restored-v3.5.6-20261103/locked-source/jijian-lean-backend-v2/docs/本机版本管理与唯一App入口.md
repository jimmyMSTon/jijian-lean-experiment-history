# 极简 Lean｜本机 Git / App 版本交付规范

适用于 Codex 在当前两棵 Git 工作树里的后续开发；这不是数学能力 Gate、额外测试次数要求或公开发布条件。

## 唯一面向用户的 App 入口

**用户日常打开**：`~/Applications/极简 Lean.app`。

- `极简lean 2/dist/极简 Lean.app`：稳定 `main` 的构建产物，仅供安装源。
- `极简lean-next/dist/极简 Lean.app`：开发 `codex/next` 的测试产物，不能作为用户的正式日常入口。
- `build/NativePreview.app`、`build/native-smoke/`：fixture/检查构建，不作为正式 App。
- 所有测试结果须明确说明使用的是哪一个构建；不得将旧进程的表现视作新包已启动。
- 旧 App 进程不会因为目录中的 .app 更新而自动升级。安装后提示用户先保存证明并 `⌘Q` 退出所有旧极简 Lean 实例，再从 `~/Applications` 打开；不要擅自杀掉用户当前应用。

## 源码分支与交付顺序

1. **开发**：只在独立 `codex/next` 等工作树修改源码，`main` 保持最后一次已交付版本。保留用户已有的其他未提交文件。
2. **任务完成**：在开发分支提交本任务改动，分开记录 UI、MathIR/后端、测试与文档；不能把未提交更改当成已交付，避免 `git add -A` 混入其他人的工作。
3. **同步稳定版**：经本轮任务确认交付后，将开发分支合入 `main`。能 fast-forward 则优先 fast-forward；若存在真实冲突，必须逐段保留两方改动，禁止强制重置/丢弃提交或 `push --force`。若不能解决，报告原因，**不要继续安装不一致版本**。
4. **构建稳定版**：从同步后的 **`main` 源码**重新打包正式 SwiftUI App。后端源码变化时不能仅使用 `--reuse-backend` 继续复用旧后端。打包依赖按项目声明使用固定版本，不静默降级。
5. **本机安装**：从稳定 `main` 工程运行 `scripts/publish_local_mac.py --install`。正式构建的 Info.plist 保存实际 `JijianSourceCommit` / `JijianSourceDirty`，安装前自动对照当前 `main`，不接受旧构建或未提交源码产生的包。脚本复制/原子安装到 `~/Applications/极简 Lean.app`，旧版本保存在本地备份目录，避免直接覆盖正在运行的文件。
6. **交付说明**：报告 `main`/`codex/next` Git commit、构建与验证证据、`~/Applications` 的安装结果、是否需要重新打开，以及尚未完成的检查。**不要只提交工程报告，却给用户一条过期的 .app 路径**。

安全事项：保持 `.env` / `server.env`、DeepSeek Key、工作数据、模型缓存、Mathlib 生成产物不进入 Git；本地提交不等于推送公网。签名通过不等于 Developer ID 公证。

本流程只解决版本追踪、可重复构建与用户入口一致的问题。没有新增 AI 开关、重试/次数限制、发布 Gate 或未确认的数学业务行为。
