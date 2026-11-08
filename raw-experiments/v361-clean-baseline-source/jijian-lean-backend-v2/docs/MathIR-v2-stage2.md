# MathIR v2 second-stage verification

This stage remains isolated from v1. It does not change the production API,
MathIR v1, Statement Lock, Mathlib retrieval, DeepSeek, repair, or the existing
Kernel boundary.

## Contract hardening

- Root variable and definition declarations are emitted in dependency order.
  A variable used by a definition is explicitly quantified before the `let`;
  definitions that depend on other definitions are topologically ordered.
  Cycles and undeclared symbols fail validation. Variable-domain constraints
  participate in dependency order too.
- Generated v2 theorem types elaborate under `set_option autoImplicit false`.
  There is no Lean auto-implicit fallback for an undeclared AST symbol.
- `statementHash` identifies the canonical closed Lean theorem type;
  `mathirHash` identifies the complete serialized v2 record; each `routeHash`
  identifies the full route, including proof terms, dependencies, induction
  structure, and source references. `sourceEvidenceHash` covers the source
  record and source-reference associations only. A proof-term change updates
  the route hash without changing source identity. Source-only changes leave
  the theorem hash unchanged.
- Lower-bound induction requires the step condition to be exactly the declared
  `n ≥ lowerBound` proposition, in a local step scope and as a declared
  dependency. The IH stays a local premise. The generated route proof uses
  `Nat.le_induction`; unrelated propositions cannot substitute for the bound.

## Verification model

Each claim becomes a `ProofObligation` with stable `source_id`, route/node IDs,
expected Lean type, source references, local context, dependencies, and its
original `proofTerm`. Base and induction-step obligations are explicit. Every
obligation is checked by the isolated local Lean runtime. The complete locked
goal is then independently replayed through the existing data-only Kernel
audit. A route passes only when all of its obligations and the complete target
Kernel replay pass. `anyRouteKernelPassed` preserves separate route outcomes;
it does not discard failed routes. Source alignment, statement lock, step
results, and Kernel certificates are separate fields.

## Real Lean and Kernel matrix

The reproducible command is:

```sh
.venv/bin/python scripts/verify_mathir_v2_stage2.py
```

It writes the complete proof, obligation, hash, diagnostics, and Kernel
certificate records to
`reports/mathir_v2_stage2_kernel_results.json`. This is a real local Lean 4.34.0
and Mathlib run under the configured macOS sandbox. The report contains no AI
provider calls.

| Scenario | Route result | Complete Kernel result |
|---|---|---|
| `1 = 1`, proof `by rfl` | passed | verified, checked and statement matched, no axioms |
| `1 = 2`, proof `by rfl` | failed (`not_proved`) | no certificate |
| Two methods for `1 = 1` | `by assumption` failed; independent `by rfl` passed | Any-route true; the failed route remains in the report |
| `∀ n, 1 ≤ n → n + 0 = n` | base `by simp` and step `by intro k hk ih; simp` passed | verified; certificate axiom list: `propext` |
| `∑ k ∈ Icc 1 2, (1/2 : ℚ)^k = 3/4` | `by norm_num [Finset.sum_Icc_succ_top]` passed | verified; certificate axiom list: `propext`, `Classical.choice`, `Quot.sound` |

The JSON report records the exact canonical statement hash and route hash for
each case. These certificates prove the encoded Lean statements only; the
separate source-alignment fields do not claim that Kernel verification proves
the human transcription. The report omits the large internal wire expression
bundles; the retained proof terms, expected statement, expression hashes, and
certificate metadata are sufficient to inspect and reproduce each run.

## Reproduced failures and corrections

The first matrix attempt failed at `tests/v2/test_v2_kernel.py:117`, before
induction verification, because its fixture encoded `lowerBound` as an
expression object. The v2 contract requires
the explicit typed literal `{ "type": "Nat", "value": "1" }`; correcting the
fixture allowed the induction route to run.

The next run failed at `tests/v2/test_v2_kernel.py:132`: proof elaboration left
the `Finset.Icc` sum goal unsolved with `by norm_num`. The statement and Rat
typing were correct. Expanding the interval with
`Finset.sum_Icc_succ_top` produced a passing proof and a valid independent
Kernel certificate, confirmed separately and in the final matrix.

Adversarial regressions also cover the original root-definition/autoImplicit
probe, forward definition dependencies, cycles, undeclared names, constrained
variable binder order, local declaration hash separation, route and induction
source-reference hash changes, and unrelated lower-bound step conditions.

The final full default regression completed with `335 passed, 1 skipped, 2
deselected`. The skip was the explicitly selected macOS live runtime test; the
two deselected cases were the `live_ai` Provider tests. The last 100 AI audit
records contained zero real requests; they were test stubs.

## Compatibility and remaining scope

No v1 production files or installed App behavior are changed. The v2 proof
terms are only evaluated in the isolated local Lean environment. This slice
supports direct claim obligations and the explicitly modeled natural induction
route; arbitrary proof-route composition beyond those structures remains
unimplemented. Human source equivalence remains independently assessed and is
not implied by typed AST validation or a Kernel certificate.
