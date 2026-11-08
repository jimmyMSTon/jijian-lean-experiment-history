# 开发测试与 AI 调用控制（2026-10-07 更新）

用户已取消全局离线模式。本说明替代此前默认阻断网络、live opt-in 与完整 E2E 双开关安排。正式 App/Provider 和真实 AI 测试不读取 LIVE_AI_TESTS、OFFLINE_AI、DISABLE_LIVE_AI 或 FULL_E2E_LIVE 来决定是否允许 DeepSeek 请求。没有 pytest runtime 自动 Provider 替换或 autouse 网络封锁。

正式 Provider 为 deepseek-flash，凭据由服务端环境配置。应用读取本机 server.env，密钥不进入源码/App 分发文件。AI 测试正常使用同一 Provider，需要正常凭据配置；缺少凭据明确跳过或返回配置错误，不生成 fixture 成功结果。

测试按实际目的选择：纯 schema、数据转换、诊断解析、Statement Lock 与 UI 渲染显式使用 fixture/stub；历史响应回放显式使用 RecordedProvider，标注 record_replay。真实 AI 能力和完整生产链测试正常访问 Provider，无需 live 开关。只做本地回归可选择排除 tests/test_live.py 与 tests/test_macos_live.py，或运行 scripts/check_offline.py；这是具体测试选择，不是全局网络 Gate。单独本地 Lean 检查不用 AI Provider。

官方客户端已迁移为 SwiftUI。`scripts/check_ui_fixtures.cjs` 与 `scripts/check_stitch_live.cjs` 是历史 Web/Stitch 页面测试，DOM 选择器已与当前 SwiftUI 客户端分离，不属于普通回归或 UI 验收。SwiftUI 状态夹具通过 `scripts/build_native_preview.py` 的 `UI_FIXTURE` 目标检查；预览不启动 Provider。

UI fixture 在临时静态服务器渲染 recognition_success、recognition_ambiguous、verification_success、verification_failed、formalization_failed、repair_success 等状态。测试明确拦截 API，未修改正式 UI 的 Provider，也未增加普通用户开发面板。渲染通过不能算实际 AI/图片识别或 Kernel 成功。

开发入口可安装 devtools.ai_testing。缓存 key 包含模型、thinking、schema/阶段、prompt 内容与版本、完整数学输入/repair 输入、图片字节 hash、MathIR 版本。成功录制结果以 0600 保存于 .dev-ai/cache；命中复用实际响应，未命中正常调用 Provider。不存在 cache miss 阻断网络。跨实例/进程文件锁实现 single-flight；并发失败共享结果。LIVE_AI_FRESH 仅是开发绕过缓存选项，不是允许网络的开关，也不影响 App。

内容无关请求日志有 workflow_id、request_id、stage、reason、model、input_hash、image_hashes、prompt_version、retry_index、token usage、cache hit/miss。正式 HTTP 审计在服务 data_dir/ai-audit.jsonl，started/finished 两行按同一 request_id 只计一次，不能和开发日志再重复相加。供应商收到响应但 JSON/schema 失败仍记真实请求与 token；取消或无返回的用量记未知，不写成 0。不记录密钥或敏感请求正文。

正式自动修复保留完全相同 statement/proof/Lean diagnostics/检索内容的去重，没有新增次数上限或 HTTP/SDK 自动 retry。开发相同请求使用缓存；不以“重复”作为新网络 Gate。固定声明或绑定真正漂移时返回 STATEMENT_DRIFT/BINDER_DRIFT，不能用 proof-only repair 改题，也不能由成功证书覆盖；这是用户已确认的数学一致性约束。

当前代码从 typed MathIR 生成 canonical specification、binder map 与 statement_hash，Flash 只生成 proof。repair 单个响应仅 proof；固定声明的保存/加载、alpha-renaming、辅助表达式导出及 fresh Kernel 环境都有对应检查。保留原输入、来源映射、失败记录和未解决歧义；Kernel 只能验证形式化命题，不能证明识别/自然语言解释完全忠实。

最新实测和未通过项见 reports/statement-lock-three/DeepSeekFlash三题结构锁与Lean能力报告.md。本地 fixture/stub 回归 296 passed；实际三题与 Kernel 结果独立记录。开发统计端点只在显式开发服务器存在，不暴露在正式 App；运行时启动/健康查询不自动调用 AI。
