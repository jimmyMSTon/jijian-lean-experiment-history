# Stitch UI 接口绑定

本包没有 Stitch 导出文件，不另造 UI。将已经设计好的控件绑定到以下连接层即可。

| 现有界面动作 | 连接实现 | 返回/显示 |
|---|---|---|
| 文字、LaTeX 输入 | `MathInput.kind=text/latex` | 原文不自动改写 |
| 拖入、粘贴或选择图片 | `uploadMathFile` / `backend.upload` | `assetId` |
| 拍照 | 客户端取得摄像头画面 → `uploadVideoFrame` | `kind=photo` 的统一图片输入 |
| 手写 Canvas | `handwritingInput` | 原始笔顺、x/y、时间、压力 |
| PDF 上传 | 上传得到 assetId → `kind=pdf` | 支持异步识别状态 |
| 混合输入 | `kind=mixed, parts=[...]` | 保持输入顺序和各块来源 |
| 验证按钮 | `backend.start(input)` | job.id |
| 验证进度 | `backend.events(job.id, callback)` | 识别、结构化、翻译、逐步核验、完成 |
| 取消 | `backend.cancel(job.id)` | cancelled 或此前已完成状态 |
| 识别结果更正 | `backend.correction` | 新识别修订 ID，不覆盖原图 |
| 数学解释 / 结果 | `job.result.feedback` | 中文状态、原步骤、影响依赖 |
| 主动查看形式化细节 | `backend.artifact(formalizationId)` | 内部 Lean 和映射；不默认显示 |
| 明确请求修复翻译 | `backend.repair(...)` | 新形式化修订，原类型哈希不变 |

## 最小接线示例

```typescript
import { LeanBackend } from './client/backend-client';

const api = new LeanBackend(backendAddress, serviceConnectionToken);
const job = await api.start({ kind: 'text', text: editorValue });
await api.events(job.id, event => {
  updateExistingProgressUI(event.event, event.data);
});
const finished = await api.job(job.id);
if (finished.result) {
  showExistingResultPanel(finished.result.feedback);
} else {
  showExistingErrorPanel(finished.error);
}
```

这里的 UI 函数由现有 Stitch 页面组件实现。示例没有新页面、登录 Gate 或强制审核步骤。API 地址、令牌和 CORS 来源依据实际开发环境配置，不是用户账号逻辑。

数学内容建议通过已有数学排版组件渲染；源文本和 AI 文本不通过 `innerHTML` 执行。代码点范围转 DOM/JavaScript UTF-16 下标时调用 `codePointIndexToUTF16`，避免包含扩展字符时标错位置。

输入歧义和形式化失败都通过现有反馈区域展示。不能仅看到任务完成或接口返回 200 就把结果涂成“证明成立”。
