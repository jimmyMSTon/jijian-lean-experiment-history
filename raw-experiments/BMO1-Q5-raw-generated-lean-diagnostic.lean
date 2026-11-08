import Mathlib

set_option maxHeartbeats 1000000

theorem bmo1_diagnostic_q5 :
  ∀ (p n : ℕ), Nat.Prime p → 1 < n → p ∣ (n ^ 6 - 1) → (∀ m : ℕ, 1 < m → p ∣ (m ^ 6 - 1) → n ≤ m) → p ∣ ((n + 1) ^ 6 - 1) ∨ p ∣ ((n + 2) ^ 6 - 1) :=
by
  intro p n hp hn hdiv hmin
  haveI : Fact p.Prime := ⟨hp⟩
  have hpow : (n : ZMod p) ^ 6 = 1 := by
    have hle : 1 ≤ n ^ 6 := by
      have hpos : 0 < n := by omega
      have hpowpos : 0 < n ^ 6 := pow_pos hpos 6
      omega
    have hdiv0 : (((n ^ 6 - 1 : ℕ) : ZMod p)) = 0 :=
      (ZMod.natCast_eq_zero_iff_dvd p (n ^ 6 - 1)).2 hdiv
    have hcast : (((n ^ 6 - 1 : ℕ) : ZMod p)) = (n : ZMod p) ^ 6 - 1 := by
      rw [Nat.cast_sub hle]
      push_cast
      norm_num
    rw [hcast] at hdiv0
    exact sub_eq_zero.mp hdiv0
  have source_step_0 :
      ((n : ZMod p) ^ 2 + (n : ZMod p) + 1 = 0) ∨
      ((n : ZMod p) = -1) ∨
      ((n : ZMod p) = 1) ∨
      ((n : ZMod p) ^ 2 - (n : ZMod p) + 1 = 0) := by
    have hfac :
        ((n : ZMod p) - 1) * ((n : ZMod p) + 1) *
        ((n : ZMod p) ^ 2 + (n : ZMod p) + 1) *
        ((n : ZMod p) ^ 2 - (n : ZMod p) + 1) = 0 := by
      have h :
          ((n : ZMod p) - 1) * ((n : ZMod p) + 1) *
          ((n : ZMod p) ^ 2 + (n : ZMod p) + 1) *
          ((n : ZMod p) ^ 2 - (n : ZMod p) + 1) = (n : ZMod p) ^ 6 - 1 := by
        ring
      rw [h, hpow]
      ring
    rcases mul_eq_zero.mp hfac with h123 | h4
    · rcases mul_eq_zero.mp h123 with h12 | h3
      · rcases mul_eq_zero.mp h12 with h1 | h2
        · have hn1 : (n : ZMod p) = 1 := sub_eq_zero.mp h1
          exact Or.inr (Or.inr (Or.inl hn1))
        · have hnm1 : (n : ZMod p) = -1 := by
            calc
              (n : ZMod p) = (n : ZMod p) + 1 - 1 := by ring
              _ = 0 - 1 := by rw [h2]
              _ = -1 := by ring
          exact Or.inr (Or.inl hnm1)
      · exact Or.inl h3
    · exact Or.inr (Or.inr (Or.inr h4))
  have source_step_10 :
      p ∣ ((n + 1) ^ 6 - 1) ∨ p ∣ ((n + 2) ^ 6 - 1) := by
    rcases source_step_0 with hplus | hminus | hone | hminusquad
    · have hq : (n : ZMod p) + 1 + (n : ZMod p) ^ 2 = 0 := by
        simpa [add_assoc, add_comm, add_left_comm] using hplus
      have hnp1 : (n : ZMod p) + 1 = -((n : ZMod p) ^ 2) := by
        calc
          (n : ZMod p) + 1 =
              ((n : ZMod p) + 1 + (n : ZMod p) ^ 2) + (-((n : ZMod p) ^ 2)) := by ring
          _ = 0 + (-((n : ZMod p) ^ 2)) := by rw [hq]
          _ = -((n : ZMod p) ^ 2) := by ring
      have hcase1pow : ((n : ZMod p) + 1) ^ 6 = 1 := by
        rw [hnp1]
        calc
          (-((n : ZMod p) ^ 2)) ^ 6 = ((n : ZMod p) ^ 2) ^ 6 := by ring
          _ = ((n : ZMod p) ^ 6) ^ 2 := by ring
          _ = 1 := by rw [hpow]; norm_num
      have source_step_1 : p ∣ ((n + 1) ^ 6 - 1) := by
        have hle : 1 ≤ (n + 1) ^ 6 := by
          have hpos : 0 < n + 1 := by omega
          have hpowpos : 0 < (n + 1) ^ 6 := pow_pos hpos 6
          omega
        have hzero : (((n + 1) ^ 6 - 1 : ℕ) : ZMod p) = 0 := by
          rw [Nat.cast_sub hle]
          push_cast
          rw [hcase1pow]
          norm_num
        exact (ZMod.natCast_eq_zero_iff_dvd p (((n + 1) ^ 6 - 1))).mp hzero
      exact Or.inl source_step_1
    · have hnp2 : (n : ZMod p) + 2 = 1 := by
        rw [hminus]
        ring
      have hcase2pow : ((n : ZMod p) + 2) ^ 6 = 1 := by
        rw [hnp2]
        norm_num
      have source_step_2 : p ∣ ((n + 2) ^ 6 - 1) := by
        have hle : 1 ≤ (n + 2) ^ 6 := by
          have hpos : 0 < n + 2 := by omega
          have hpowpos : 0 < (n + 2) ^ 6 := pow_pos hpos 6
          omega
        have hzero : (((n + 2) ^ 6 - 1 : ℕ) : ZMod p) = 0 := by
          rw [Nat.cast_sub hle]
          push_cast
          rw [hcase2pow]
          norm_num
        exact (ZMod.natCast_eq_zero_iff_dvd p (((n + 2) ^ 6 - 1))).mp hzero
      exact Or.inr source_step_2
    · have source_step_3 : (((n : ZMod p) - 2) ^ 6 = 1) := by
        have hnm2 : (n : ZMod p) - 2 = -1 := by
          rw [hone]
          ring
        calc
          ((n : ZMod p) - 2) ^ 6 = (-1) ^ 6 := by rw [hnm2]
          _ = 1 := by norm_num
      have source_step_4 : ¬ 4 ≤ n := by
        intro hge
        have hcast_diff : ((n - 2 : ℕ) : ZMod p) = (n : ZMod p) - 2 := by
          rw [Nat.cast_sub (by omega : 2 ≤ n)]
          norm_num
        have hpow_small : (((n - 2 : ℕ) : ZMod p) ^ 6 = 1) := by
          rw [hcast_diff]
          exact source_step_3
        have hdivsmall : p ∣ ((n - 2) ^ 6 - 1) := by
          have hle : 1 ≤ (n - 2) ^ 6 := by
            have hpos : 0 < n - 2 := by omega
            have hpowpos : 0 < (n - 2) ^ 6 := pow_pos hpos 6
            omega
          have hzero : (((n - 2) ^ 6 - 1 : ℕ) : ZMod p) = 0 := by
            rw [Nat.cast_sub hle]
            push_cast
            rw [hpow_small]
            norm_num
          exact (ZMod.natCast_eq_zero_iff_dvd p (((n - 2) ^ 6 - 1))).mp hzero
        have hle_n : n ≤ n - 2 := hmin (n - 2) (by omega) hdivsmall
        omega
      have source_step_5 : n = 3 := by
        have hn_cases : n = 2 ∨ n = 3 := by omega
        rcases hn_cases with h2 | h3
        · exfalso
          have htwo : (2 : ZMod p) = 1 := by
            simpa [h2] using hone
          have hzero2 : (((2 - 1 : ℕ) : ZMod p) = 0) := by
            rw [Nat.cast_sub (by norm_num : 1 ≤ 2)]
            rw [htwo]
            norm_num
          have h1zero : ((1 : ℕ) : ZMod p) = 0 := by
            simpa using hzero2
          have hp_dvd_one : p ∣ 1 := (ZMod.natCast_eq_zero_iff_dvd p 1).mp h1zero
          have hp_eq_one : p = 1 := Nat.dvd_one.mp hp_dvd_one
          have hp_gt_one : 1 < p := hp.one_lt
          omega
        · exact h3
      have source_step_6 : p ∣ ((n + 2) ^ 6 - 1) := by
        have hthree : (3 : ZMod p) = 1 := by
          simpa [source_step_5] using hone
        have hzero2 : (((3 - 1 : ℕ) : ZMod p) = 0) := by
          rw [Nat.cast_sub (by norm_num : 1 ≤ 3)]
          rw [hthree]
          norm_num
        have h2zero : ((2 : ℕ) : ZMod p) = 0 := by
          simpa using hzero2
        have hp_dvd_2 : p ∣ 2 := (ZMod.natCast_eq_zero_iff_dvd p 2).mp h2zero
        have hp_eq_two : p = 2 := by
          have hp_le_2 : p ≤ 2 := Nat.le_of_dvd (by norm_num : 0 < 2) hp_dvd_2
          have hp_gt_1 : 1 < p := hp.one_lt
          omega
        rw [source_step_5, hp_eq_two]
        norm_num
      exact Or.inr source_step_6
    · have hq : (n : ZMod p) - 1 - (n : ZMod p) ^ 2 = 0 := by
        calc
          (n : ZMod p) - 1 - (n : ZMod p) ^ 2 =
              -((n : ZMod p) ^ 2 - (n : ZMod p) + 1) := by ring
          _ = 0 := by rw [hminusquad, neg_zero]
      have hnm1 : (n : ZMod p) - 1 = (n : ZMod p) ^ 2 := by
        calc
          (n : ZMod p) - 1 = ((n : ZMod p) - 1 - (n : ZMod p) ^ 2) + (n : ZMod p) ^ 2 := by ring
          _ = 0 + (n : ZMod p) ^ 2 := by rw [hq]
          _ = (n : ZMod p) ^ 2 := by ring
      have source_step_7 : (((n : ZMod p) - 1) ^ 6 = 1) := by
        rw [hnm1]
        calc
          ((n : ZMod p) ^ 2) ^ 6 = ((n : ZMod p) ^ 6) ^ 2 := by ring
          _ = 1 := by rw [hpow]; norm_num
      have source_step_8 : n = 2 := by
        have hnot3 : ¬ 3 ≤ n := by
          intro hge
          have hcast_diff : ((n - 1 : ℕ) : ZMod p) = (n : ZMod p) - 1 := by
            rw [Nat.cast_sub (by omega : 1 ≤ n)]
            norm_num
          have hpow_small : (((n - 1 : ℕ) : ZMod p) ^ 6 = 1) := by
            rw [hcast_diff]
            exact source_step_7
          have hdivsmall : p ∣ ((n - 1) ^ 6 - 1) := by
            have hle : 1 ≤ (n - 1) ^ 6 := by
              have hpos : 0 < n - 1 := by omega
              have hpowpos : 0 < (n - 1) ^ 6 := pow_pos hpos 6
              omega
            have hzero : (((n - 1) ^ 6 - 1 : ℕ) : ZMod p) = 0 := by
              rw [Nat.cast_sub hle]
              push_cast
              rw [hpow_small]
              norm_num
            exact (ZMod.natCast_eq_zero_iff_dvd p (((n - 1) ^ 6 - 1))).mp hzero
          have hle_n : n ≤ n - 1 := hmin (n - 1) (by omega) hdivsmall
          omega
        omega
      have source_step_9 : p ∣ ((n + 2) ^ 6 - 1) := by
        have hthree_zero : (3 : ZMod p) = 0 := by
          have hthis := hminusquad
          rw [source_step_8] at hthis
          norm_num at hthis
          exact hthis
        have hp_dvd_3 : p ∣ 3 := (ZMod.natCast_eq_zero_iff_dvd p 3).mp hthree_zero
        have hp_eq_three : p = 3 := by
          have hp_le_3 : p ≤ 3 := Nat.le_of_dvd (by norm_num : 0 < 3) hp_dvd_3
          have hp_gt_1 : 1 < p := hp.one_lt
          have hp_ne_two : p ≠ 2 := by
            intro h2
            have hdiv23 : 2 ∣ 3 := by simpa [h2] using hp_dvd_3
            rcases hdiv23 with ⟨k, hk⟩
            omega
          omega
        rw [source_step_8, hp_eq_three]
        norm_num
      exact Or.inr source_step_9
  exact source_step_10
