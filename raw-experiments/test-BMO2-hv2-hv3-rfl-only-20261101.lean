import Mathlib
set_option maxRecDepth 20000
set_option maxHeartbeats 2000000
def PhiX (n : ℕ) : ℕ := n ^ 2 + n + 1
variable (v : ℕ → ℕ)
variable (hrec : ∀ n : ℕ, 2 ≤ n → (v n : ℚ) =
  (((v (n - 1) : ℚ) ^ 2 + (v (n - 1) : ℚ) + 1) ^ 2025) / (v (n - 2) : ℚ))
variable (hv0 : v 0 = 1)
variable (hpos : 0 < v 1)
example : v 2 = PhiX (v 1) ^ 2025 := by
  apply Nat.cast_injective (R := ℚ)
  rw [hrec 2 (by norm_num), hv0]
  norm_num
  rw [PhiX]
  push_cast
  rfl
example : v 3 * v 1 = PhiX (v 2) ^ 2025 := by
  apply Nat.cast_injective (R := ℚ)
  rw [Nat.cast_mul, hrec 3 (by norm_num)]
  have hv1ne : (v 1 : ℚ) ≠ 0 := by exact_mod_cast (Nat.pos_iff_ne_zero.mp hpos)
  field_simp [hv1ne]
  rw [PhiX]
  push_cast
  rfl
