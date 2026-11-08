import Mathlib

example : ∀ (p n : ℕ), Nat.Prime p → 1 < n → (p : ℤ) ∣ (n : ℤ) ^ 6 - 1 → (∀ (m : ℕ), 1 < m → m < n → ¬ (p : ℤ) ∣ (m : ℤ) ^ 6 - 1) → (p : ℤ) ∣ ((n : ℤ) + 1) ^ 6 - 1 ∨ (p : ℤ) ∣ ((n : ℤ) + 2) ^ 6 - 1 := by
  intro p n hp hn h6 hmin
  have case1 : (p : ℤ) ∣ (n : ℤ) ^ 2 + (n : ℤ) + 1 →
      (p : ℤ) ∣ ((n : ℤ) + 1) ^ 6 - 1 := by
    intro hc
    have hfac : ((n : ℤ) + 1) ^ 6 - 1 =
        ((n : ℤ) ^ 2 + (n : ℤ) + 1) *
          ((n : ℤ) ^ 4 + 5 * (n : ℤ) ^ 3 + 9 * (n : ℤ) ^ 2 + 6 * (n : ℤ)) := by
      ring
    rw [hfac]
    exact dvd_mul_of_dvd_left hc _
  have case2 : (p : ℤ) ∣ (n : ℤ) + 1 →
      (p : ℤ) ∣ ((n : ℤ) + 2) ^ 6 - 1 := by
    intro hc
    have hfac : ((n : ℤ) + 2) ^ 6 - 1 =
        ((n : ℤ) + 1) *
          (((n : ℤ) + 2) ^ 5 + ((n : ℤ) + 2) ^ 4 + ((n : ℤ) + 2) ^ 3 +
            ((n : ℤ) + 2) ^ 2 + ((n : ℤ) + 2) + 1) := by
      ring
    rw [hfac]
    exact dvd_mul_of_dvd_left hc _
  have case3 : (p : ℤ) ∣ (n : ℤ) - 1 →
      (p : ℤ) ∣ ((n : ℤ) + 2) ^ 6 - 1 := by
    intro hc
    have hnot_ge4 : ¬ 4 ≤ n := by
      intro hn4
      let m : ℕ := n - 2
      have hm_gt1 : 1 < m := by
        dsimp [m]
        omega
      have hm_lt_n : m < n := by
        dsimp [m]
        omega
      have hdiv : (p : ℤ) ∣ (m : ℤ) ^ 6 - 1 := by
        have hcast : (m : ℤ) = (n : ℤ) - 2 := by
          dsimp [m]
          exact Nat.cast_sub (by omega : 2 ≤ n)
        rw [hcast]
        have hfac : ((n : ℤ) - 2) ^ 6 - 1 =
            ((n : ℤ) - 1) *
              (((n : ℤ) - 1) ^ 5 - 6 * ((n : ℤ) - 1) ^ 4 +
                15 * ((n : ℤ) - 1) ^ 3 - 20 * ((n : ℤ) - 1) ^ 2 +
                15 * ((n : ℤ) - 1) - 6) := by
          ring
        rw [hfac]
        exact dvd_mul_of_dvd_left hc _
      exact (hmin m hm_gt1 hm_lt_n) hdiv
    have hn_cases : n = 2 ∨ n = 3 := by omega
    rcases hn_cases with hn2 | hn3
    · subst n
      have hp_dvd_one : (p : ℤ) ∣ 1 := by
        simpa using hc
      have hp_dvd_one_nat : p ∣ 1 := by
        exact_mod_cast hp_dvd_one
      exact False.elim (hp.ne_one (Nat.dvd_one.mp hp_dvd_one_nat))
    · subst n
      have hp_dvd_two : (p : ℤ) ∣ 2 := by
        norm_num at hc ⊢
        all_goals exact hc
      have hp_dvd_two_nat : p ∣ 2 := by
        exact_mod_cast hp_dvd_two
      have hp_le_two : p ≤ 2 := Nat.le_of_dvd (by norm_num) hp_dvd_two_nat
      have hp_ge_two : 2 ≤ p := hp.two_le
      have hp_eq_two : p = 2 := by omega
      subst p
      norm_num
  have case4 : (p : ℤ) ∣ (n : ℤ) ^ 2 - (n : ℤ) + 1 →
      (p : ℤ) ∣ ((n : ℤ) + 2) ^ 6 - 1 := by
    intro hc
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
        exact dvd_mul_of_dvd_left hc _
      exact (hmin m hm_gt1 hm_lt_n) hdiv
    have hn_eq_two : n = 2 := by omega
    subst n
    have hp_dvd_three : (p : ℤ) ∣ 3 := by
      norm_num at hc ⊢
      all_goals exact hc
    have hp_dvd_three_nat : p ∣ 3 := by
      exact_mod_cast hp_dvd_three
    have hp_le_three : p ≤ 3 := Nat.le_of_dvd (by norm_num) hp_dvd_three_nat
    have hp_ge_two : 2 ≤ p := hp.two_le
    have hp_eq_three : p = 3 := by
      interval_cases p <;> simp_all
    subst p
    norm_num
  have hsplit : (p : ℤ) ∣ (n : ℤ) - 1 ∨
      ((p : ℤ) ∣ (n : ℤ) + 1 ∨
        ((p : ℤ) ∣ (n : ℤ) ^ 2 + (n : ℤ) + 1 ∨
          (p : ℤ) ∣ (n : ℤ) ^ 2 - (n : ℤ) + 1)) := by
    let a : ℤ := (n : ℤ) - 1
    let b : ℤ := (n : ℤ) + 1
    let c : ℤ := (n : ℤ) ^ 2 + (n : ℤ) + 1
    let d : ℤ := (n : ℤ) ^ 2 - (n : ℤ) + 1
    have hfac : (n : ℤ) ^ 6 - 1 = a * b * c * d := by
      dsimp [a, b, c, d]
      ring
    rw [hfac] at h6
    have hpZ : Prime (p : ℤ) := by
      rw [Int.prime_iff_natAbs_prime]
      simpa using hp
    have h' : (p : ℤ) ∣ (a * b) * (c * d) := by
      convert h6 using 1 <;> ring
    have hAB := (hpZ.dvd_mul).mp h'
    have h1 : (p : ℤ) ∣ a ∨ (p : ℤ) ∣ b ∨ (p : ℤ) ∣ c ∨ (p : ℤ) ∣ d := by
      rcases hAB with hAB | hCD
      · have h_ab := (hpZ.dvd_mul).mp hAB
        rcases h_ab with h_a | h_b
        · exact Or.inl h_a
        · exact Or.inr (Or.inl h_b)
      · have h_cd := (hpZ.dvd_mul).mp hCD
        rcases h_cd with h_c | h_d
        · exact Or.inr (Or.inr (Or.inl h_c))
        · exact Or.inr (Or.inr (Or.inr h_d))
    simpa [a, b, c, d] using h1
  rcases hsplit with ha | hb | hc | hd
  · right
    exact case3 ha
  · right
    exact case2 hb
  · left
    exact case1 hc
  · right
    exact case4 hd
