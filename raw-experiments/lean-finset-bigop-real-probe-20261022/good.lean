import Mathlib
example (r : ℕ) (p : ℕ → ℕ) : ℕ := by
  let P : ℕ := ∏ j ∈ Finset.Icc 1 r, p j
  exact P
