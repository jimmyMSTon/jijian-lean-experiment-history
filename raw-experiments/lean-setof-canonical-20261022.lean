import Mathlib
#check setOf
example (f : ℝ → ℝ) : Set ℝ :=
  (setOf (fun x : ℝ => 0 ≤ x ∧ x ≤ 1 ∧ f x < 0))
example (f : ℝ → ℝ) :
  (setOf (fun x : ℝ => 0 ≤ x ∧ x ≤ 1 ∧ f x < 0)) =
    {x : ℝ | 0 ≤ x ∧ x ≤ 1 ∧ f x < 0} := by
  rfl
