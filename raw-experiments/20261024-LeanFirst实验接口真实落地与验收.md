# 2026-10-24 16:05 Lean-first 实验接口工程落地

旧主体 `ea90f7c` 的 MathIR 仍存在盲测泛化问题。新路径基于真实对照实验，直接让 DeepSeek 将人类数学原证明译为 Lean 命题、同路线 proofTerm 与原文位置，发送真实 Lean Kernel 判断。区别于旧逻辑：不再必须通过自制30节点/13作用域 MathIR 的复杂编译器。

## 已实际完成

- 提交 `bc23806d10658c4601c533468c7527facdaa0c86`：新增 `backend/lean_first.py`，以及实验接口 `POST /api/v2/experimental/lean-first`，带来源区间校验、禁止占位、真实证书校验、单独来源认证状态。
- 新增4条服务端单测；连同现有相关测试总计22 passed。
- SwiftUI App bundle 已重新构建、源码提交戳一致、源码 dirty=false、codesign deep strict通过；**尚未替换正式安装App的默认验证按钮**。
- 使用**签名 App 捆绑后端**启动隔离真实服务，并经新实验 HTTP 接口提交真实数学原证明；DeepSeek→Lean4 Kernel 返回 formal_verified_source_mapping_unconfirmed，Kernel verified=true，源码映射有效，certificate checked=true、statementMatched=true、additionalAxioms=[]。
- 新接口的原稿独立认证依旧 false，不允许把形式化正确性声称为自然语言百分百等价。

## 现有独立对照试验（不同于本接口）

CRT 存在唯一性与另两道新证明，都在无 MathIR 的一次模型翻译后被真实 Lean Kernel核验通过；一份错误不等式未被模型宣称通过。来源细节见 `20261024-Lean直译对照实验与路线判断.md`。这些试验与新接口测试结合说明技术可行，不等于盲测样本足够。

## 边界和下一项真正未完工部分

1. 原生 SwiftUI 正式验证按钮尚未改用新实验接口，必须设计切换、超时、错误状态/历史保存的具体逻辑，再进行原生 UI 验收。
2. 新接口还没有多题盲测泛化的统计验证；错误定位仍缺少正式 Kernel 反例搜索和逐步人类反馈。
3. 当前结果只为 Lean 对**模型翻译后的命题与形式证明**发证，不保证原自然语言文本语义完全等价。
4. 正式旧版不覆盖；提交的代码和对照报告保全，可继续开发或撤回。

## 本地文件

- `~/Documents/ChatGPT/极简lean 2/jijian-lean-backend-v2/backend/lean_first.py`
- `~/Documents/ChatGPT/极简lean-review/packaged-lean-first-bc23806-smoke/response.json`
- `~/Documents/ChatGPT/极简lean-review/20261024-Lean直译对照实验与路线判断.md`
