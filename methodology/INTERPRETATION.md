# Interpretation of experimental evidence

The dataset contains repeated runs, versions, partial proof attempts, adversarial examples, and non-identical benchmarks. It is **not** a statistically representative sample of mathematical problems.

- `kernel_verified=true` establishes only what that particular job certified, not the original natural-language proof.
- `formal_proof_certified` and `original_proof_certified` are separate source fields.
- A verified auxiliary lemma must not be described as a whole-problem proof.
- A rejected deliberately false proof is not equivalent to failure on a correct proof.
- A regression test count is not an independent math benchmark count.
- Null fields mean missing data; they do not imply success or failure.
- Runtime, AI calls and tokens should only be compared under compatible tasks and settings.
- Historical reports are archival artifacts and may contain claims that need independent reproduction.
- The archive inventory lists local filenames and sizes, not the underlying private data.
