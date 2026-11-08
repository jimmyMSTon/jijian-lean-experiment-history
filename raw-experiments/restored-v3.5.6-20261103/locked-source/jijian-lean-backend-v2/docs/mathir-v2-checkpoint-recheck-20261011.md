# MathIR v2 checkpoint recheck — 2026-10-11

This is a safe engineering checkpoint on top of `d0b4d87cfa1244577170a13a4344f6aca48bb385` (`codex/mathir-v2-stage3`). The commit preserves the current uncommitted v2 source workflow integration and tests; it does not claim that the workflow has passed a live provider-to-Kernel run. No DeepSeek request was made in this recheck. The formal Mac App, Lean runtime sources, and Kernel trust boundary were not changed.

## Work preserved in the checkpoint

- A server-authored source-evidence adapter and a structure-only MathIR v2 provider contract. Model output cannot supply or rewrite source text and cannot provide proof terms.
- An additive `/api/v2/pipeline` and `/api/v2/jobs` path wired to proof-only generation, the existing Mathlib retriever, Lean verification, and the existing repair workflow. The v1 routes remain available.
- Content-addressed storage for large proof terms and Lean proof wires, plus compact workflow and verification history artifacts.
- The `mixed` source kind in the v2 schema, generated schema/OpenAPI files, and stub-based tests for the service wiring.

The service wiring test uses recorded provider and Lean stubs. It verifies serialization, event, storage, and route wiring only; its simulated Kernel flags are not real AI or Kernel evidence. A real v2 end-to-end request was not run.

## Regression results

Commands executed with the project Python 3.12 virtual environment:

```text
.venv/bin/python -m py_compile ...
.venv/bin/python scripts/export_contracts.py
.venv/bin/python -m pytest tests/v2/test_structure_pipeline.py tests/v2/test_workflow.py tests/v2/test_mathir_v2.py -q
.venv/bin/python -m pytest -q
```

`py_compile`, contract generation, and `git diff --check` passed. The targeted suite ended with **75 passed, 1 failed**. The full default suite ended with **429 passed, 2 failed, 1 skipped, 2 deselected, 1 warning** in 1,058.86 seconds. The deselected tests are explicitly marked `live_ai`; the skipped macOS runtime test requires its separate explicit runtime setup. The project audit log contains test transport records, but the latest records are marked `real_request_attempted=false`; no real DeepSeek request was made.

The two failures are both induction issues, and no sample-specific fix was made:

1. `tests/v2/test_mathir_v2.py::test_induction_obligations_close_root_definition_binders_without_promoting_sum_index` fails before Lean with `V2_INDUCTION_BASE`. The deterministic type/structure validator cannot reconcile the declared lower bound with this root definition's binder context.
2. `tests/v2/test_v2_kernel.py::test_real_lean_composes_induction_route_with_base_and_transitive_helpers` ran the actual Lean/Kernel path and failed the fixed theorem. The generated composed theorem refers to `v_n` after introducing the quantified binder as `target_induction_n`; Lean reports `Unknown identifier v_n`. Local proof fragments can verify while the composed locked theorem remains unverified. This is a route-composition/scoping defect, not a Kernel pass.

Existing final complete-route evidence remains distinguishable from the earlier Stage 8 snapshots replayed during this check:

| Case | Existing final saved evidence | Supplemental Stage 8 snapshot replay here |
|---|---|---|
| C01 | Current-compiler replay: fixed statement and original route passed, Statement Lock preserved, zero new DeepSeek requests ([report](../reports/mathir-v2-C01-current-compiler-replay.json)). | Fixed statement passed; original route did not. This input predates the saved Stage 9 repair patches and is not the final proof package. |
| C07 | Current Lean/Kernel replay: 8/8 obligations, fixed statement and original route passed, zero Provider calls, 78.881 seconds ([report](../reports/mathir-v2-C07-current-compiler-kernel-replay-20261011.json)). | Not run again; the saved final replay is already on the current compiler and no compiler or Kernel code changed. |
| C08 | Current workflow diagnostics-cleanup replay: fixed statement and original route passed, Statement Lock preserved, zero Provider calls ([report](../reports/mathir-v2-C08-current-diagnostics-cleanup-rerun-20261011.json)). | The Stage 8 snapshot did not pass the fixed statement or original route. It predates the saved diagnostics cleanup and is not the final proof package. |

The supplemental snapshot results are preserved in [the closeout replay report](../reports/mathir-v2-safe-closeout-saved-kernel-rerun-20261011.json). They do not overwrite or replace the later final C01/C08 evidence. The v2 compiler and Lean runner were not changed in this checkpoint.

## Structural limits observed in MathIR v2

- `Expr` is a closed typed AST. Its scalar types are `Nat`, `Int`, `Rat`, and `Real`, with polynomials over `Rat` or `Real`; the current operations include arithmetic and comparisons, logic, quantifiers, finite sums, `sin`, `cos`, polynomial evaluation, and explicit casts/ascriptions. There is no general function-application node or higher-order function type, so a source expression such as `T(n)` cannot currently be represented as a normal function call.
- Symbol identity and binding rely on declaration IDs, binder IDs, and explicit scopes. Reusing a declaration ID for a separate quantified binding can produce a structurally valid but semantically misbound theorem; saved C06 evidence demonstrates that collision.
- Structural induction is represented explicitly, but general multi-variable, nested, or mutually recursive induction composition is not established by the current route compiler. The actual Lean failure above shows a binder-name escape in a simpler induction-with-helper route.
- `sourceRefs` validate source-block ranges and support step-level traceability. They do not prove semantic equivalence between handwritten/Chinese source and the typed MathIR or locate a particular image stroke. The Kernel only checks the locked Lean statement and proof term.
- A fixed statement proof, individual step certificates, dependency usage, route connectivity, composition, and complete original-route success are separate statuses. A theorem proved independently cannot stand in for a broken or disconnected original route.

## Workflow-wide defects and established modules

The recurring workflow boundary is the translation from source semantics to bound typed expressions and from local proof contexts to a composed theorem. A successful schema parse is not semantic confirmation; a valid MathIR compile is not a proof; locally checked fragments do not imply that their dependency graph composes. Repair can only address a proof term when the fixed statement and its context elaborate. The `V2_INDUCTION_BASE` and free `v_n` failures are concrete examples of the current induction handling limits.

The following base modules have direct evidence of working within their supported contracts:

- MathIR v2 schema validation, deterministic type/scope checks for the supported expression subset, source-range validation, and deterministic theorem rendering. Thirteen saved MathIR structures compile in the existing matrix; that is a compiler result, not a semantic or proof-success count.
- Statement/proof locks and structural hashes reject patches that alter the locked theorem or MathIR structure.
- The local Lean runner batches statement elaboration and proof export while independently replaying each proof wire in the existing isolated Kernel audit path. Existing C01, C07, and C08 final reports show complete routes for those saved inputs.
- Route connectivity, dependency-closure and binder-use audits, Mathlib candidate `#check` verification, Lean diagnostic parsing, and proof-only patch application each have passing tests or saved execution evidence. They do not guarantee that every MathIR shape is expressible or every generated proof composes.

## Preserved evidence

All reports, proof wires, saved provider responses, research databases, and scratch runtime files remain in place. The regenerated [evidence manifest](mathir-v2-uncommitted-evidence-manifest.tsv) records **2,080 retained evidence/scratch files totaling 1,054,327,290 bytes**, with each relative path, byte size, and SHA-256; it does not embed file contents or secrets. The large evidence files remain uncommitted so the source checkpoint stays reviewable and small.
