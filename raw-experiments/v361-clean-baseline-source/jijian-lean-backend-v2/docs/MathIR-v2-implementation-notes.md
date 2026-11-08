# MathIR v2 standalone implementation

This is an experimental, versioned contract and deterministic compiler. It is
not wired into the v1 API or application workflow. Existing v1 records,
statement hashes, proofs, certificates, Mathlib retrieval, repair, and kernel
verification are unchanged.

`contracts/MathIRV2.schema.json` is exported from the Pydantic contract in
`backend/v2/models.py`. The contract stores typed declarations and literals,
scopes, source evidence and references, explicit goal assumptions, independent
proof routes, and structured natural-induction cases. Numeric coercion is never
inferred: a conversion must be represented as an explicit `cast` node.

`backend/v2/typecheck.py` validates expression arity and type, declaration and
scope visibility, source-reference ranges, route dependency DAGs, and the shape
of ordinary and lower-bound induction. A lower-bound induction record carries
its base point, local induction hypothesis, local step-condition assumption,
step proof, and bounded conclusion separately. Route-local assumptions cannot
be promoted to theorem assumptions.

`backend/v2/compiler.py` lowers typed data into a deterministic Lean theorem
statement and separately retains each route's obligations and hash. It accepts
no model-authored Lean fragments. The statement hash excludes source evidence
and candidate proof routes; the source evidence hash and route hashes are
separate. This is a v2 development contract only, not a replacement for v1
Statement Lock or Kernel verification.

The default pytest selection excludes only tests tagged `live_ai`. A test can
still be deliberately selected with `pytest -m live_ai`; this selection rule is
test-runner configuration only and does not alter Provider or App behavior. The
v2 suite uses local data and includes one real local Lean/Mathlib elaboration
test when the local toolchain is available. It makes no DeepSeek requests.

## Verification performed

- `tests/v2`: 11 schema/type/compile/induction/route tests passed.
- Three compiler-generated statements (Nat, Rat, and `Polynomial ℝ`) were
  elaborated by the installed Lean 4.34.0 toolchain against the existing local
  Mathlib project.
- Full default pytest: `325 passed, 1 skipped, 2 deselected`. The skip is the
  explicitly gated macOS live runtime test; the two deselected tests are tagged
  `live_ai`.
- The audit log rows added by the final default test run reported
  `real_request_attempted: false`; no live DeepSeek HTTP request was made by
  that run.
- `scripts/check_examples.py` independently reported the pre-existing v1
  example as locally verified with an isolated data-only kernel replay. That is
  evidence for the existing v1 sample only; v2 routes have not received kernel
  certificates.

This initial slice does not claim complete theorem-to-proof compilation,
induction proof synthesis, formal source fidelity, or kernel acceptance for
arbitrary v2 routes. Those remain follow-up work before any production use.
