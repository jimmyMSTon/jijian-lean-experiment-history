> 2026-10-07 更新：已移除全局离线模式和 live AI 开关限制。正式 App 与真实 AI 测试正常访问 DeepSeek；fixture 由具体测试显式选择。参见开发测试说明及 reports/statement-lock-three/DeepSeekFlash三题结构锁与Lean能力报告.md。

> 2026-10-06 本机整合接续：用户最新第一版仅用 DeepSeek，覆盖下文历史网关安排；真实 API / Kernel 联调已执行。当前配置与边界见 [第一版实际配置与实测入口](docs/第一版实际配置与实测入口.md)，最终执行证据见 [真实联调报告](reports/DeepSeek真实联调报告.md)。

# 极简 Lean 后端 V2 增量升级

本版本以已交付的 `jijian-lean-backend-v1.0.zip` 为基线修改。保留 MathIR 1.0、用户原证明步骤和依赖、Lean 执行与独立审计、存储、任务、取消及前端原有接口；不重做 Stitch UI。

## 本版链路

文字 / LaTeX / 图片 / 手写笔迹 / PDF → DeepSeek V4.1 Flash 识别与结构化 → MathIR → 当前安装 Mathlib 的源码检索和 Lean `#check` → Flash 翻译类型与证明片段 → Lean 核验 → 固定命题和依赖下的诊断修复 → Lean 复核 → 人类数学反馈。

生产实例统一由 `DeepSeekProvider` 提供 AI。图片用 `FlashVision` 直接转录，数字笔迹先渲染成图片，PDF 在本机逐页渲染。没有接入 Mathpix 或 PaddleOCR；旧供应商源码仅为原包回归与历史参考保留，不被生产 `Services` 实例化，没有供应商回退路由。

## 给 Codex 的入口

读取 `CODEX_READ_FIRST.md` 和 `docs/V2补丁说明.md`。用户只需要把原包、补丁包及 Stitch 导出/MCP 上下文交给 Codex，不需要本人开终端合并代码。

开发凭据在服务器 `.env` 填写：

```dotenv
DEEPSEEK_[REDACTED_SECRET]
DEEPSEEK_MODEL=deepseek-flash
DEEPSEEK_BASE_URL=https://api.deepseek.com
```

2026-10-06 核对的 DeepSeek 官方接口名是 `deepseek-flash`，当前对应 V4.1 Flash；旧名称 `deepseek-v4-flash` 属于兼容别名。运行记录同时保存请求模型、供应商返回模型、指纹和用量，不把模型别名当永久版本锁。`.env.example` 给出本机后端、受控云端网关和 Lean 路径配置。

本版没有替用户指定思考模式；`DEEPSEEK_THINKING` 留空即不传该参数，实际行为使用供应商默认值。显式设置 `enabled` 或 `disabled` 时原样发送并记录，不自动升到其他模型。

## 接口与客户端

原 `/api/structure`、`/api/formalize`、`/api/verify`、`/api/formalize/repair`、`/api/pipeline`、`/api/jobs`、识别与修订接口继续存在。新增 `GET /api/library/lookup?name=...`；`/api/library/search` 返回当前源码候选。

`/api/pipeline` 和 `/api/jobs` 接入已确认的修复循环。原单步 `/api/formalize/repair` 仍只生成一次修复版本，调用方可再调用 `/api/verify`。调用流程记录 `repairWorkflowId`、每次修复的原记录/新记录、诊断来源和命题指纹；前端无需新增页面或按钮。

JSON 模式只能约束 JSON 格式。代码使用本地 JSON Schema 与 Pydantic 再核对字段，不把供应商的 JSON 模式说成严格模式原生保证。

## 本机与云端

本机后端持有用户文件、Mathlib 检索和 Lean 运行环境；正式分发时通过你控制的网关请求 DeepSeek，发行方密钥不放进 Mac 安装包。PDF 和笔迹渲染也在本机完成，再按用户当前识别功能向 DeepSeek 发图。网关不负责执行 Lean 候选程序。

原版的 Lean v4.34.0 / Mathlib v4.34.0 工程文件没有被本补丁改版。环境准备脚本继续负责固定工具链与 Mathlib 缓存，补丁不会在每次验证时自动联网升级库。已有数据表不清空，新增 PDF 识别进度表可与旧 SQLite 数据共存。

## 实测与未验证

本轮证据见 `reports/V2补丁验证报告.md`。`reports/交付验证报告.md` 和原有测试 XML 是 V1 原始交付记录，不能冒充本轮结果。

自动化检查中有明确的 HTTP/Lean 输出测试替身；它们用于查请求协议、不可变命题、错误分流、循环和取消，不是识别质量或证明成功率。真实 DeepSeek 请求、Mathlib 环境与 Lean 内核联调，以及 macOS 构建/签名仍由实际环境检验，不得把本包当成已签名 `.app`。

## 可由 Codex 使用的检查工具

```bash
python -m pytest -q
python scripts/check_examples.py
python scripts/export_contracts.py
tsc -p client/tsconfig.json
```

`tests/test_live.py` 是真实环境检查入口，显式启用才发送付费请求。工具和本轮检查结果不构成用户新增的发布 Gate 或次数/费用限制。
