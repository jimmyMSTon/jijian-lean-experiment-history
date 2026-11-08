# 极简 Lean：三道高难证明真实软件双轮验证

注意：两轮的测试执行环境不同。第一轮是签名安装 App（90a6e5b）；第二轮为同一正式开发主线追加结构化提示词改进后的**真实源码 DeepSeek + Lean**，不可冒称新签名安装 App。
两轮提交的三份用户原稿完全相同，所有真实请求与证书各自留存；没有手写 MathIR 或 Lean。

## 结果对照

| 题目 | 首轮签名版 | 更新后源码结构化 | Lean 完整路线 | 原稿独立认证 | 第二轮 AI 请求 | 输入/输出 Token | 耗时 |
|---|---|---|---|---|---:|---|---:|
| hard_number_theory_4k3 | PARSE_ERROR | True | False | False | 10 | 228627/192753 | 1237.195 |
| hard_analysis_ivt_sup | PARSE_ERROR | False | None | None | 1 | 11673/34002 | 136.652 |
| hard_linear_algebra_spectral | PARSE_ERROR | False | None | None | 1 | 11966/41826 | 179.914 |

首轮签名版真实消耗：{"cases": 3, "realDeepSeekRequests": 3, "inputTokens": 34304, "outputTokens": 124511, "elapsedSeconds": 502.81, "completeLeanKernelSuccesses": 0, "independentOriginalProofSuccesses": 0}

第二轮更新后源码真实消耗：{"realRequestCount": 12, "inputTokens": 252266, "outputTokens": 268581, "sumWallSeconds": 1553.761}

仅有独立 Lean Kernel completeOriginalRouteKernelPassed=true 的情况可计入完整形式证明成功，且仅有 sourceProofVerified=true 才能计入作者原稿忠实性认证。

## hard_number_theory_4k3

实际源码报告：/[LOCAL_USER]/Documents/ChatGPT/极简lean 2/jijian-lean-backend-v2/reports/hard-three-structure-20261022-hard_number_theory_4k3.json
Source SHA-256：25ed79056365bd1c13a3391a1bafd9aec6befbf3085e00efdef302d680d1d24b
MathIR结构化：True，原稿保真：True
形式化：False，原稿认证：False
真实 AI requests： 10，阶段：{"mathir": 1, "formalization": 3, "other": 3, "repair": 3}
失败： null
Route Kernel证书： [{"routeId": "route_contradiction", "status": "incomplete", "completeOriginalRouteKernelPassed": false, "kernelChecked": null, "statementMatched": null, "additionalAxioms": null}]


## hard_analysis_ivt_sup

实际源码报告：/[LOCAL_USER]/Documents/ChatGPT/极简lean 2/jijian-lean-backend-v2/reports/hard-three-structure-20261022-hard_analysis_ivt_sup.json
Source SHA-256：73bcce94d4c07e1c10ee98aeacf212d5fd5db91c6a80c8557002e46af7d4b53f
MathIR结构化：False，原稿保真：None
形式化：None，原稿认证：None
真实 AI requests： 1，阶段：{"mathir": 1}
失败： {"code": "PARSE_ERROR", "message": "JSON 无法确定性恢复；未重新调用 AI", "details": {"position": 12221, "syntax": "Expecting ',' delimiter", "responseId": "4273dbe4-a9e4-431f-a491-4b345c9516b9", "unvalidatedAIOutputId": "27e2b9cd-1428-42f7-85a5-58b8a78663ac"}}
Route Kernel证书： []


## hard_linear_algebra_spectral

实际源码报告：/[LOCAL_USER]/Documents/ChatGPT/极简lean 2/jijian-lean-backend-v2/reports/hard-three-structure-20261022-hard_linear_algebra_spectral.json
Source SHA-256：f1f3240a93c04b59a15f6d685d57aa00a9b0e6c27388f08bc857e819021c839c
MathIR结构化：False，原稿保真：None
形式化：None，原稿认证：None
真实 AI requests： 1，阶段：{"mathir": 1}
失败： {"code": "PARSE_ERROR", "message": "JSON 无法确定性恢复；未重新调用 AI", "details": {"position": 23744, "syntax": "Expecting ',' delimiter", "responseId": "309310aa-e6fd-4d0d-a63c-e44da7f1c05b", "unvalidatedAIOutputId": "63f02cc4-dad2-4c99-bcab-bf0eb3269a23"}}
Route Kernel证书： []
