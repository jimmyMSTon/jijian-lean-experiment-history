import Mathlib
#check Set.ofPred
example (f : ℝ → ℝ) : Set ℝ := Set.ofPred (fun x : ℝ => 0 ≤ x ∧ x ≤ 1 ∧ f x < 0)
example (f : ℝ → ℝ) :
  Set.ofPred (fun x : ℝ => 0 ≤ x ∧ x ≤ 1 ∧ f x < 0) =
    {x : ℝ | 0 ≤ x ∧ x ≤ 1 ∧ f x < 0} := by
  rfl
