接手此工程继续“一次性完成指定任务”，不是只出计划。现在是用户明确指定的唯一正式开发工作树 /[LOCAL_USER]/Documents/ChatGPT/极简lean 2，分支 codex/official-proof-core，当前基线 066dd52，工作树中 14 个已修改和 8 个未跟踪文件已经包含上一轮未完成的通用修复，必须保留、逐项核实，不得丢弃。main 是稳定发布，V2 已冻结，不要另开并行分支。

必须先检查历史同步文档 /[LOCAL_USER]/Documents/ChatGPT/极简lean-review/CHATGPT_CODEX_工程同步.md 末尾和最近相关证据，尤其:
- /[LOCAL_USER]/Documents/ChatGPT/极简lean-review/hard-three-ivt-structure-setof-live-v3-20261022.log
- /[LOCAL_USER]/Documents/ChatGPT/极简lean-review/hard-three-spectral-full-compiler-feedback-real-20261022.log
- /[LOCAL_USER]/Documents/ChatGPT/极简lean-review/run_three_hard_signed_app_20261021.py 的 CASES 三题原始数学证明
- 当前 backend/reports 内对应 json；已知 2026-10-22 IVT 报告显示 fixedStatementKernelPassed 和 originalRouteKernelPassed 均 True，但形式化却将 f:[0,1]→ℝ 变成全 ℝ 连续，原稿认证 False，这个不能冒称通过；谱定理仍 PARSE_ERROR；数论有5个缺 proofTerm。
- 当前 Python 非实时回归已经 857 passed / 69 deselected（不能冒称三个问题完成）。

任务：完整、直接落地对“高难证明通用结构化→MathIR→Lean/Mathlib→诊断修复→独立原稿忠实性”链路的剩余实际问题的源码修复与审查，复测同三道高难原文（两道高等、一数论），遇问题直接修，不留下明知的同类缺陷。尤其：原始 f:[0,1]→ℝ 的限制域函数必须忠实保留，不能为了 Kernel 通过偷偷弱化/强化原题；谓词/集合/有界量词；正交矩阵、有限维 Matrix/Fin/归纳与复杂 MathIR 严格 JSON 解析；不得为通过测试硬编码3道题、手写预制 MathIR/Lean 替换 DeepSeek、跳过 Lean Kernel、伪造 proofTerm/数学证明、将原稿结论正确替代原稿推理正确。失败应保留证据、清晰标识不能认证，不把未证当假。维护真实请求审计，统计调用、tokens、Kernel 与原稿独立通过情况。

用户规则：DeepSeek Flash 是主体翻译，文本/图片原文→真实 DeepSeek→MathIR→Lean4+Mathlib→Kernel，任何正式 AI 测试不得通过离线 Gate 绕过，保留缓存和审计；无新数量阈值、费用门槛、Gate、题型白名单、新拒绝条件、流程约束或凭空假设；没有用户确认不能自行增加硬规则。保留已确认 V2 封档、重构正式开发版，Mac SwiftUI 原稿显示与局部红绿诊断。安装版是 ~/Applications/极简 Lean.app。

必须自己分析现有 git diff 和新增测试；修好问题后运行完整必要 Python/Native、真 DeepSeek 业务测试及 Lean Kernel，不可仅用 fixture 自称产品验证；真实测试新鲜/缓存必须如实区分；收集 per-case 原文SHA、provider真实 ID/次数/输入输出tokens、Lean证书、独立忠实性、修复记录、测试输出。校验工程改动没有引入无根据的硬性规则。最终如能满足则 commit 到唯一正式开发分支、安全 ff-only 合并 main、全量重建/签名/安装唯一正式 Mac App、核对 SHA，并保存具体交接报告。若某深层数学能力暂时无法正确形式化，绝对禁止为通过而换命题，说明明确失败边界，完成能安全完成的全部通用修复并保留真实失败产物；不虚报通过，不要把已执行变成以后再做的承诺。

执行时务必持续工作而非报告计划，出现异常先修再测，同一任务尽力一气完成。不要更改无关项目、密钥配置或部署。当前另外有 Codex 处理“先机”项目，互不打扰。