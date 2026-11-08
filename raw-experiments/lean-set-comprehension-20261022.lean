import Mathlib
#check Set.setOf
#check setOf
#check Set.iic
example (f : ℝ → ℝ) :
    Set ℝ := Set.setOf (fun x : ℝ => 0 ≤ x ∧ x ≤ 1 ∧ f x < 0)
example (f : ℝ → ℝ) :
    Set ℝ := {x : ℝ | 0 ≤ x ∧ x ≤ 1 ∧ f x < 0}
