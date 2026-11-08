# Official macOS UI inventory

Runtime: Swift + SwiftUI (`macos/Native/NativeApp.swift`). WebView pages: 0. Stitch exports: visual reference only. Historical Web source is preserved, not included as the official UI.

Implemented native states: welcome, workspace, recognition, verifying, success, failure, step-detail, source-mapping, ambiguity, editing, import, camera, preferences, system-error, formal-details.

Bindings: existing FastAPI contracts, upload/recognition correction, SSE jobs/cancellation and same-job fallback reads, real saved verification history, Unicode source mapping, file import/export, handwritten Canvas, explicit AVFoundation capture, optional explanation, read-only engineering details. No new provider or product rules.

Evidence and limits: reports/swiftui-migration/客户端架构审计.md and design-qa.md. Native implementation does not imply pixel-exact Stitch acceptance or new live AI/Kernel success.
