import Mathlib

theorem q3_false_universal_parity :
    ¬ (∀ a b : ℕ, 0 < a → 0 < b → a ≠ b → a*b = 1000000 → Odd (Nat.dist a b)) := by
  intro h
  have hc := h 2 500000 (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  norm_num [Nat.dist] at hc
