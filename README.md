# 极简 Lean · 历史实验与形式化验证研究档案

**Jijian Lean — Experimental History & Evidence Archive**

这是极简 Lean 研发过程的公开历史档案，记录 AI 数学形式化、Lean Kernel 验证、证明修复、语义忠实性、奥赛题泛化测试和工程回归。**成功、失败与未完成记录均予保留。**

## 数据范围

- 已索引 **66** 条结构化案例记录，来源于 **46** 份本地 `summary.json`。
- Kernel 字段为 true：**15**；false：**46**；缺失：**5**。
- 公开 **18** 份经初步敏感内容筛查的 Markdown 历史报告。
- 另有 **4680** 项本地轻量级证据文件的名称与大小索引，原始文件不随之公开。

**警告：这些不是独立题目样本，不得将 true/total 当作产品通过率。**

## 目录

| 路径 | 内容 |
|---|---|
| [data/structured-results.csv](data/structured-results.csv) | 可分析的案例级数据 |
| [data/structured-results.json](data/structured-results.json) | 原始字段类型保留的结构化数据 |
| [data/report-manifest.json](data/report-manifest.json) | 报告来源相对路径和原文件 SHA-256 |
| [data/local-evidence-inventory.csv](data/local-evidence-inventory.csv) | 本地证据目录清单（不含文件正文） |
| [reports/](reports/) | 历史工程报告和实验报告 |
| [methodology/INTERPRETATION.md](methodology/INTERPRETATION.md) | 统计与验证结果的解释边界 |
| [DATA_DICTIONARY.md](DATA_DICTIONARY.md) | 初版数据字典 |

## 历史阶段

1. **早期数学证明验证**：自然语言证明、Lean 生成、编译和修复链路。
2. **MathIR 与证明义务**：结构化表达、源证明步骤追踪、数学语义忠实性问题。
3. **Mac 原生应用与端到端链路**：真实 AI 请求、Lean Kernel、软件回归。
4. **竞赛数学泛化**：数论、代数、数列、几何、BMO、CMO、高联二试。
5. **长证明与复杂题攻坚**：多轮修复、模块化证明、局部引理与整题验证的区别。

## 重要的研究结论

Lean Kernel 能够验证特定形式化命题的证明，但不能单独证明自然语言原题与形式化命题语义一致。早期成功样本与后续复杂题目失败记录应并列展示，不能用局部 Kernel 成功代替整题通过。

## 隐私与可复核性

历史实验日志包含大量中间产物、模型请求、环境路径和可能的敏感信息。本仓库只公开经过初步筛查的报告与结构化摘要；原始文件通过 SHA-256 和相对路径建立追溯关系。未公开的原始日志不应被描述为已提供完整公开复现。

## License

暂不授予统一代码许可证。第三方数学题、代码和依赖许可须分别确认。公开可读不等于允许无限制再分发。
