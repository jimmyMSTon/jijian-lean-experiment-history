# 极简 Lean Mac App：源码锁定 Runtime 优先级与后端启动生命周期

## 触发条件

核查最新 7414cb1 Mac App 发现 BackendRuntime.start 继承 ProcessInfo.processInfo.environment 后，将打包 runtime.json 的键仅在环境变量缺失时添加：

for (key, value) in runtime where env[key] == nil { env[key] = value }

因此启动当前 App 的 Shell、IDE、测试环境如果保留旧 LEAN_PROJECT_DIR / LEAN_LAKE_BIN / MATHLIB_SOURCE_DIR / JJ_RUNTIME_SOURCE_FINGERPRINT，即使用户正在运行正确签名的最新版 App，子后端仍可能继承过时的源码锁定契约。后端 Runtime attestation 失败或调用不同版本模块时，客户端可能误报系统不可用，且不是真正的数学验证错误。

此外，BackendRuntime.start 在进程存活但 HTTP /health 永远不可用时，没有任何服务就绪超时；首次进入 GUI 的验证界面可能无限等待。

## 修复

- 新建纯 Foundation 的 NativeRuntimeEnvironment.make，明确四个源码锁定的 runtime key 都必须存在、路径使用绝对值且指纹为 64 个十六进制字符。
- Source-lock 四个键全部从签名 App 的 bundle runtime.json 覆盖继承环境。旧 Shell 的同名键绝对不能覆盖打包 Manifest；Provider 配置和 JJ_ENV_FILE 的现有行为保持不变。
- 仍强制 JJ_HOST=127.0.0.1、采用 App 运行时分配的私有端口以及此用户的 Application Support data 目录。
- 缺失或不合法的 runtime.json 时，不静默回退过时 env；直接报告 RUNTIME_MANIFEST_INVALID。原稿不受影响。
- App 自己启动的子后端等待 /health 的过程增加 45 秒就绪超时，并且对取消/超时仅终止本 App 创建的 child process。**这只约束启动挂死，不对 DeepSeek、Lean、Proof/Repair 加任何模型请求时长/轮数 Gate，也不会中断他人进程。**
- 保留已有数据目录/历史，不做清理、删除、迁移或自动重试。

## 测试

- tests/native_signed_runtime_environment.swift 与实际 NativeRuntimeEnvironment.swift 编译成可执行 Swift 测试；注入四个过时环境键，验证全部由 trusted runtime.json 覆盖，Provider 配置未被改动；验证坏 JSON、缺失键、错指纹、相对路径、非法端口被拒绝。
- 真实 Mac 打包版本 7414cb1 的 runtime.json 也作为测试输入，同样核对来源字段与环境合并结果一致，PASS。
- 全部 Native Swift 源码类型检查在提交前进行；结果以实际测试输出为准。
- 此补丁独立于 Codex 正在开发的 Complex/代数数学后端；不会修改 mathir types、Compiler、Provider 或 Kernel 验证。

## 证据边界

不声称本轮启动了日常 App，也不将本机签名资源路径验证视为用户手写题 MathIR 语义正确。最终完整 GUI/后端打包还需在 Codex 主线稳定后集成验收。
