<!-- Source: local experiment archive; paths and email addresses sanitized -->

# 极简 Lean：旧版 V3.5.6 与新版 3e678f7 原稿同题实测对比

输入完全相同，SHA256 逐题核验；分别使用真实 DeepSeek、独立数据目录、真实 Lean Kernel。

新版结果是实际运行时的 3e678f7；当前源码 094583e 还没有这五道题的独立端到端实测，不应混淆。

| 题目 | 旧版 Kernel | 新版 Kernel | 旧版真实 AI 请求 | 新版真实 AI 请求 |
|---|---|---|---:|---:|
| gaolian-2024-r2-q1 | 未通过 | 未通过 | 3 | 12 |
| gaolian-2024-r2-q2 | 未通过 | 未通过 | 5 | 9 |
| gaolian-2024-r2-q4 | 未通过 | 未通过 | 5 | 6 |
| bmo1-2024-q5 | 通过 | 通过 | 6 | 4 |
| bmo2-2025-q4 | 未通过 | 未通过 | 5 | 13 |

旧版提交 c37bfb5873e41a686271785d7ee2c717afaa08b2，V3.5.6 签名备份；
新版固定 3e678f7478d6bf0b12e38642e6661c46f3848de2；
两版均不可仅依据 Kernel 证明自然语言数学语义百分之百一致；模型随机输出造成的单次差异不能直接归因为代码退化。
原始逐题证据和 AI 审计：v356-headtohead-20261031/<case-id>/ 与此前新版真实测试目录。
