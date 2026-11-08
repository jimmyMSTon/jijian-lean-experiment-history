import Mathlib

example : ∀ (p n : ℕ), Nat.Prime p → 1 < n → (p : ℤ) ∣ (n : ℤ) ^ 6 - 1 → (∀ (m : ℕ), 1 < m → m < n → ¬ (p : ℤ) ∣ (m : ℤ) ^ 6 - 1) → (p : ℤ) ∣ (n : ℤ) ^ 2 - (n : ℤ) + 1 → (p : ℤ) ∣ ((n : ℤ) + 2) ^ 6 - 1 := by
  intro p n hp hn h6 hmin hcase
  have hnot_ge3 : ¬ 3 ≤ n := by
    intro hn3
    let m : ℕ := n - 1
    have hm_gt1 : 1 < m := by
      dsimp [m]
      omega
    have hm_lt_n : m < n := by
      dsimp [m]
      omega
    have hdiv : (p : ℤ) ∣ (m : ℤ) ^ 6 - 1 := by
      have hcast : (m : ℤ) = (n : ℤ) - 1 := by
        dsimp [m]
        exact Nat.cast_sub (by omega : 1 ≤ n)
      rw [hcast]
      have hfac : ((n : ℤ) - 1) ^ 6 - 1 =
          ((n : ℤ) ^ 2 - (n : ℤ) + 1) *
            ((n : ℤ) ^ 4 - 5 * (n : ℤ) ^ 3 + 9 * (n : ℤ) ^ 2 - 6 * (n : ℤ)) := by
        ring
      rw [hfac]
      exact dvd_mul_of_dvd_left hcase _
    exact (hmin m hm_gt1 hm_lt_n) hdiv
  have hn_eq_two : n = 2 := by omega
  subst n
  have hp_dvd_three : (p : ℤ) ∣ 3 := by
    norm_num at hcase ⊢
    all_goals exact hcase
  have hp_dvd_three_nat : p ∣ 3 := by
    exact_mod_cast hp_dvd_three
  have hp_le_three : p ≤ 3 := Nat.le_of_dvd (by norm_num) hp_dvd_three_nat
  have hp_ge_two : 2 ≤ p := hp.two_le
  have hp_eq_three : p = 3 := by
    interval_cases p
  subst p
  norm_num
