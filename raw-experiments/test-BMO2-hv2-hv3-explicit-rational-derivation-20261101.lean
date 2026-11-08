import Mathlib
set_option maxRecDepth 4096
set_option maxHeartbeats 200000
def PhiX (n : ℕ) : ℕ := n ^ 2 + n + 1
variable (v : ℕ → ℕ)
variable (hrec : ∀ n : ℕ, 2 ≤ n → (v n : ℚ) =
  (((v (n - 1) : ℚ) ^ 2 + (v (n - 1) : ℚ) + 1) ^ 2025) / (v (n - 2) : ℚ))
variable (hv0 : v 0 = 1)
variable (hpos : 0 < v 1)

example : v 2 = PhiX (v 1) ^ 2025 := by
  have h2 := hrec 2 (by omega)
  have h0q : (v 0 : ℚ) = 1 := by exact_mod_cast hv0
  have h2' : (v 2 : ℚ) =
      (((v 1 : ℚ) ^ 2 + (v 1 : ℚ) + 1) ^ 2025) := by
    simpa only [show (2 : ℕ) - 1 = 1 by omega,
      show (2 : ℕ) - 2 = 0 by omega, h0q, div_one] using h2
  apply Nat.cast_injective (R := ℚ)
  change (v 2 : ℚ) = (PhiX (v 1) ^ 2025 : ℚ)
  simpa [PhiX] using h2'

example : v 3 * v 1 = PhiX (v 2) ^ 2025 := by
  have h3 := hrec 3 (by omega)
  have h1ne : (v 1 : ℚ) ≠ 0 := by
    exact_mod_cast (Nat.pos_iff_ne_zero.mp hpos)
  have h3' : (v 3 : ℚ) * (v 1 : ℚ) =
      (((v 2 : ℚ) ^ 2 + (v 2 : ℚ) + 1) ^ 2025) := by
    rw [show (3 : ℕ) - 1 = 2 by omega,
        show (3 : ℕ) - 2 = 1 by omega] at h3
    calc
      (v 3 : ℚ) * (v 1 : ℚ) =
          ((((v 2 : ℚ) ^ 2 + (v 2 : ℚ) + 1) ^ 2025) / (v 1 : ℚ)) * (v 1 : ℚ) := by
            rw [h3]
      _ = (((v 2 : ℚ) ^ 2 + (v 2 : ℚ) + 1) ^ 2025) := by
            field_simp [h1ne]
  apply Nat.cast_injective (R := ℚ)
  change ((v 3 * v 1 : ℕ) : ℚ) = (PhiX (v 2) ^ 2025 : ℚ)
  simpa [PhiX] using h3'
