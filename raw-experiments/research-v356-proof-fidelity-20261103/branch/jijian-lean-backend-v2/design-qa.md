# SwiftUI design QA — 2026-10-07

Verdict: NEEDS POLISH. Native migration implemented; pixel-exact acceptance remains open.

15 confirmed screens use SwiftUI. Official binary does not link WebKit. Stitch original screenshots/exports are preserved in ../stitch-current. Latest native captures are reports/swiftui-migration/screenshots/01-native.png through 15-native.png, from an explicitly labelled fixture preview.

Remaining: exact icon shapes (SF Symbols vs Material Symbols), mathematical typography/typesetting, and page-specific spacing/size comparisons. Default engineering columns are hidden according to the user's newer requirement. Hardware camera/Continuity checks and a new full live proof in the native client are unexecuted.

Workflow binding checks passed with explicit local fixtures and a real backend pure-text recognition route. This is not new model or Kernel evidence. 36 protected backend files remain byte-identical; DeepSeek audit event count remained 16 (new requests 0).

## Continued fidelity work

Welcome gateway main actions now fill their card width and use the source primary color, secondary actions fill width; source Material Symbols draw/document_scanner/account_tree/auto_awesome replace their SF Symbols substitutes. A SwiftUI Text/CTFont component renders the original font directly. Actual fixture preview capture: reports/swiftui-migration/screenshots/welcome-material-symbols-buttons.png. Text wrapping was corrected to avoid silently truncating descriptions and use cases; preview now shares the official window sizing delegate. Compiled both official App and preview successfully. This does not prove all 15 pages match; verdict remains NEEDS POLISH.

## Shared shell and workspace refinement

Shared sidebar logo/navigation now render source Material Symbols architecture/[LOCAL_USER]/verified/file_upload/tune/troubleshoot; active state uses source cyan #00e7fe and foreground #00646e. Sidebar icon sizing and row padding were reduced to the source values. Workspace gained the missing human proof outline and source cards, populated only from actual current records. Selecting step 2 opened its matching original excerpt in native step detail, verified through the GUI. Screenshot: reports/swiftui-migration/screenshots/workspace-proof-outline.png. Latest official App and preview both compiled and the official bundle signature was verified by the build. Original engineering side columns remain hidden under the newer user requirement. No complete 15-page pixel-match claim.

## Recognition source-column refinement

Source screen 7a7625c9be104027a283d2a5bee6ced4 was inspected together with its original exported grid definition. Recognition now has a 300pt source column with selectable original fragments and an independent original-image card; the remaining width is the human transcription editor. Source Material Symbols and selected cyan tint are preserved. Engineering/Lean target panels remain hidden under the newer instruction. Actual native capture: reports/swiftui-migration/screenshots/recognition-source-column.png and .txt. This fixture is a text-source case; the empty-image state is accurate and does not constitute OCR evidence. Official and preview builds succeeded. The full 15-screen fidelity verdict remains NEEDS POLISH.

## Verifying stage-strip refinement

Inspected original a88d7c66ad8a411d8ec765ac9a255f0a. Added its horizontal stage-card hierarchy in native SwiftUI, without invented timing or completion percentages. Corrected real backend event-name handling for formalizing/formalized/verifying/verified/structured and repair events; previous aliases omitted those names and displayed generic processing. Stage highlight reflects only the current event, and unknown/queued state makes no false completion claim. Current capture: reports/swiftui-migration/screenshots/verifying-stage-strip.png. Capture used explicit UI fixture with no model or Kernel execution. Official build/signature and preview compile passed. Full 15-page fidelity remains unaccepted.

## Success/failure summary refinement

Inspected both original result screens. Restored the compact summary row and a proof-breakdown section header. Values are derived from actual verification step establishment, unresolvedAmbiguityIds, and the verified predicate, with no invented elapsed-time/memory values. Proof cards now use source low-surface gray. Both native official and preview builds passed, and GUI checks showed 4/4 on saved-success and “尚未通过” on explicit failure fixture. Captures: success-result-metrics.png and failure-result-metrics.png. The latter exposed a stale success explanation in the synthetic failure fixture; that preview-only fixture has now been corrected in source and needs a refreshed capture. This is not a new live model/Kernel test. Full visual acceptance remains incomplete.

## Step detail / source mapping refinement

Inspected original screenshots 23d08e342737439b9983abcd2e2943bd and 572475286f1e47eabe0b859baca2de7a. Step detail now pairs original excerpt and selected proof side by side. Dependencies display mapped human mathematics instead of internal node IDs. Source mapping now has a source-style horizontal step selector, bound to selectedStep without any AI action. Official/preview compilation and GUI rendering succeeded; screenshots refined-state-6.png (step detail), refined-state-7.png (source mapping). Failure fixture was rebuilt and GUI confirmed its formerly stale success message is now “这一步尚未完成形式化证明。” (refined-state-5.png). All these are labelled UI fixture checks, not live proof runs. Step-level mapping precision remains explicit; no false pixel/bbox claims. Full 15-page pixel fidelity is still incomplete.

## Ambiguity-card refinement

Inspected fd82a1525ba64343bb8dc632ab306fbc original. Added side-by-side original source and mathematical context, horizontal candidate cards, cyan selected border and right-aligned explicit correction action. No fake confidence, recommendation, crop precision or auto-choice. Image binding uses ambiguity sourceRefs, falling back only when there is a single source block; it cannot silently show an unrelated selected proof's image. Official build/signature and preview compile passed. Native GUI candidate selection was exercised without pressing correction; capture ambiguity-candidate-cards.png. Preview text-source has no image and honestly displays that state. Full 15-page fidelity remains incomplete.

## Import-choice / editing preview refinement

Inspected original import and editing screens. Replaced compact import buttons with four source-style choice cards bound to existing file import, clipboard mathematics, AVFoundation camera navigation, and native handwriting. No new file/count constraints or live AI actions added. Editing preview now supplies an explicit previous original so the existing before/after mathematics layout is actually exercised; source's Lean editor remains hidden per the newer user instruction. Official App and preview compile/signature checks passed. Actual native captures: import-input-cards.png and editing-original-comparison.png. Capture exercises rendering, not new image recognition. Import queue fidelity and remaining page-specific geometry still need work; full acceptance remains incomplete.

## Imported source queue

Import page now restores the source-style list beneath four input cards. List uses existing recognition blocks in order and does not fabricate filenames, throughput, recognition quality or status. Each row opens its corresponding proofreading position through the existing binding. Both builds succeeded. Native GUI showed “已导入原稿”, captured import-recorded-queue.png, and the row action visibly opened 识别校对 with the matching original text. An accessibility observation failed transiently after the action; a fresh observation of the same app confirmed navigation, without restarting or resubmitting any work. No new AI execution. Full 15-page fidelity remains incomplete.

## Camera-page layout refinement

Inspected original fbfbedfe949c4a21a1fd2637c6df531e. Native camera page now has a large original-preview column and a 280pt device/current-draft column, with compact source-style headers/cards and capture action beneath preview. AVFoundation capture binding, device discovery, permission action and image import are preserved. Current draft is labelled as such, never as the newly photographed sheet. Official App/preview compile and signature checks passed; GUI inactive-state capture camera-native-layout.png. Camera was not enabled, no photo captured, and no AI was called. Physical/Continuity camera testing remains unexecuted, so this is layout evidence only. Full 15-page acceptance remains incomplete.

## Preferences native layout refinement

Compared the original Stitch preferences HTML and screenshot with the native window. Replaced the single combined card with a two-column layout: left typography/detail cards, right 390-point live mathematics preview, 24-point spacing/padding, 190-point preview area. Formula is centered and follows the existing persisted math-size binding. No provider, schema, or workflow logic was changed. Unimplemented source controls and fake runtime telemetry were not made into functional claims. Official and explicit preview builds passed; screenshot: `reports/swiftui-migration/screenshots/preferences-native-columns.png`. This is recorded-response visual evidence, not a new AI/Kernel run. Full 15-page pixel-fidelity acceptance remains incomplete.

## System status native card hierarchy

Compared source system-error screenshot/HTML. Native page now uses the source top summary card and two-column content hierarchy, actual draft/record bindings, existing navigation, and initially collapsed technical error code. No synthetic network/AI/kernel telemetry, fallback provider, automatic retry, or new product gate was added. Preview compilation and actual-window inspection passed; screenshot `reports/swiftui-migration/screenshots/system-status-native-cards.png` uses explicit saved records and does not prove new AI/Kernel execution. Full 15-page exact visual acceptance remains incomplete.

## Formal details split inspection

Compared original formal-details HTML and screenshot. Native page now pairs the actual human proposition and proof steps on the left with a 390-point inspector on the right, with 24-point gutter. Lean text uses the source dark teal code surface; other contract views remain selectable data. Selecting a step uses the existing detail navigation. Preview and official builds passed after fixing the required proof-card number argument. Actual rendered screenshot: `reports/swiftui-migration/screenshots/formal-details-native-split.png`. The snapshot is explicit replay of an existing verified record, not a new AI/Kernel result. Full 15-page exact fidelity remains unproven.

## Full current 15-page evidence refresh

Captured all 15 states from the current explicit native preview, with per-page PNG and AX text in screenshots/current15. Inspected the full Stitch/SwiftUI contact comparison. Overall verdict remains NOT 1:1; a page-by-page gap audit is recorded in reports/swiftui-migration/15页视觉差异审计.md. Old contact sheets are not evidence for the current build. No provider requests were used.

## Shared proof-card formula inset

Source success HTML specifies a separate formula panel with p-4, surface-container and rounded-lg, distinct from the outer surface-container-low step card. Native ProofCard now implements that panel with 16-point inset and #eeeeee surface. Number background matches primary/15. Added per-use fill so formal-details uses the source white outer cards while results retain the source low-gray outer cards. Existing step navigation/data/status logic is unchanged. Preview and official builds passed; actual success screenshot `reports/swiftui-migration/screenshots/success-inset-proof-cards.png` inspected. Explicit replay only; no new AI/Kernel run. Full pixel fidelity still incomplete.

## Results proposition banner

Source success banner uses low-gray p-8 container, left status/proposition/text, right compact verification badge, and metrics inside the same container. Implemented that hierarchy with existing actual verification predicate and data. Moved existing edit action into the upper toolbar; kept original mapping/export/explanation actions. Actual success and synthetic failure screenshots saved as success-native-banner.png and failure-native-banner.png; success visually inspected. Preview and official builds passed. Source fake Lean version/time/performance claims are not copied. No new AI requests or Kernel runs. Full 15-page 1:1 verdict remains incomplete.

## Source mapping and step dependency hierarchy

Compared both source-mapping and step-detail Stitch screenshots and current native views. Reorganized detail with a status panel, original-step card and current proof on the left; a 280-point dependencies/source column on the right; 24-point gutter. Mapping now renders the selected step excerpt beside its actual proof instead of all proof cards, and highlights only source blocks referenced by the step. Asset images come from each actual source block; no fallback to unrelated selected image. Explicit text retains step-level precision. In real native preview, selecting step 3 updated excerpt and detail showed both recorded dependencies. Screenshots: source-mapping-current-step.png and step-detail-third-dependencies.png. Preview and official builds passed, recorded response only, no AI or Kernel run. Full 15-page 1:1 remains incomplete.

## Recognition original and revision cards

Reordered left column to source-image comparison then numbered selectable blocks, with selected border/background. Right column separates recorded original from existing bound editor; original preview uses a 190-point scroll region so long source does not push editing far below the viewport. Source empty-image state remains honest; no synthetic crop/confidence. Existing select/save/verify handlers unchanged. Preview and official builds passed. Screenshots recognition-original-edit-cards.png (before height correction) and recognition-compact-original.png (current). Explicit recorded response preview only; no recognition/AI/Kernel invocation. Full 15-page fidelity remains incomplete.

## Verifying stage container and status column

Compared source verifying HTML/screenshot. Wrapped existing five-stage strip in source-like white p-5 card with compact Material header. Main area now places original mathematics on left and 280-point current event/cancel cards on right with 24-point gutter. Actual event mapping and cancel handler unchanged. No percentage/ETA, claimed closed steps, fake diagnostics or retry added. Preview and official builds passed; inspected actual screenshot verifying-native-process-cards.png. Explicit verifying UI fixture, no real AI/Lean task was started. Full 15-page 1:1 remains incomplete.

## Editing revision emphasis

Added presentation-only line differences using Swift CollectionDifference; old replaced/removed lines appear red, added lines appear cyan in an explicitly expanded preview. Both source panes preserve full text and use fixed-height scrolling. Existing editDraft/verify handlers unchanged. Pure Swift checks passed for unchanged text, Unicode replacement, duplicate deletion and added line, using existing toolchain overlay after an initial no-overlay compiler failure. In actual native preview, replacing one line produced remove=1/add=1, retained other lines and showed both color states; screenshot editing-line-difference.png. No verify button pressed and no AI request. Preview/official builds passed. Text-diff coloring conveys textual change only, never semantic validity. Full 15-page visual acceptance incomplete.

## Welcome halo and capsule

Matched original welcome HTML halo (720x380 cyan/10 blur100, secondary320 blur90), Sigma tint, and capsule fast-input/button with return indicator, all SwiftUI. Existing verify binding preserved. During screenshot repair, lineLimit(1) was found to normalize newline text and write back the bound draft; that change was withdrawn and replaced by presentation clipping. Fresh native window AX confirmed multiline source preserved. Preview and final official builds passed; screenshot welcome-native-halo-capsule.png. No submit/AI/Kernel call. Full 15-page 1:1 incomplete.
