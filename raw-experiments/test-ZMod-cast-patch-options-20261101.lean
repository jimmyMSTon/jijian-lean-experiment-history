import Mathlib
example (m : ℕ) (hm : m ∣ 3 ^ 2025) : ((3 : ZMod m) ^ 2025) = 0 := by
  have h3 : (((3 ^ 2025 : ℕ) : ZMod m) = 0) :=
    (ZMod.natCast_eq_zero_iff (3 ^ 2025) m).2 hm
  simpa [Nat.cast_pow] using h3

example (m : ℕ) (hm : m ∣ 3 ^ 2025) : ((3 : ZMod m) ^ 2025) = 0 := by
  have h3 : (((3 ^ 2025 : ℕ) : ZMod m) = 0) :=
    (ZMod.natCast_eq_zero_iff (3 ^ 2025) m).2 hm
  norm_num [Nat.cast_pow] at h3 ⊢
  exact h3

example (m : ℕ) (hm : m ∣ 3 ^ 2025) : ((3 : ZMod m) ^ 2025) = 0 := by
  have h3 : (((3 ^ 2025 : ℕ) : ZMod m) = 0) :=
    (ZMod.natCast_eq_zero_iff (3 ^ 2025) m).2 hm
  norm_cast at h3
  exact h3

example (m : ℕ) (hm : m ∣ 3 ^ 2025) : ((3 : ZMod m) ^ 2025) = 0 := by
  have h3 : (((3 ^ 2025 : ℕ) : ZMod m) = 0) :=
    (ZMod.natCast_eq_zero_iff (3 ^ 2025) m).2 hm
  exact_mod_cast h3

example (m : ℕ) (hm : m ∣ 3 ^ 2025) : ((3 : ZMod m) ^ 2025) = 0 := by
  have h3 : (((3 ^ 2025 : ℕ) : ZMod m) = 0) :=
    (ZMod.natCast_eq_zero_iff (3 ^ 2025) m).2 hm
  have hcast : (↑(3 : ℕ) : ZMod m) = (3 : ZMod m) := by norm_num
  rw [← hcast] at *
  exact h3
