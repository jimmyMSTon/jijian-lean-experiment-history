by
  intro α L x hαirr hα hLpos hL hxpos hx1 hrec
  let a : ℕ := Int.toNat (Int.floor (((L : ℝ) + 1) / α))
  have source_step_0 : 1 ≤ a := by
    have hαpos : (0 : ℝ) < α := lt_trans zero_lt_one hα
    have hden : (0 : ℝ) < α - 1 := sub_pos.mpr hα
    have hfrac : α < α ^ 2 / (α - 1) := by
      have hdiff : α ^ 2 / (α - 1) - α = α / (α - 1) := by
        field_simp [hden.ne']
        ring
      have hpos : 0 < α / (α - 1) := div_pos hαpos hden
      linarith
    have hα_lt_L : α < (L : ℝ) := by
      linarith [hL, hfrac]
    have hq : (1 : ℝ) ≤ ((L : ℝ) + 1) / α := by
      have hdiff : ((L : ℝ) + 1) / α - 1 = (((L : ℝ) + 1) - α) / α := by
        field_simp [hαpos.ne']
      have hnum : 0 ≤ ((L : ℝ) + 1) - α := by linarith
      have hnonneg : 0 ≤ ((L : ℝ) + 1) / α - 1 := by
        rw [hdiff]
        exact div_nonneg hnum (le_of_lt hαpos)
      linarith
    have hfloor : (1 : ℤ) ≤ Int.floor (((L : ℝ) + 1) / α) := by
      rw [Int.le_floor]
      simpa using hq
    have hz_nonneg : (0 : ℤ) ≤ Int.floor (((L : ℝ) + 1) / α) := le_trans (by norm_num) hfloor
    have ha_int : (a : ℤ) = Int.floor (((L : ℝ) + 1) / α) := by
      dsimp [a]
      exact Int.toNat_of_nonneg hz_nonneg
    have ha_ge_int : (1 : ℤ) ≤ (a : ℤ) := by
      rw [ha_int]
      exact hfloor
    omega
  have source_step_1 :
      ∃ N : ℕ, 2 ≤ N ∧ x N ≤ L ∧
        (∀ m : ℕ, 1 ≤ m → m < N → L < x m) ∧
        L + 1 ≤ x (N - 1) ∧
        (x N : ℤ) = Int.floor ((x (N - 1) : ℝ) / α) := by
    classical
    let P : ℕ → Prop := fun n => 1 ≤ n ∧ x n ≤ L
    have hex : ∃ n, P n := by
      by_contra hnone
      have hgt : ∀ n : ℕ, 1 ≤ n → L < x n := by
        intro n hn
        have hnot : ¬ x n ≤ L := by
          intro hle
          exact hnone ⟨n, hn, hle⟩
        omega
      have hdec : ∀ n : ℕ, 1 ≤ n → x (n + 1) < x n := by
        intro n hn
        have hxn_gt : L < x n := hgt n hn
        have hnot : ¬ x n ≤ L := by omega
        have hrecn := hrec n hn
        simp [hnot] at hrecn
        have hposn : (0 : ℝ) < (x n : ℝ) := by exact_mod_cast hxpos n hn
        have hαpos : (0 : ℝ) < α := by linarith
        have hlt_real : ((x n : ℝ) / α) < (x n : ℝ) := by
          rw [div_lt_iff₀ hαpos]
          have hmul : (x n : ℝ) * 1 < (x n : ℝ) * α :=
            mul_lt_mul_of_pos_left hα hposn
          simpa using hmul
        have hfloor_lt : Int.floor ((x n : ℝ) / α) < (x n : ℤ) := by
          rw [Int.floor_lt]
          simpa using hlt_real
        have hlt_int : (x (n + 1) : ℤ) < (x n : ℤ) := by
          rw [hrecn]
          exact hfloor_lt
        exact_mod_cast hlt_int
      have hbound : ∀ k : ℕ, x (1 + k) + k ≤ x 1 := by
        intro k
        induction k with
        | zero => simp
        | succ k ih =>
            have hstep := hdec (1 + k) (by omega)
            have hstep' : x (1 + (k + 1)) < x (1 + k) := by
              simpa [Nat.add_assoc] using hstep
            omega
      have hbound0 := hbound (x 1)
      have hzero : x (1 + x 1) = 0 := by omega
      have hpos : 0 < x (1 + x 1) := hxpos (1 + x 1) (by omega)
      omega
    let N : ℕ := Nat.find hex
    have hNspec : 1 ≤ N ∧ x N ≤ L := by
      dsimp [N]
      have h := Nat.find_spec hex
      simpa [P] using h
    have hN_le_of_P : ∀ m : ℕ, P m → N ≤ m := by
      intro m hm
      dsimp [N]
      exact Nat.find_min' hex hm
    have hNpos : 1 ≤ N := hNspec.1
    have hNle : x N ≤ L := hNspec.2
    have hN_ne_one : N ≠ 1 := by
      intro h
      have : x 1 ≤ L := by simpa [h] using hNle
      omega
    have hN_ge_two : 2 ≤ N := by omega
    refine ⟨N, hN_ge_two, hNle, ?_, ?_, ?_⟩
    · intro m hm hmlt
      by_contra hnot_gt
      have hmP : P m := by
        dsimp [P]
        constructor
        · exact hm
        · omega
      have hNm : N ≤ m := hN_le_of_P m hmP
      omega
    · have hprev_ge1 : 1 ≤ N - 1 := by omega
      have hprev_lt : N - 1 < N := by omega
      by_contra hnot
      have hle : x (N - 1) ≤ L := by omega
      have hprevP : P (N - 1) := by
        dsimp [P]
        exact ⟨hprev_ge1, hle⟩
      have hNleprev : N ≤ N - 1 := hN_le_of_P (N - 1) hprevP
      omega
    · have hprev_ge1 : 1 ≤ N - 1 := by omega
      have hprev_not_le : ¬ x (N - 1) ≤ L := by
        intro hle
        have hprevP : P (N - 1) := by
          dsimp [P]
          exact ⟨hprev_ge1, hle⟩
        have hNleprev : N ≤ N - 1 := hN_le_of_P (N - 1) hprevP
        omega
      have hrecprev := hrec (N - 1) hprev_ge1
      have hN_eq : N - 1 + 1 = N := by omega
      simpa [hN_eq, hprev_not_le] using hrecprev
  obtain ⟨N₀, hN₀_ge2, hN₀_le, hN₀_first, hN₀_prev, hN₀_rec⟩ := source_step_1
  let x' : ℕ → ℕ := fun n => x (n + N₀ - 1)
  have source_step_2 :
      ∀ n : ℕ, 1 ≤ n →
        (a : ℝ) ≤ (x' n : ℝ) ∧ (x' n : ℝ) < α * (L : ℝ) := by
    have hαpos : (0 : ℝ) < α := lt_trans zero_lt_one hα
    have hLrealpos : (0 : ℝ) < (L : ℝ) := by exact_mod_cast hLpos
    have hL_lt_αL : (L : ℝ) < α * (L : ℝ) := by
      calc
        (L : ℝ) = 1 * (L : ℝ) := by ring
        _ < α * (L : ℝ) := by
          exact mul_lt_mul_of_pos_right hα hLrealpos
    have hL1_nonneg : 0 ≤ (L : ℝ) + 1 := by positivity
    have hq_nonneg : 0 ≤ (((L : ℝ) + 1) / α) := div_nonneg hL1_nonneg (le_of_lt hαpos)
    have hfloor_a_nonneg : 0 ≤ Int.floor (((L : ℝ) + 1) / α) := by
      rw [Int.le_floor]
      simpa using hq_nonneg
    have ha_int : (a : ℤ) = Int.floor (((L : ℝ) + 1) / α) := by
      dsimp [a]
      exact Int.toNat_of_nonneg hfloor_a_nonneg
    have hαL_not_int : ¬ ∃ m : ℤ, α * (L : ℝ) = (m : ℝ) := by
      rintro ⟨m, hm⟩
      have hαeq : α = (m : ℝ) / (L : ℝ) := by
        field_simp [hLrealpos.ne']
        linarith
      let q : ℚ := (m : ℚ) / (L : ℚ)
      have hqreal : (q : ℝ) = (m : ℝ) / (L : ℝ) := by
        dsimp [q]
        norm_num
      have hαq : α = (q : ℝ) := by
        rw [hαeq, hqreal]
      exact hαirr.ne_rat q hαq
    have hfloor_self : (Int.floor (α * (L : ℝ)) : ℝ) < α * (L : ℝ) := by
      by_contra hnot
      have hle : α * (L : ℝ) ≤ (Int.floor (α * (L : ℝ)) : ℝ) := le_of_not_gt hnot
      have hge : (Int.floor (α * (L : ℝ)) : ℝ) ≤ α * (L : ℝ) := Int.floor_le _
      have heq : (Int.floor (α * (L : ℝ)) : ℝ) = α * (L : ℝ) := le_antisymm hge hle
      apply hαL_not_int
      exact ⟨Int.floor (α * (L : ℝ)), heq.symm⟩
    have hrec' : ∀ n : ℕ, 1 ≤ n →
        ((x' (n + 1) : ℤ) =
          if x' n ≤ L then Int.floor (α * (x' n : ℝ))
          else Int.floor ((x' n : ℝ) / α)) := by
      intro n hn
      have hk : 1 ≤ n + N₀ - 1 := by omega
      have hidx : (n + 1 + N₀ - 1) = (n + N₀ - 1) + 1 := by omega
      dsimp [x']
      rw [hidx]
      exact hrec (n + N₀ - 1) hk
    intro n hn
    induction n, hn using Nat.le_induction with
    | base =>
        have hx'1 : x' 1 = x N₀ := by
          dsimp [x']
          have hidx1 : 1 + N₀ - 1 = N₀ := by omega
          rw [hidx1]
        have hprev_ge : ((L : ℝ) + 1) ≤ (x (N₀ - 1) : ℝ) := by
          exact_mod_cast hN₀_prev
        have hdiv_ge : (((L : ℝ) + 1) / α) ≤ (x (N₀ - 1) : ℝ) / α := by
          exact div_le_div_of_nonneg_right hprev_ge (le_of_lt hαpos)
        have hfloor_ge : (a : ℤ) ≤ Int.floor ((x (N₀ - 1) : ℝ) / α) := by
          rw [ha_int]
          exact Int.floor_mono hdiv_ge
        have hlow_int : (a : ℤ) ≤ (x N₀ : ℤ) := by
          rw [hN₀_rec]
          exact hfloor_ge
        have hlow : (a : ℝ) ≤ (x' 1 : ℝ) := by
          rw [hx'1]
          exact_mod_cast hlow_int
        have hxN_le_real : (x N₀ : ℝ) ≤ (L : ℝ) := by
          exact_mod_cast hN₀_le
        have hupp : (x' 1 : ℝ) < α * (L : ℝ) := by
          rw [hx'1]
          linarith
        exact ⟨hlow, hupp⟩
    | succ n hn ih =>
        by_cases hxle : x' n ≤ L
        · have hrec_eq : (x' (n + 1) : ℤ) = Int.floor (α * (x' n : ℝ)) := by
            simpa [hxle] using hrec' n hn
          have hxpos_real : (0 : ℝ) < (x' n : ℝ) := by
            have ha_pos_nat : 0 < a := lt_of_lt_of_le zero_lt_one source_step_0
            have ha_pos : (0 : ℝ) < (a : ℝ) := by exact_mod_cast ha_pos_nat
            linarith [ih.1]
          have hαx_ge_x : (x' n : ℝ) ≤ α * (x' n : ℝ) := by
            have hmul : (1 : ℝ) * (x' n : ℝ) ≤ α * (x' n : ℝ) :=
              mul_le_mul_of_nonneg_right (le_of_lt hα) (le_of_lt hxpos_real)
            simpa using hmul
          have hfloor_ge : (x' n : ℤ) ≤ Int.floor (α * (x' n : ℝ)) := by
            rw [Int.le_floor]
            simpa using hαx_ge_x
          have ha_le_x : (a : ℤ) ≤ (x' n : ℤ) := by
            exact_mod_cast ih.1
          have hlow_int : (a : ℤ) ≤ (x' (n + 1) : ℤ) := by
            rw [hrec_eq]
            exact le_trans ha_le_x hfloor_ge
          have hlow : (a : ℝ) ≤ (x' (n + 1) : ℝ) := by
            exact_mod_cast hlow_int
          have hxnext_real : (x' (n + 1) : ℝ) = (Int.floor (α * (x' n : ℝ)) : ℝ) := by
            have := congrArg (fun z : ℤ => (z : ℝ)) hrec_eq
            simpa using this
          have hupp : (x' (n + 1) : ℝ) < α * (L : ℝ) := by
            by_cases hxeqL : x' n = L
            · have hxeqL_real : (x' n : ℝ) = (L : ℝ) := by
                exact_mod_cast hxeqL
              have hfloor_lt : (Int.floor (α * (x' n : ℝ)) : ℝ) < α * (L : ℝ) := by
                rw [hxeqL_real]
                exact hfloor_self
              rw [hxnext_real]
              exact hfloor_lt
            · have hxltL_nat : x' n < L := by omega
              have hxltL_real : (x' n : ℝ) < (L : ℝ) := by
                exact_mod_cast hxltL_nat
              have hαx_lt : α * (x' n : ℝ) < α * (L : ℝ) := by
                exact mul_lt_mul_of_pos_left hxltL_real hαpos
              have hfloor_le_y : (Int.floor (α * (x' n : ℝ)) : ℝ) ≤ α * (x' n : ℝ) := Int.floor_le _
              rw [hxnext_real]
              linarith
          exact ⟨hlow, hupp⟩
        · have hrec_eq : (x' (n + 1) : ℤ) = Int.floor ((x' n : ℝ) / α) := by
            simpa [hxle] using hrec' n hn
          have hxgt_nat : L < x' n := by omega
          have hL1_le : L + 1 ≤ x' n := by omega
          have hL1_le_real : (L : ℝ) + 1 ≤ (x' n : ℝ) := by
            exact_mod_cast hL1_le
          have hdiv_ge : (((L : ℝ) + 1) / α) ≤ (x' n : ℝ) / α := by
            exact div_le_div_of_nonneg_right hL1_le_real (le_of_lt hαpos)
          have hfloor_ge : (a : ℤ) ≤ Int.floor ((x' n : ℝ) / α) := by
            rw [ha_int]
            exact Int.floor_mono hdiv_ge
          have hlow_int : (a : ℤ) ≤ (x' (n + 1) : ℤ) := by
            rw [hrec_eq]
            exact hfloor_ge
          have hlow : (a : ℝ) ≤ (x' (n + 1) : ℝ) := by
            exact_mod_cast hlow_int
          have hxnext_real : (x' (n + 1) : ℝ) = (Int.floor ((x' n : ℝ) / α) : ℝ) := by
            have := congrArg (fun z : ℤ => (z : ℝ)) hrec_eq
            simpa using this
          have hdiv_lt_L : (x' n : ℝ) / α < (L : ℝ) := by
            rw [div_lt_iff₀ hαpos]
            calc
              (x' n : ℝ) < α * (L : ℝ) := ih.2
              _ = (L : ℝ) * α := by ring
          have hxnext_lt_L_real : (x' (n + 1) : ℝ) < (L : ℝ) := by
            have hfloor_le_y : (Int.floor ((x' n : ℝ) / α) : ℝ) ≤ (x' n : ℝ) / α := Int.floor_le _
            rw [hxnext_real]
            linarith
          have hupp : (x' (n + 1) : ℝ) < α * (L : ℝ) := by
            have hxnext_le_L_real : (x' (n + 1) : ℝ) ≤ (L : ℝ) := le_of_lt hxnext_lt_L_real
            linarith
          exact ⟨hlow, hupp⟩
  have source_step_3 :
      ((a : ℝ) ≤ (x' 1 : ℝ) ∧ (x' 1 : ℝ) < α * (L : ℝ)) ∧
      (∀ n : ℕ, 1 ≤ n →
        (((a : ℝ) ≤ (x' n : ℝ) ∧ (x' n : ℝ) ≤ (L : ℝ)) →
          (a : ℝ) ≤ (x' (n + 1) : ℝ) ∧ (x' (n + 1) : ℝ) < α * (L : ℝ)) ∧
        (((L : ℝ) + 1 ≤ (x' n : ℝ) ∧ (x' n : ℝ) < α * (L : ℝ)) →
          (a : ℝ) ≤ (x' (n + 1) : ℝ) ∧ (x' (n + 1) : ℝ) < α * (L : ℝ))) := by
    constructor
    · exact source_step_2 1 (by norm_num)
    · intro n hn
      constructor
      · intro _
        exact source_step_2 (n + 1) (by omega)
      · intro _
        exact source_step_2 (n + 1) (by omega)
  have source_step_4 :
      ∃ N : ℕ, ∃ p : ℕ, 0 < p ∧
        ∀ n : ℕ, N ≤ n → x (n + p) = x n := by
    classical
    have hrecx' : ∀ t : ℕ, 1 ≤ t →
        (x' (t + 1) : ℤ) =
          if x' t ≤ L then Int.floor (α * (x' t : ℝ))
          else Int.floor ((x' t : ℝ) / α) := by
      intro t ht
      have hk : 1 ≤ t + N₀ - 1 := by omega
      have hidx : t + 1 + N₀ - 1 = (t + N₀ - 1) + 1 := by omega
      dsimp [x']
      rw [hidx]
      exact hrec (t + N₀ - 1) hk
    have hper_from_eq :
        ∀ i j : ℕ, 1 ≤ i → i < j → x' i = x' j →
          ∃ N : ℕ, ∃ p : ℕ, 0 < p ∧
            ∀ n : ℕ, N ≤ n → x (n + p) = x n := by
      intro i j hi hij heq
      let p : ℕ := j - i
      have hp : 0 < p := by
        dsimp [p]
        omega
      have hper' : ∀ s : ℕ, x' (i + s) = x' (j + s) := by
        intro s
        induction s with
        | zero =>
            simpa using heq
        | succ s ih =>
            have hi_s : 1 ≤ i + s := by omega
            have hj_s : 1 ≤ j + s := by omega
            have hrec_i := hrecx' (i + s) hi_s
            have hrec_j := hrecx' (j + s) hj_s
            have hInt : (x' (i + s + 1) : ℤ) = (x' (j + s + 1) : ℤ) := by
              calc
                (x' (i + s + 1) : ℤ)
                    = (if x' (i + s) ≤ L then
                        Int.floor (α * (x' (i + s) : ℝ))
                      else Int.floor ((x' (i + s) : ℝ) / α)) := hrec_i
                _ = (if x' (j + s) ≤ L then
                        Int.floor (α * (x' (j + s) : ℝ))
                      else Int.floor ((x' (j + s) : ℝ) / α)) := by
                        rw [ih]
                _ = (x' (j + s + 1) : ℤ) := hrec_j.symm
            have hNat : x' (i + s + 1) = x' (j + s + 1) := by
              exact_mod_cast hInt
            simpa [Nat.add_assoc] using hNat
      refine ⟨i + N₀ - 1, p, hp, ?_⟩
      intro n hn
      let s : ℕ := n - (i + N₀ - 1)
      have hn_eq : n = i + N₀ - 1 + s := by
        dsimp [s]
        omega
      have hnp_eq : n + p = j + N₀ - 1 + s := by
        dsimp [p]
        omega
      calc
        x (n + p) = x' (j + s) := by
          rw [hnp_eq]
          dsimp [x']
          have hidx : j + N₀ - 1 + s = (j + s) + N₀ - 1 := by omega
          rw [hidx]
        _ = x' (i + s) := (hper' s).symm
        _ = x n := by
          rw [hn_eq]
          dsimp [x']
          have hidx : i + N₀ - 1 + s = (i + s) + N₀ - 1 := by omega
          rw [hidx]
    let U : ℕ := Int.toNat (Int.floor (α * (L : ℝ)))
    have hU_bound : ∀ n : ℕ, 1 ≤ n → x' n < U + 1 := by
      intro n hn
      have hxlt : (x' n : ℝ) < α * (L : ℝ) := (source_step_2 n hn).2
      have hxleR : (x' n : ℝ) ≤ α * (L : ℝ) := le_of_lt hxlt
      have hfloor_ge_int : (x' n : ℤ) ≤ Int.floor (α * (L : ℝ)) := by
        rw [Int.le_floor]
        simpa using hxleR
      have hxnon : (0 : ℤ) ≤ (x' n : ℤ) := by
        exact_mod_cast (Nat.zero_le (x' n))
      have hnonneg : (0 : ℤ) ≤ Int.floor (α * (L : ℝ)) :=
        le_trans hxnon hfloor_ge_int
      have hU_int : (U : ℤ) = Int.floor (α * (L : ℝ)) := by
        dsimp [U]
        exact Int.toNat_of_nonneg hnonneg
      have hxleU_int : (x' n : ℤ) ≤ (U : ℤ) := by
        rw [hU_int]
        exact hfloor_ge_int
      have hxleU : x' n ≤ U := by exact_mod_cast hxleU_int
      omega
    let f : Fin (U + 2) → Fin (U + 1) := fun k =>
      ⟨x' (k.val + 1), by
        have hk : 1 ≤ k.val + 1 := by omega
        exact hU_bound (k.val + 1) hk⟩
    have hcard : Fintype.card (Fin (U + 1)) < Fintype.card (Fin (U + 2)) := by
      simp
    obtain ⟨k₁, k₂, hkne, hkeq⟩ :=
      Fintype.exists_ne_map_eq_of_card_lt f hcard
    have hval : x' (k₁.val + 1) = x' (k₂.val + 1) := by
      have h := congrArg Fin.val hkeq
      simpa [f] using h
    have hvne : k₁.val ≠ k₂.val := by
      intro h
      exact hkne (Fin.ext h)
    rcases lt_or_gt_of_ne hvne with hlt | hgt
    · exact hper_from_eq (k₁.val + 1) (k₂.val + 1) (by omega) (by omega) hval
    · exact hper_from_eq (k₂.val + 1) (k₁.val + 1) (by omega) (by omega) hval.symm
  have source_step_5 :
      ∃ N p t : ℕ, 1 ≤ N ∧ 0 < p ∧
        (∀ n : ℕ, N ≤ n → x (n + p) = x n) ∧
        t ≤ L ∧
        (∃ j : ℕ, N ≤ j ∧ j < N + p ∧ x j = t) ∧
        (∀ k : ℕ, N ≤ k → k < N + p → x k ≤ L → x k ≤ t) := by
    obtain ⟨N0, p, hp, hper0⟩ := source_step_4
    let N : ℕ := max N0 1
    have hNpos : 1 ≤ N := by simp [N]
    have hper : ∀ n : ℕ, N ≤ n → x (n + p) = x n := by
      intro n hn
      exact hper0 n (le_trans (le_max_left N0 1) hn)
    have hex_mem : ∃ k : ℕ, N ≤ k ∧ k < N + p ∧ x k ≤ L := by
      by_contra hnone
      have hgt : ∀ k : ℕ, N ≤ k → k < N + p → L < x k := by
        intro k hNk hkNp
        have hnot : ¬ x k ≤ L := by
          intro hxk
          exact hnone ⟨k, hNk, hkNp, hxk⟩
        omega
      have hdec : ∀ k : ℕ, N ≤ k → k < N + p → x (k + 1) < x k := by
        intro k hNk hkNp
        have hk1 : 1 ≤ k := le_trans hNpos hNk
        have hxkgt : L < x k := hgt k hNk hkNp
        have hnot : ¬ x k ≤ L := by omega
        have hrec_k := hrec k hk1
        simp [hnot] at hrec_k
        have hposk : (0 : ℝ) < (x k : ℝ) := by exact_mod_cast hxpos k hk1
        have hαpos : (0 : ℝ) < α := lt_trans zero_lt_one hα
        have hlt_real : ((x k : ℝ) / α) < (x k : ℝ) := by
          rw [div_lt_iff₀ hαpos]
          have hmul : (x k : ℝ) * 1 < (x k : ℝ) * α :=
            mul_lt_mul_of_pos_left hα hposk
          simpa using hmul
        have hfloor_lt : Int.floor ((x k : ℝ) / α) < (x k : ℤ) := by
          rw [Int.floor_lt]
          simpa using hlt_real
        have hlt_int : (x (k + 1) : ℤ) < (x k : ℤ) := by
          rw [hrec_k]
          exact hfloor_lt
        exact_mod_cast hlt_int
      have hchain : ∀ m : ℕ, m ≤ p → x (N + m) + m ≤ x N := by
        intro m
        induction m with
        | zero =>
            intro hm
            simp
        | succ m ih =>
            intro hm
            have ih' : x (N + m) + m ≤ x N := ih (by omega)
            have hm_lt : m < p := by omega
            have hstep : x (N + (m + 1)) < x (N + m) := by
              have hNle : N ≤ N + m := by omega
              have hlt : N + m < N + p := by omega
              have hdec' := hdec (N + m) hNle hlt
              simpa [Nat.add_assoc] using hdec'
            omega
      have hp_bound := hchain p (le_refl p)
      have hlt : x (N + p) < x N := by omega
      have heq := hper N (le_refl N)
      omega
    let S : Finset ℕ := (Finset.Ico N (N + p)).filter (fun k => x k ≤ L)
    have hSne : S.Nonempty := by
      rcases hex_mem with ⟨k, hNk, hkNp, hxk⟩
      refine ⟨k, ?_⟩
      dsimp [S]
      rw [Finset.mem_filter, Finset.mem_Ico]
      exact ⟨⟨hNk, hkNp⟩, hxk⟩
    obtain ⟨j, hjS, hmax⟩ := Finset.exists_max_image S (fun k => x k) hSne
    refine ⟨N, p, x j, hNpos, hp, hper, ?_, ?_, ?_⟩
    · exact (Finset.mem_filter.mp hjS).2
    · refine ⟨j, ?_, ?_, rfl⟩
      · exact (Finset.mem_Ico.mp (Finset.mem_filter.mp hjS).1).1
      · exact (Finset.mem_Ico.mp (Finset.mem_filter.mp hjS).1).2
    · intro k hNk hkNp hxk
      have hkS : k ∈ S := by
        dsimp [S]
        rw [Finset.mem_filter, Finset.mem_Ico]
        exact ⟨⟨hNk, hkNp⟩, hxk⟩
      exact hmax k hkS
  obtain ⟨N₁, p₁, t₁, hN₁_pos, hp₁_pos, hper₁, ht₁_le, ht₁_mem, ht₁_max⟩ := source_step_5
  let A : Set ℕ := {u | a ≤ u ∧ u ≤ t₁}
  let B : Set ℕ := {u | L + 1 ≤ u ∧ (u : ℝ) < α * (t₁ : ℝ)}
  have source_step_6 :
      ∀ n : ℕ, N₁ ≤ n → x n ∈ A ∪ B := by
    intro n hn
    have hαpos : (0 : ℝ) < α := lt_trans zero_lt_one hα
    have ht_pos : 0 < t₁ := by
      rcases ht₁_mem with ⟨j, hjN, hjlt, hxj⟩
      have hj1 : 1 ≤ j := le_trans hN₁_pos hjN
      have hposj : 0 < x j := hxpos j hj1
      omega
    have hαt_nonint : ∀ z : ℤ, α * (t₁ : ℝ) ≠ (z : ℝ) := by
      intro z hz
      have ht_ne_real : (t₁ : ℝ) ≠ 0 := by exact_mod_cast (ne_of_gt ht_pos)
      have hαeq : α = (z : ℝ) / (t₁ : ℝ) := by
        calc
          α = (α * (t₁ : ℝ)) / (t₁ : ℝ) := by field_simp [ht_ne_real]
          _ = (z : ℝ) / (t₁ : ℝ) := by rw [hz]
      let q : ℚ := (z : ℚ) / (t₁ : ℚ)
      have hqreal : (q : ℝ) = (z : ℝ) / (t₁ : ℝ) := by
        dsimp [q]
        norm_num
      have hαq : α = (q : ℝ) := by rw [hαeq, hqreal]
      exact hαirr.ne_rat q hαq
    have hfloor_αt_lt : (Int.floor (α * (t₁ : ℝ)) : ℝ) < α * (t₁ : ℝ) := by
      by_contra hnot
      have hle : α * (t₁ : ℝ) ≤ (Int.floor (α * (t₁ : ℝ)) : ℝ) := le_of_not_gt hnot
      have hge : (Int.floor (α * (t₁ : ℝ)) : ℝ) ≤ α * (t₁ : ℝ) := Int.floor_le _
      have heq : (Int.floor (α * (t₁ : ℝ)) : ℝ) = α * (t₁ : ℝ) := le_antisymm hge hle
      exact (hαt_nonint (Int.floor (α * (t₁ : ℝ)))) heq.symm
    have hper_pow : ∀ q m : ℕ, N₁ ≤ m → x (m + q * p₁) = x m := by
      intro q
      induction q with
      | zero =>
          intro m hm
          simp
      | succ q ih =>
          intro m hm
          have hstep := hper₁ (m + q * p₁) (by omega)
          calc
            x (m + (q + 1) * p₁) = x ((m + q * p₁) + p₁) := by
              congr 1
              rw [Nat.succ_mul]
              omega
            _ = x (m + q * p₁) := hstep
            _ = x m := ih m hm
    have h_cycle_upper : ∀ k : ℕ, N₁ ≤ k → (x k : ℝ) < α * (L : ℝ) := by
      intro k hk
      let K : ℕ := k + N₀ * p₁
      have hK_eq : x K = x k := by
        dsimp [K]
        exact hper_pow N₀ k hk
      have hp_ge : 1 ≤ p₁ := hp₁_pos
      have hN0_le_mul : N₀ ≤ N₀ * p₁ := by
        calc
          N₀ = N₀ * 1 := by rw [Nat.mul_one]
          _ ≤ N₀ * p₁ := Nat.mul_le_mul_left N₀ hp_ge
      have hK_ge : N₀ ≤ K := by
        dsimp [K]
        omega
      let idx : ℕ := K - N₀ + 1
      have hidx1 : 1 ≤ idx := by dsimp [idx]; omega
      have hxsrc := (source_step_2 idx hidx1).2
      have hx'eq : x' idx = x K := by
        dsimp [x', idx]
        congr 1
        omega
      have hltK : (x K : ℝ) < α * (L : ℝ) := by
        simpa [hx'eq] using hxsrc
      simpa [hK_eq] using hltK
    have hmain : ∀ m : ℕ, N₁ ≤ m → x m ∈ A ∪ B := by
      intro m
      induction m using Nat.strong_induction_on with
      | h m ih =>
          intro hm
          by_cases hwin : m < N₁ + p₁
          · change x m ∈ A ∨ x m ∈ B
            by_cases hLle : x m ≤ L
            · left
              dsimp [A]
              constructor
              · have hm_ge_N0 : N₀ ≤ m := by
                  by_contra h
                  have hmlt : m < N₀ := by omega
                  have hm1 : 1 ≤ m := le_trans hN₁_pos hm
                  have hgt := hN₀_first m hm1 hmlt
                  omega
                let idx : ℕ := m - N₀ + 1
                have hidx1 : 1 ≤ idx := by dsimp [idx]; omega
                have hxsrc := source_step_2 idx hidx1
                have hx'eq : x' idx = x m := by
                  dsimp [x', idx]
                  congr 1
                  omega
                have ha_real : (a : ℝ) ≤ (x m : ℝ) := by
                  have := hxsrc.1
                  simpa [hx'eq] using this
                exact_mod_cast ha_real
              · exact ht₁_max m hm hwin hLle
            · right
              dsimp [B]
              constructor
              · omega
              · have hLgt : L < x m := by omega
                have upper_of_pred : ∀ k : ℕ, N₁ ≤ k → k < N₁ + p₁ → x m = x (k + 1) →
                    (x m : ℝ) < α * (t₁ : ℝ) := by
                  intro k hk_ge hk_lt hm_eq
                  have hk_pos : 1 ≤ k := le_trans hN₁_pos hk_ge
                  have hxk_lt_αL : (x k : ℝ) < α * (L : ℝ) := h_cycle_upper k hk_ge
                  have hxk_le : x k ≤ L := by
                    by_contra hnot
                    have hxk_gt : L < x k := by omega
                    have hkrec := hrec k hk_pos
                    have hnotif : ¬ x k ≤ L := by omega
                    have hquot_lt : (x k : ℝ) / α < (L : ℝ) := by
                      rw [div_lt_iff₀ hαpos]
                      calc
                        (x k : ℝ) < α * (L : ℝ) := hxk_lt_αL
                        _ = (L : ℝ) * α := by ring
                    have hfloor_lt_L : (Int.floor ((x k : ℝ) / α) : ℝ) < (L : ℝ) := by
                      exact lt_of_le_of_lt (Int.floor_le _) hquot_lt
                    have hnext_eq : (x (k + 1) : ℤ) = Int.floor ((x k : ℝ) / α) := by
                      simpa [hnotif] using hkrec
                    have hnext_lt_L_real : (x (k + 1) : ℝ) < (L : ℝ) := by
                      have hnext_eq_real : (x (k + 1) : ℝ) = (Int.floor ((x k : ℝ) / α) : ℝ) := by
                        exact_mod_cast hnext_eq
                      rw [hnext_eq_real]
                      exact hfloor_lt_L
                    have hnext_le : x (k + 1) ≤ L := by
                      exact_mod_cast (le_of_lt hnext_lt_L_real)
                    have hxm_le : x m ≤ L := by
                      rw [hm_eq]
                      exact hnext_le
                    omega
                  have hxkt : x k ≤ t₁ := ht₁_max k hk_ge hk_lt hxk_le
                  have hxm_int_eq : (x m : ℤ) = Int.floor (α * (x k : ℝ)) := by
                    rw [hm_eq]
                    simpa [if_pos hxk_le] using hrec k hk_pos
                  have hxm_real_eq : (x m : ℝ) = (Int.floor (α * (x k : ℝ)) : ℝ) := by
                    have := congrArg (fun z : ℤ => (z : ℝ)) hxm_int_eq
                    simpa using this
                  by_cases hxeqt : x k = t₁
                  · have hxk_real_eq : (x k : ℝ) = (t₁ : ℝ) := by exact_mod_cast hxeqt
                    have hfloor_lt : (Int.floor (α * (x k : ℝ)) : ℝ) < α * (t₁ : ℝ) := by
                      rw [hxk_real_eq]
                      exact hfloor_αt_lt
                    rw [hxm_real_eq]
                    exact hfloor_lt
                  · have hxlt : x k < t₁ := by omega
                    have hxk_real_lt : (x k : ℝ) < (t₁ : ℝ) := by exact_mod_cast hxlt
                    have hαlt : α * (x k : ℝ) < α * (t₁ : ℝ) :=
                      mul_lt_mul_of_pos_left hxk_real_lt hαpos
                    have hfloor_le : (Int.floor (α * (x k : ℝ)) : ℝ) ≤ α * (x k : ℝ) := Int.floor_le _
                    rw [hxm_real_eq]
                    linarith
                by_cases hlt : N₁ < m
                · let k : ℕ := m - 1
                  have hk_ge : N₁ ≤ k := by dsimp [k]; omega
                  have hk_lt : k < N₁ + p₁ := by dsimp [k]; omega
                  have hm_eq : x m = x (k + 1) := by
                    have hk1 : k + 1 = m := by dsimp [k]; omega
                    rw [hk1]
                  exact upper_of_pred k hk_ge hk_lt hm_eq
                · have hmN : m = N₁ := by omega
                  let k : ℕ := N₁ + p₁ - 1
                  have hk_ge : N₁ ≤ k := by dsimp [k]; omega
                  have hk_lt : k < N₁ + p₁ := by dsimp [k]; omega
                  have hm_eq : x m = x (k + 1) := by
                    have hk1 : k + 1 = N₁ + p₁ := by dsimp [k]; omega
                    have hperN := hper₁ N₁ (le_refl N₁)
                    calc
                      x m = x N₁ := by rw [hmN]
                      _ = x (N₁ + p₁) := hperN.symm
                      _ = x (k + 1) := by rw [hk1]
                  exact upper_of_pred k hk_ge hk_lt hm_eq
          · have hle_sub : N₁ ≤ m - p₁ := by omega
            have hlt_sub : m - p₁ < m := by omega
            have heq : x m = x (m - p₁) := by
              have hper := hper₁ (m - p₁) hle_sub
              have hsub : m - p₁ + p₁ = m := by omega
              simpa [hsub] using hper
            rw [heq]
            exact ih (m - p₁) hlt_sub hle_sub
    exact hmain n hn
  have source_step_7 :
      Int.floor (α * (a : ℝ)) < (L + 1 : ℤ) ∧
      (L + 1 : ℤ) ≤ Int.floor (α * ((a + 1 : ℕ) : ℝ)) := by
    have hαpos : (0 : ℝ) < α := lt_trans zero_lt_one hα
    have hLreal : (0 : ℝ) < (L : ℝ) := by exact_mod_cast hLpos
    have hL1_nonneg : (0 : ℝ) ≤ (L : ℝ) + 1 := by linarith
    have hq_nonneg : (0 : ℝ) ≤ ((L : ℝ) + 1) / α := by
      exact div_nonneg hL1_nonneg (le_of_lt hαpos)
    have hfloor_nonneg : (0 : ℤ) ≤ Int.floor (((L : ℝ) + 1) / α) := by
      rw [Int.le_floor]
      simpa using hq_nonneg
    have ha_int : (a : ℤ) = Int.floor (((L : ℝ) + 1) / α) := by
      dsimp [a]
      exact Int.toNat_of_nonneg hfloor_nonneg
    have ha_le_q_real : (a : ℝ) ≤ ((L : ℝ) + 1) / α := by
      have hfloor_le := Int.floor_le (((L : ℝ) + 1) / α)
      have haeq : (a : ℝ) = (Int.floor (((L : ℝ) + 1) / α) : ℝ) := by
        exact_mod_cast ha_int
      rw [haeq]
      exact hfloor_le
    have hmul_le : α * (a : ℝ) ≤ (L : ℝ) + 1 := by
      calc
        α * (a : ℝ) ≤ α * (((L : ℝ) + 1) / α) := by
          exact mul_le_mul_of_nonneg_left ha_le_q_real (le_of_lt hαpos)
        _ = (L : ℝ) + 1 := by
          field_simp [hαpos.ne']
    have ha_pos_nat : 0 < a := lt_of_lt_of_le zero_lt_one source_step_0
    have ha_pos_real : (0 : ℝ) < (a : ℝ) := by exact_mod_cast ha_pos_nat
    have hαa_ne : α * (a : ℝ) ≠ (L : ℝ) + 1 := by
      intro heq
      have hα_eq : α = ((L : ℝ) + 1) / (a : ℝ) := by
        calc
          α = (α * (a : ℝ)) / (a : ℝ) := by
            field_simp [ha_pos_real.ne']
          _ = ((L : ℝ) + 1) / (a : ℝ) := by rw [heq]
      let q : ℚ := ((L : ℚ) + 1) / (a : ℚ)
      have hqreal : (q : ℝ) = ((L : ℝ) + 1) / (a : ℝ) := by
        dsimp [q]
        norm_num
      have hαq : α = (q : ℝ) := by
        rw [hα_eq, hqreal]
      exact hαirr.ne_rat q hαq
    have hαa_lt : α * (a : ℝ) < (L : ℝ) + 1 := by
      exact lt_of_le_of_ne hmul_le hαa_ne
    have hq_lt_succ : ((L : ℝ) + 1) / α < (a : ℝ) + 1 := by
      have hlt := Int.lt_floor_add_one (((L : ℝ) + 1) / α)
      have haeq : (a : ℝ) = (Int.floor (((L : ℝ) + 1) / α) : ℝ) := by
        exact_mod_cast ha_int
      rw [← haeq] at hlt
      exact hlt
    have hmul_succ_lt : (L : ℝ) + 1 < α * ((a + 1 : ℕ) : ℝ) := by
      calc
        (L : ℝ) + 1 = α * (((L : ℝ) + 1) / α) := by
          field_simp [hαpos.ne']
        _ < α * ((a : ℝ) + 1) := by
          exact mul_lt_mul_of_pos_left hq_lt_succ hαpos
        _ = α * ((a + 1 : ℕ) : ℝ) := by
          norm_num
    constructor
    · rw [Int.floor_lt]
      simpa using hαa_lt
    · rw [Int.le_floor]
      simpa using le_of_lt hmul_succ_lt
  have source_step_8 :
      (∀ i : ℕ, N₁ ≤ i → x i ∈ A → a < x i → x (i + 1) ∈ B) ∧
      (∀ i : ℕ, N₁ ≤ i → x i = a → x (i + 1) ∈ A) ∧
      (∀ i : ℕ, N₁ ≤ i → x i ∈ B → x (i + 1) ∈ A ∧ x (i + 1) < t₁) := by
    have hαpos : (0 : ℝ) < α := lt_trans zero_lt_one hα
    constructor
    · intro i hi hiA hgt
      have hi_ge1 : 1 ≤ i := le_trans hN₁_pos hi
      have hiA' : a ≤ x i ∧ x i ≤ t₁ := by simpa [A] using hiA
      have hxi_le_t : x i ≤ t₁ := hiA'.2
      have hxi_le_L : x i ≤ L := le_trans hxi_le_t ht₁_le
      have hrec_i := hrec i hi_ge1
      have hnext_eq_int : (x (i + 1) : ℤ) = Int.floor (α * (x i : ℝ)) := by
        simpa [if_pos hxi_le_L] using hrec_i
      have hnext_eq_real : (x (i + 1) : ℝ) = (Int.floor (α * (x i : ℝ)) : ℝ) := by
        have := congrArg (fun z : ℤ => (z : ℝ)) hnext_eq_int
        simpa using this
      have hxi_ge_a1 : a + 1 ≤ x i := by omega
      have hxi_ge_a1_real : ((a + 1 : ℕ) : ℝ) ≤ (x i : ℝ) := by exact_mod_cast hxi_ge_a1
      have hmul_ge : α * ((a + 1 : ℕ) : ℝ) ≤ α * (x i : ℝ) :=
        mul_le_mul_of_nonneg_left hxi_ge_a1_real (le_of_lt hαpos)
      have hfloor_ge : Int.floor (α * ((a + 1 : ℕ) : ℝ)) ≤ Int.floor (α * (x i : ℝ)) :=
        Int.floor_mono hmul_ge
      have hnext_ge_L1_int : (L + 1 : ℤ) ≤ Int.floor (α * (x i : ℝ)) :=
        le_trans source_step_7.2 hfloor_ge
      have hnext_ge_L1_int' : (L + 1 : ℤ) ≤ (x (i + 1) : ℤ) := by
        rw [hnext_eq_int]
        exact hnext_ge_L1_int
      have hnext_ge_L1 : L + 1 ≤ x (i + 1) := by exact_mod_cast hnext_ge_L1_int'
      have ht₁_pos : 0 < t₁ := by
        rcases ht₁_mem with ⟨j, hjN, hjlt, hxj⟩
        have hj1 : 1 ≤ j := le_trans hN₁_pos hjN
        have hposj : 0 < x j := hxpos j hj1
        omega
      have hαt_nonint : ∀ z : ℤ, α * (t₁ : ℝ) ≠ (z : ℝ) := by
        intro z hz
        have ht_ne_real : (t₁ : ℝ) ≠ 0 := by exact_mod_cast (ne_of_gt ht₁_pos)
        have hαeq : α = (z : ℝ) / (t₁ : ℝ) := by
          calc
            α = (α * (t₁ : ℝ)) / (t₁ : ℝ) := by field_simp [ht_ne_real]
            _ = (z : ℝ) / (t₁ : ℝ) := by rw [hz]
        let q : ℚ := (z : ℚ) / (t₁ : ℚ)
        have hqreal : (q : ℝ) = (z : ℝ) / (t₁ : ℝ) := by
          dsimp [q]
          norm_num
        have hαq : α = (q : ℝ) := by rw [hαeq, hqreal]
        exact hαirr.ne_rat q hαq
      have hfloor_αt_lt : (Int.floor (α * (t₁ : ℝ)) : ℝ) < α * (t₁ : ℝ) := by
        by_contra hnot
        have hle : α * (t₁ : ℝ) ≤ (Int.floor (α * (t₁ : ℝ)) : ℝ) := le_of_not_gt hnot
        have hge : (Int.floor (α * (t₁ : ℝ)) : ℝ) ≤ α * (t₁ : ℝ) := Int.floor_le _
        have heq : (Int.floor (α * (t₁ : ℝ)) : ℝ) = α * (t₁ : ℝ) := le_antisymm hge hle
        exact (hαt_nonint (Int.floor (α * (t₁ : ℝ)))) heq.symm
      have hfloor_lt : (Int.floor (α * (x i : ℝ)) : ℝ) < α * (t₁ : ℝ) := by
        by_cases hxeq : x i = t₁
        · have hxireal : (x i : ℝ) = (t₁ : ℝ) := by exact_mod_cast hxeq
          rw [hxireal]
          exact hfloor_αt_lt
        · have hxilt : x i < t₁ := lt_of_le_of_ne hxi_le_t hxeq
          have hxireal_lt : (x i : ℝ) < (t₁ : ℝ) := by exact_mod_cast hxilt
          have hαlt : α * (x i : ℝ) < α * (t₁ : ℝ) :=
            mul_lt_mul_of_pos_left hxireal_lt hαpos
          have hfloor_le := Int.floor_le (α * (x i : ℝ))
          linarith
      have hnext_lt : (x (i + 1) : ℝ) < α * (t₁ : ℝ) := by
        rw [hnext_eq_real]
        exact hfloor_lt
      dsimp [B]
      exact ⟨hnext_ge_L1, hnext_lt⟩
    · constructor
      · intro i hi hi_eq_a
        have hi_ge1 : 1 ≤ i := le_trans hN₁_pos hi
        have ha_le_L : a ≤ L := by
          have ha_ge_floor : (a : ℤ) ≤ Int.floor (α * (a : ℝ)) := by
            rw [Int.le_floor]
            have ha_nonneg : (0 : ℝ) ≤ (a : ℝ) := by positivity
            have hle : (a : ℝ) ≤ α * (a : ℝ) := by
              calc
                (a : ℝ) = 1 * (a : ℝ) := by ring
                _ ≤ α * (a : ℝ) := mul_le_mul_of_nonneg_right (le_of_lt hα) ha_nonneg
            simpa using hle
          have hltL1 : (a : ℤ) < (L + 1 : ℤ) :=
            lt_of_le_of_lt ha_ge_floor source_step_7.1
          have hleL_int : (a : ℤ) ≤ (L : ℤ) := by omega
          exact_mod_cast hleL_int
        have hx_le_L : x i ≤ L := by
          rw [hi_eq_a]
          exact ha_le_L
        have hrec_i := hrec i hi_ge1
        have hnext_eq_int : (x (i + 1) : ℤ) = Int.floor (α * (x i : ℝ)) := by
          simpa [if_pos hx_le_L] using hrec_i
        have hnext_lt_L1_int : (x (i + 1) : ℤ) < (L + 1 : ℤ) := by
          rw [hnext_eq_int]
          simpa [hi_eq_a] using source_step_7.1
        have hnext_le_L_int : (x (i + 1) : ℤ) ≤ (L : ℤ) := by omega
        have hnext_le_L : x (i + 1) ≤ L := by exact_mod_cast hnext_le_L_int
        have hmem := source_step_6 (i + 1) (by omega : N₁ ≤ i + 1)
        have hmem' : x (i + 1) ∈ A ∨ x (i + 1) ∈ B := by
          simpa [Set.mem_union] using hmem
        rcases hmem' with hA | hB
        · exact hA
        · dsimp [B] at hB
          exfalso
          omega
      · intro i hi hiB
        have hi_ge1 : 1 ≤ i := le_trans hN₁_pos hi
        have hiB' : L + 1 ≤ x i ∧ (x i : ℝ) < α * (t₁ : ℝ) := by
          simpa [B] using hiB
        have hxi_gt_L : L < x i := by omega
        have hnot : ¬ x i ≤ L := by omega
        have hrec_i := hrec i hi_ge1
        have hnext_eq_int : (x (i + 1) : ℤ) = Int.floor ((x i : ℝ) / α) := by
          simpa [hnot] using hrec_i
        have ha_int : (a : ℤ) = Int.floor (((L : ℝ) + 1) / α) := by
          have hL1_nonneg : (0 : ℝ) ≤ (L : ℝ) + 1 := by positivity
          have hq_nonneg : (0 : ℝ) ≤ ((L : ℝ) + 1) / α :=
            div_nonneg hL1_nonneg (le_of_lt hαpos)
          have hfloor_nonneg : (0 : ℤ) ≤ Int.floor (((L : ℝ) + 1) / α) := by
            rw [Int.le_floor]
            simpa using hq_nonneg
          dsimp [a]
          exact Int.toNat_of_nonneg hfloor_nonneg
        have hlow_floor : (a : ℤ) ≤ Int.floor ((x i : ℝ) / α) := by
          rw [ha_int]
          apply Int.floor_mono
          have hLi_nat : ((L + 1 : ℕ) : ℝ) ≤ (x i : ℝ) := by exact_mod_cast hiB'.1
          have hLi : ((L : ℝ) + 1) ≤ (x i : ℝ) := by simpa using hLi_nat
          exact div_le_div_of_nonneg_right hLi (le_of_lt hαpos)
        have hlow_int : (a : ℤ) ≤ (x (i + 1) : ℤ) := by
          rw [hnext_eq_int]
          exact hlow_floor
        have hlow : a ≤ x (i + 1) := by exact_mod_cast hlow_int
        have hdiv_lt_t : (x i : ℝ) / α < (t₁ : ℝ) := by
          rw [div_lt_iff₀ hαpos]
          calc
            (x i : ℝ) < α * (t₁ : ℝ) := hiB'.2
            _ = (t₁ : ℝ) * α := by ring
        have hfloor_lt_t_int : Int.floor ((x i : ℝ) / α) < (t₁ : ℤ) := by
          rw [Int.floor_lt]
          simpa using hdiv_lt_t
        have hnext_lt_t_int : (x (i + 1) : ℤ) < (t₁ : ℤ) := by
          rw [hnext_eq_int]
          exact hfloor_lt_t_int
        have hnext_lt_t : x (i + 1) < t₁ := by exact_mod_cast hnext_lt_t_int
        constructor
        · dsimp [A]
          exact ⟨hlow, le_of_lt hnext_lt_t⟩
        · exact hnext_lt_t
  have source_step_9 :
      (∀ i : ℕ, N₁ < i → i ≤ N₁ + p₁ → x i = t₁ → x (i - 1) = a) ∧
      (∀ i : ℕ, N₁ ≤ i → i < N₁ + p₁ → x i = a → x (i + 1) = t₁) := by
    have hfirst : ∀ i : ℕ, N₁ < i → i ≤ N₁ + p₁ → x i = t₁ → x (i - 1) = a := by
      intro i hi_gt hi_le hxi_t
      let j : ℕ := i - 1
      have hj_ge : N₁ ≤ j := by dsimp [j]; omega
      have hsucc : j + 1 = i := by dsimp [j]; omega
      have hxjsucc : x (j + 1) = t₁ := by
        rw [hsucc]
        exact hxi_t
      have hmem := source_step_6 j hj_ge
      have hmem' : x j ∈ A ∨ x j ∈ B := by simpa [Set.mem_union] using hmem
      rcases hmem' with hA | hB
      · have hA' : a ≤ x j ∧ x j ≤ t₁ := by simpa [A] using hA
        by_cases hxj_eq : x j = a
        · simpa [j] using hxj_eq
        · have hxj_gt_a : a < x j := lt_of_le_of_ne hA'.1 (Ne.symm hxj_eq)
          have hBsucc : x (j + 1) ∈ B := source_step_8.1 j hj_ge hA hxj_gt_a
          rw [hxjsucc] at hBsucc
          have hBsucc' : L + 1 ≤ t₁ ∧ (t₁ : ℝ) < α * (t₁ : ℝ) := by
            simpa [B] using hBsucc
          have hL1 : L + 1 ≤ t₁ := hBsucc'.1
          omega
      · have hstep := source_step_8.2.2 j hj_ge hB
        have hlt : x (j + 1) < t₁ := hstep.2
        rw [hxjsucc] at hlt
        exact (lt_irrefl t₁ hlt).elim
    constructor
    · exact hfirst
    · intro i hiN hiLt hxi_a
      have hprev_exists : ∃ r : ℕ, 1 ≤ r ∧ x r = a ∧ x (r + 1) = t₁ := by
        rcases ht₁_mem with ⟨j, hjN, hjlt, hxj⟩
        by_cases hcase : N₁ < j
        · let r : ℕ := j - 1
          have hr_ge1 : 1 ≤ r := by dsimp [r]; omega
          have hra : x r = a := by
            have hcall := hfirst j hcase (by omega) hxj
            simpa [r] using hcall
          have hrs : x (r + 1) = t₁ := by
            have h_eq : r + 1 = j := by dsimp [r]; omega
            rw [h_eq]
            exact hxj
          exact ⟨r, hr_ge1, hra, hrs⟩
        · have hj_eq : j = N₁ := by omega
          let i0 : ℕ := N₁ + p₁
          have hi0_gt : N₁ < i0 := by dsimp [i0]; omega
          have hi0_le : i0 ≤ N₁ + p₁ := by dsimp [i0]; omega
          have hx_i0 : x i0 = t₁ := by
            dsimp [i0]
            calc
              x (N₁ + p₁) = x N₁ := hper₁ N₁ (le_refl N₁)
              _ = x j := by rw [← hj_eq]
              _ = t₁ := hxj
          let r : ℕ := i0 - 1
          have hr_ge1 : 1 ≤ r := by dsimp [r]; omega
          have hra : x r = a := by
            have hcall := hfirst i0 hi0_gt hi0_le hx_i0
            simpa [r] using hcall
          have hrs : x (r + 1) = t₁ := by
            have h_eq : r + 1 = i0 := by dsimp [r]; omega
            rw [h_eq]
            exact hx_i0
          exact ⟨r, hr_ge1, hra, hrs⟩
      rcases hprev_exists with ⟨r, hr_ge1, hra, hrs⟩
      have hi1 : 1 ≤ i := le_trans hN₁_pos hiN
      have h_int_eq : (x (i + 1) : ℤ) = (x (r + 1) : ℤ) := by
        calc
          (x (i + 1) : ℤ)
              = (if x i ≤ L then Int.floor (α * (x i : ℝ))
                 else Int.floor ((x i : ℝ) / α)) := hrec i hi1
          _ = (if x r ≤ L then Int.floor (α * (x r : ℝ))
                 else Int.floor ((x r : ℝ) / α)) := by
                 rw [hxi_a, hra]
          _ = (x (r + 1) : ℤ) := (hrec r hr_ge1).symm
      have h_nat_eq : x (i + 1) = x (r + 1) := by exact_mod_cast h_int_eq
      rw [h_nat_eq]
      exact hrs
  have source_step_10 :
      t₁ = a →
        (∀ n : ℕ, N₁ ≤ n → x (n + 1) = x n) ∧ Odd 1 := by
    intro hta
    have hA_eq : ∀ u : ℕ, u ∈ A → u = a := by
      intro u hu
      dsimp [A] at hu
      have hua : u ≤ a := by simpa [hta] using hu.2
      omega
    have hx_eq_a : ∀ n : ℕ, N₁ ≤ n → x n = a := by
      intro n hn
      have hmem := source_step_6 n hn
      have hmem' : x n ∈ A ∨ x n ∈ B := by
        simpa [Set.mem_union] using hmem
      rcases hmem' with hA | hB
      · exact hA_eq (x n) hA
      · have hstep := source_step_8.2.2 n hn hB
        have hnextA : x (n + 1) ∈ A := hstep.1
        have hnext_lt : x (n + 1) < t₁ := hstep.2
        have hnext_eq : x (n + 1) = a := hA_eq (x (n + 1)) hnextA
        have hcontr : False := by
          have hlt_a : x (n + 1) < a := by simpa [hta] using hnext_lt
          omega
        exact False.elim hcontr
    constructor
    · intro n hn
      have hxn : x n = a := hx_eq_a n hn
      have hstepA : x (n + 1) ∈ A := source_step_8.2.1 n hn hxn
      have hnext_eq : x (n + 1) = a := hA_eq (x (n + 1)) hstepA
      rw [hnext_eq, hxn]
    · exact ⟨0, by norm_num⟩
  have source_step_11 :
      t₁ > a →
        ∃ i j : ℕ, N₁ ≤ i ∧ i < j ∧ j - i ≤ p₁ ∧
          x i = t₁ ∧ x j = t₁ ∧
          (∀ k : ℕ, i < k → k < j → x k ≠ t₁) := by
    intro ht
    obtain ⟨i, hiN, hi_lt, hxi⟩ := ht₁_mem
    let P : ℕ → Prop := fun d => 0 < d ∧ d ≤ p₁ ∧ x (i + d) = t₁
    have hexP : ∃ d, P d := by
      refine ⟨p₁, hp₁_pos, le_rfl, ?_⟩
      have hper := hper₁ i hiN
      rw [hper, hxi]
    let d : ℕ := Nat.find hexP
    have hdspec : P d := by
      dsimp [d]
      have h := Nat.find_spec hexP
      simpa [P] using h
    have hdpos : 0 < d := hdspec.1
    have hdle : d ≤ p₁ := hdspec.2.1
    have hxd : x (i + d) = t₁ := hdspec.2.2
    refine ⟨i, i + d, hiN, ?_, ?_, hxi, hxd, ?_⟩
    · omega
    · omega
    · intro k hik hkj hxk
      have hkpos : 0 < k - i := by omega
      have hklt : k - i < d := by omega
      have hkle : k - i ≤ p₁ := by omega
      have hk_eq : i + (k - i) = k := by omega
      have hPk : P (k - i) := by
        refine ⟨hkpos, hkle, ?_⟩
        rw [hk_eq]
        exact hxk
      have hmin : d ≤ k - i := by
        dsimp [d]
        exact Nat.find_min' hexP hPk
      omega
  have source_step_12 :
      t₁ > a →
      (∀ i j : ℕ, N₁ ≤ i → i < j → j - i ≤ p₁ →
        x i = t₁ → x j = t₁ →
        (∀ k : ℕ, i < k → k < j → x k ≠ t₁) →
        (∀ k : ℕ, i < k → k < j →
          (((k - i) % 2 = 1 → x k ∈ B) ∧
           ((k - i) % 2 = 0 → x k ∈ A ∧ x k ≠ t₁))) ∧
        x (j - 1) = a) := by
    intro ht
    have h_a_to_t : ∀ p : ℕ, N₁ ≤ p → x p = a → x (p + 1) = t₁ := by
      intro p hp hpa
      have hprev_exists : ∃ r : ℕ, 1 ≤ r ∧ x r = a ∧ x (r + 1) = t₁ := by
        rcases ht₁_mem with ⟨j, hjN, hjlt, hxj⟩
        by_cases hcase : N₁ < j
        · let r : ℕ := j - 1
          have hr_ge1 : 1 ≤ r := by dsimp [r]; omega
          have hra : x r = a := by
            have hcall := source_step_9.1 j hcase (by omega) hxj
            simpa [r] using hcall
          have hrs : x (r + 1) = t₁ := by
            have h_eq : r + 1 = j := by dsimp [r]; omega
            rw [h_eq]
            exact hxj
          exact ⟨r, hr_ge1, hra, hrs⟩
        · have hj_eq : j = N₁ := by omega
          let i0 : ℕ := N₁ + p₁
          have hi0_gt : N₁ < i0 := by dsimp [i0]; omega
          have hi0_le : i0 ≤ N₁ + p₁ := by dsimp [i0]; omega
          have hx_i0 : x i0 = t₁ := by
            dsimp [i0]
            calc
              x (N₁ + p₁) = x N₁ := hper₁ N₁ (le_refl N₁)
              _ = x j := by rw [← hj_eq]
              _ = t₁ := hxj
          let r : ℕ := i0 - 1
          have hr_ge1 : 1 ≤ r := by dsimp [r]; omega
          have hra : x r = a := by
            have hcall := source_step_9.1 i0 hi0_gt hi0_le hx_i0
            simpa [r] using hcall
          have hrs : x (r + 1) = t₁ := by
            have h_eq : r + 1 = i0 := by dsimp [r]; omega
            rw [h_eq]
            exact hx_i0
          exact ⟨r, hr_ge1, hra, hrs⟩
      rcases hprev_exists with ⟨r, hr_ge1, hra, hrs⟩
      have hp1 : 1 ≤ p := le_trans hN₁_pos hp
      have h_int_eq : (x (p + 1) : ℤ) = (x (r + 1) : ℤ) := by
        calc
          (x (p + 1) : ℤ)
              = (if x p ≤ L then Int.floor (α * (x p : ℝ))
                 else Int.floor ((x p : ℝ) / α)) := hrec p hp1
          _ = (if x r ≤ L then Int.floor (α * (x r : ℝ))
                 else Int.floor ((x r : ℝ) / α)) := by
                 rw [hpa, hra]
          _ = (x (r + 1) : ℤ) := (hrec r hr_ge1).symm
      have h_nat_eq : x (p + 1) = x (r + 1) := by exact_mod_cast h_int_eq
      rw [h_nat_eq]
      exact hrs
    intro i j hi hij hd hxi hxj hno
    have hprop :
        ∀ k : ℕ, i < k → k < j →
          (((k - i) % 2 = 1 → x k ∈ B) ∧
           ((k - i) % 2 = 0 → x k ∈ A ∧ x k ≠ t₁)) := by
      intro k
      induction k using Nat.strong_induction_on with
      | h k ih =>
          intro hik hkj
          by_cases hbase : k = i + 1
          · subst k
            constructor
            · intro hodd
              have hxiA : x i ∈ A := by
                dsimp [A]
                constructor
                · rw [hxi]
                  exact le_of_lt ht
                · rw [hxi]
              have hgt : a < x i := by
                rw [hxi]
                exact ht
              exact source_step_8.1 i hi hxiA hgt
            · intro hzero
              exfalso
              have hpar : ((i + 1 - i) % 2) = 1 := by omega
              omega
          · have hk_gt : i + 1 < k := by omega
            let p : ℕ := k - 1
            have hp_lt : p < k := by dsimp [p]; omega
            have hpi : i < p := by dsimp [p]; omega
            have hpj : p < j := by dsimp [p]; omega
            have ihp := ih p hp_lt hpi hpj
            have hpk : p + 1 = k := by dsimp [p]; omega
            have hNp : N₁ ≤ p := le_trans hi (le_of_lt hpi)
            by_cases hodd : (p - i) % 2 = 1
            · have hpB : x p ∈ B := ihp.1 hodd
              have hstep := source_step_8.2.2 p hNp hpB
              have hnextA : x (p + 1) ∈ A := hstep.1
              have hnext_lt : x (p + 1) < t₁ := hstep.2
              have hnext_ne : x (p + 1) ≠ t₁ := by omega
              rw [← hpk]
              constructor
              · intro hkodd
                exfalso
                have hkeven : ((p + 1 - i) % 2) = 0 := by omega
                omega
              · intro hkeven
                exact ⟨hnextA, hnext_ne⟩
            · have hltmod : (p - i) % 2 < 2 := Nat.mod_lt _ (by norm_num)
              have heven : (p - i) % 2 = 0 := by omega
              have hpA : x p ∈ A := (ihp.2 heven).1
              have hp_ne_t : x p ≠ t₁ := (ihp.2 heven).2
              have hpA' : a ≤ x p ∧ x p ≤ t₁ := by simpa [A] using hpA
              have hgt : a < x p := by
                by_contra hnot
                have hle : x p ≤ a := by omega
                have hxa : x p = a := le_antisymm hle hpA'.1
                have hnext_t : x (p + 1) = t₁ := h_a_to_t p hNp hxa
                have hikp : i < p + 1 := by omega
                have hkpj : p + 1 < j := by omega
                have hcontra : x (p + 1) ≠ t₁ := hno (p + 1) hikp hkpj
                exact hcontra hnext_t
              have hnextB : x (p + 1) ∈ B := source_step_8.1 p hNp hpA hgt
              rw [← hpk]
              constructor
              · intro hkodd
                exact hnextB
              · intro hkeven
                exfalso
                have hkodd : ((p + 1 - i) % 2) = 1 := by omega
                omega
    constructor
    · exact hprop
    · have hNprev : N₁ ≤ j - 1 := by omega
      have hmem := source_step_6 (j - 1) hNprev
      have hmem' : x (j - 1) ∈ A ∨ x (j - 1) ∈ B := by simpa [Set.mem_union] using hmem
      rcases hmem' with hA | hB
      · have hA' : a ≤ x (j - 1) ∧ x (j - 1) ≤ t₁ := by simpa [A] using hA
        by_cases hja : x (j - 1) = a
        · exact hja
        · exfalso
          have hgt : a < x (j - 1) := lt_of_le_of_ne hA'.1 (Ne.symm hja)
          have hstep := source_step_8.1 (j - 1) hNprev hA hgt
          have hxjB : x j ∈ B := by
            have h_eq : (j - 1) + 1 = j := by omega
            simpa [h_eq] using hstep
          have hxjB' : L + 1 ≤ x j ∧ (x j : ℝ) < α * (t₁ : ℝ) := by
            simpa [B] using hxjB
          have hL1_le : L + 1 ≤ x j := hxjB'.1
          rw [hxj] at hL1_le
          omega
      · have hstep := source_step_8.2.2 (j - 1) hNprev hB
        have hlt : x j < t₁ := by
          have h_eq : (j - 1) + 1 = j := by omega
          simpa [h_eq] using hstep.2
        rw [hxj] at hlt
        omega
  have source_step_13 :
      t₁ > a →
      (∀ i j : ℕ, N₁ ≤ i → i < j → j - i ≤ p₁ →
        x i = t₁ → x j = t₁ →
        (∀ k : ℕ, i < k → k < j → x k ≠ t₁) →
        x (j - 1) = a →
        Even (j - 1 - i) ∧ Odd (j - i)) := by
    intro ht i j hi hij hd hxi hxj hno hprev
    have hparity := (source_step_12 ht i j hi hij hd hxi hxj hno).1
    have hj1_gt_i : i < j - 1 := by
      by_contra hnot
      have h_eq : j - 1 = i := by omega
      have hae : a = t₁ := by
        calc
          a = x (j - 1) := hprev.symm
          _ = x i := by rw [h_eq]
          _ = t₁ := hxi
      omega
    have hj1_lt_j : j - 1 < j := by omega
    have hmod : (j - 1 - i) % 2 = 0 := by
      by_contra hne
      have hmod1 : (j - 1 - i) % 2 = 1 := by
        have hlt := Nat.mod_lt (j - 1 - i) (by norm_num : 0 < 2)
        omega
      have hB : x (j - 1) ∈ B := (hparity (j - 1) hj1_gt_i hj1_lt_j).1 hmod1
      have hB' : L + 1 ≤ x (j - 1) ∧ (x (j - 1) : ℝ) < α * (t₁ : ℝ) := by
        simpa [B] using hB
      have hL1a : L + 1 ≤ a := by
        rw [hprev] at hB'
        exact hB'.1
      have ha_le_L : a ≤ L := by
        have hαpos : (0 : ℝ) < α := lt_trans zero_lt_one hα
        have ha_floor_ge : (a : ℤ) ≤ Int.floor (α * (a : ℝ)) := by
          rw [Int.le_floor]
          have ha_nonneg : (0 : ℝ) ≤ (a : ℝ) := by positivity
          have hle : (a : ℝ) ≤ α * (a : ℝ) := by
            calc
              (a : ℝ) = 1 * (a : ℝ) := by ring
              _ ≤ α * (a : ℝ) := mul_le_mul_of_nonneg_right (le_of_lt hα) ha_nonneg
          simpa using hle
        have hltL1 : (a : ℤ) < (L + 1 : ℤ) :=
          lt_of_le_of_lt ha_floor_ge source_step_7.1
        have hleL_int : (a : ℤ) ≤ (L : ℤ) := by omega
        exact_mod_cast hleL_int
      omega
    have hoddmod : (j - i) % 2 = 1 := by
      have hji : j - i = (j - 1 - i) + 1 := by omega
      rw [hji, Nat.add_mod, hmod]
    constructor
    · rw [Nat.even_iff]
      exact hmod
    · rw [Nat.odd_iff]
      exact hoddmod
  have source_step_14 :
      t₁ > a →
      (∀ i j : ℕ, N₁ ≤ i → i < j → j - i ≤ p₁ →
        x i = t₁ → x j = t₁ →
        (∀ k : ℕ, i < k → k < j → x k ≠ t₁) →
        Odd (j - i) ∧
        (∀ q : ℕ, 0 < q →
          (∃ N : ℕ, ∀ n : ℕ, N ≤ n → x (n + q) = x n) → j - i ≤ q)) := by
    intro ht i j hi hij hdlen hxi hxj hno
    have hpar12 := source_step_12 ht i j hi hij hdlen hxi hxj hno
    have hprev : x (j - 1) = a := hpar12.2
    have hpar13 := source_step_13 ht i j hi hij hdlen hxi hxj hno hprev
    constructor
    · exact hpar13.2
    · intro q hqpos hq
      let d : ℕ := j - i
      have hdpos : 0 < d := by dsimp [d]; omega
      have hd_eq : i + d = j := by dsimp [d]; omega
      have hper_d : ∀ n : ℕ, x (i + d + n) = x (i + n) := by
        intro n
        induction n with
        | zero =>
            simp only [Nat.add_zero]
            rw [hd_eq, hxj, hxi]
        | succ n ih =>
            have hrec1 := hrec (i + n) (by omega)
            have hrec2 := hrec (i + d + n) (by omega)
            have hInt : (x (i + n + 1) : ℤ) = (x (i + d + n + 1) : ℤ) := by
              calc
                (x (i + n + 1) : ℤ)
                    = (if x (i + n) ≤ L then
                        Int.floor (α * (x (i + n) : ℝ))
                      else Int.floor ((x (i + n) : ℝ) / α)) := hrec1
                _ = (if x (i + d + n) ≤ L then
                        Int.floor (α * (x (i + d + n) : ℝ))
                      else Int.floor ((x (i + d + n) : ℝ) / α)) := by
                        rw [← ih]
                _ = (x (i + d + n + 1) : ℤ) := hrec2.symm
            have hNat : x (i + n + 1) = x (i + d + n + 1) := by
              exact_mod_cast hInt
            have harg1 : i + (n + 1) = i + n + 1 := by omega
            have harg2 : i + d + (n + 1) = i + d + n + 1 := by omega
            rw [harg1, harg2]
            exact hNat.symm
      have hper_mul : ∀ k n : ℕ, x (i + k * d + n) = x (i + n) := by
        intro k
        induction k with
        | zero =>
            intro n
            simp
        | succ k ihk =>
            intro n
            calc
              x (i + (k + 1) * d + n)
                  = x (i + d + (k * d + n)) := by
                      have hidx : i + (k + 1) * d + n = i + d + (k * d + n) := by
                        rw [Nat.succ_mul]
                        ac_rfl
                      rw [hidx]
              _ = x (i + (k * d + n)) := hper_d (k * d + n)
              _ = x (i + n) := by
                      simpa [Nat.add_assoc] using ihk n
      rcases hq with ⟨Nq, hNq⟩
      have hd_ge1 : 1 ≤ d := hdpos
      have hNq_le_mul : Nq ≤ Nq * d := by
        calc
          Nq = Nq * 1 := by rw [Nat.mul_one]
          _ ≤ Nq * d := Nat.mul_le_mul_left Nq hd_ge1
      have hi' : Nq ≤ i + Nq * d := by omega
      have hEvent := hNq (i + Nq * d) hi'
      have hper_q := hper_mul Nq q
      have hper_0 := hper_mul Nq 0
      have hxi'_t : x (i + Nq * d) = t₁ := by
        have h0 : x (i + Nq * d) = x i := by
          simpa using hper_0
        rw [h0, hxi]
      have hret : x (i + q) = t₁ := by
        calc
          x (i + q) = x (i + Nq * d + q) := hper_q.symm
          _ = x (i + Nq * d) := by
                simpa [Nat.add_assoc] using hEvent
          _ = t₁ := hxi'_t
      have hdq : d ≤ q := by
        by_contra hnot
        have hqlt : q < d := by omega
        have hiq_gt : i < i + q := by omega
        have hiq_lt_j : i + q < j := by
          have hd_eq' : i + d = j := hd_eq
          omega
        have hneq : x (i + q) ≠ t₁ := hno (i + q) hiq_gt hiq_lt_j
        exact hneq hret
      change d ≤ q
      exact hdq
  have source_step_15 :
      ∀ m : ℕ, ∃ i : ℕ, N₁ + m * p₁ ≤ i ∧ i < N₁ + (m + 1) * p₁ ∧ x i = a := by
    rcases ht₁_mem with ⟨j, hjN, hjlt, hxj⟩
    have hex_a : ∃ i0 : ℕ, N₁ ≤ i0 ∧ i0 < N₁ + p₁ ∧ x i0 = a := by
      by_cases hjN₁ : j = N₁
      · refine ⟨N₁ + p₁ - 1, ?_, ?_, ?_⟩
        · omega
        · omega
        · have hperN := hper₁ N₁ (le_refl N₁)
          have ht_at : x (N₁ + p₁) = t₁ := by
            calc
              x (N₁ + p₁) = x N₁ := hperN
              _ = x j := by rw [hjN₁]
              _ = t₁ := hxj
          have hgt : N₁ < N₁ + p₁ := by omega
          have hle : N₁ + p₁ ≤ N₁ + p₁ := le_rfl
          have hpred := source_step_9.1 (N₁ + p₁) hgt hle ht_at
          simpa using hpred
      · have hj_gt : N₁ < j := by omega
        refine ⟨j - 1, ?_, ?_, ?_⟩
        · omega
        · omega
        · have hle : j ≤ N₁ + p₁ := by omega
          have hpred := source_step_9.1 j hj_gt hle hxj
          simpa using hpred
    rcases hex_a with ⟨i0, hi0_ge, hi0_lt, hi0_a⟩
    intro m
    have hper_mul : x (i0 + m * p₁) = a := by
      induction m with
      | zero =>
          simpa using hi0_a
      | succ m ih =>
          have hstep := hper₁ (i0 + m * p₁) (by omega)
          calc
            x (i0 + (m + 1) * p₁) = x ((i0 + m * p₁) + p₁) := by
              congr 1
              rw [Nat.succ_mul]
              omega
            _ = x (i0 + m * p₁) := hstep
            _ = a := ih
    refine ⟨i0 + m * p₁, ?_, ?_, hper_mul⟩
    · exact Nat.add_le_add_right hi0_ge (m * p₁)
    · have hidx : N₁ + (m + 1) * p₁ = (N₁ + p₁) + m * p₁ := by
        rw [Nat.succ_mul]
        omega
      calc
        i0 + m * p₁ < (N₁ + p₁) + m * p₁ := Nat.add_lt_add_right hi0_lt (m * p₁)
        _ = N₁ + (m + 1) * p₁ := hidx.symm
  have source_step_16 :
      ∃ P : ℕ, Odd P ∧
        (∃ N : ℕ, ∀ n : ℕ, N ≤ n → x (n + P) = x n) ∧
        (∀ q : ℕ, 0 < q →
          (∃ N : ℕ, ∀ n : ℕ, N ≤ n → x (n + q) = x n) → P ≤ q) ∧
        (∀ y : ℕ → ℕ,
          (∀ n : ℕ, 1 ≤ n → 0 < y n) →
          (∀ n : ℕ, 1 ≤ n →
            (y (n + 1) : ℤ) =
              if y n ≤ L then Int.floor (α * (y n : ℝ))
              else Int.floor ((y n : ℝ) / α)) →
          y 1 = a →
          (∃ N : ℕ, ∀ n : ℕ, N ≤ n → y (n + P) = y n) ∧
          (∀ q : ℕ, 0 < q →
            (∃ N : ℕ, ∀ n : ℕ, N ≤ n → y (n + q) = y n) → P ≤ q)) := by
    classical
    obtain ⟨i0, hi0_ge0, hi0_lt0, hi0_a⟩ := source_step_15 0
    have hi0_ge : N₁ ≤ i0 := by simpa using hi0_ge0
    have hi0_lt : i0 < N₁ + p₁ := by simpa using hi0_lt0
    have ha_le_L : a ≤ L := by
      have hαa_lt : α * (a : ℝ) < (L : ℝ) + 1 := by
        have h := source_step_7.1
        rw [Int.floor_lt] at h
        simpa using h
      have hαa_gt : (a : ℝ) < α * (a : ℝ) := by
        have ha_pos_real : (0 : ℝ) < (a : ℝ) := by
          exact_mod_cast (lt_of_lt_of_le zero_lt_one source_step_0)
        have := mul_lt_mul_of_pos_right hα ha_pos_real
        simpa using this
      by_contra hnot
      have ha_ge : L + 1 ≤ a := by omega
      have ha_ge_real : (L : ℝ) + 1 ≤ (a : ℝ) := by exact_mod_cast ha_ge
      linarith
    have hshift : ∀ y : ℕ → ℕ,
        (∀ n : ℕ, 1 ≤ n → 0 < y n) →
        (∀ n : ℕ, 1 ≤ n →
          (y (n + 1) : ℤ) =
            if y n ≤ L then Int.floor (α * (y n : ℝ))
            else Int.floor ((y n : ℝ) / α)) →
        y 1 = a →
        ∀ n : ℕ, 1 ≤ n → y n = x (i0 + n - 1) := by
      intro y hypos hyrec hy1 n hn
      induction n, hn using Nat.le_induction with
      | base =>
          have hidx : i0 + 1 - 1 = i0 := by omega
          rw [hy1, ← hi0_a, hidx]
      | succ n hn ih =>
          have hcur : y n = x (i0 + n - 1) := ih
          have hn_ge1 : 1 ≤ n := hn
          have hyrecn := hyrec n hn_ge1
          have hxrecn := hrec (i0 + n - 1) (by omega)
          have hint : (y (n + 1) : ℤ) = (x (i0 + n) : ℤ) := by
            calc
              (y (n + 1) : ℤ) = (if y n ≤ L then Int.floor (α * (y n : ℝ)) else Int.floor ((y n : ℝ) / α)) := hyrecn
              _ = (if x (i0 + n - 1) ≤ L then Int.floor (α * (x (i0 + n - 1) : ℝ)) else Int.floor ((x (i0 + n - 1) : ℝ) / α)) := by rw [hcur]
              _ = (x ((i0 + n - 1) + 1) : ℤ) := (hxrecn).symm
              _ = (x (i0 + n) : ℤ) := by
                    have hidx : (i0 + n - 1) + 1 = i0 + n := by omega
                    exact congrArg (fun z : ℕ => (x z : ℤ)) hidx
          exact_mod_cast hint
    by_cases hta : t₁ = a
    · have hnext_i0 : x (i0 + 1) = a := by
        have h := source_step_9.2 i0 hi0_ge hi0_lt hi0_a
        simpa [hta] using h
      have hif : x i0 ≤ L := by rw [hi0_a]; exact ha_le_L
      have hfloor_eq_int : (a : ℤ) = Int.floor (α * (a : ℝ)) := by
        have h := hrec i0 (le_trans hN₁_pos hi0_ge)
        rw [hnext_i0, if_pos hif, hi0_a] at h
        exact h
      refine ⟨1, ⟨0, by norm_num⟩, ?_, ?_, ?_⟩
      · refine ⟨N₁, ?_⟩
        intro n hn
        exact (source_step_10 hta).1 n hn
      · intro q hqpos hqper
        omega
      · intro y hypos hyrec hy1
        have hy_const : ∀ n : ℕ, 1 ≤ n → y n = a := by
          intro n hn
          induction n, hn using Nat.le_induction with
          | base => exact hy1
          | succ n hn ih =>
              have hyn_le_L : y n ≤ L := by rw [ih]; exact ha_le_L
              have hrecn := hyrec n hn
              have hint : (y (n + 1) : ℤ) = (a : ℤ) := by
                calc
                  (y (n + 1) : ℤ) = (if y n ≤ L then Int.floor (α * (y n : ℝ)) else Int.floor ((y n : ℝ) / α)) := hrecn
                  _ = Int.floor (α * (a : ℝ)) := by rw [if_pos hyn_le_L, ih]
                  _ = (a : ℤ) := hfloor_eq_int.symm
              exact_mod_cast hint
        constructor
        · refine ⟨1, ?_⟩
          intro n hn
          have hn1 : 1 ≤ n := hn
          have hn1' : 1 ≤ n + 1 := by omega
          rw [hy_const (n + 1) hn1', hy_const n hn1]
        · intro q hqpos hqper
          omega
    · have ht_ge : a ≤ t₁ := by
        have hleL : x i0 ≤ L := by rw [hi0_a]; exact ha_le_L
        have h := ht₁_max i0 hi0_ge hi0_lt hleL
        simpa [hi0_a] using h
      have ht : a < t₁ := lt_of_le_of_ne ht_ge (Ne.symm hta)
      obtain ⟨i, j, hi_ge, hij, hd_le, hxi, hxj, hno⟩ := source_step_11 ht
      let d : ℕ := j - i
      have hd_pos : 0 < d := by dsimp [d]; omega
      have hd_eq : i + d = j := by dsimp [d]; omega
      have hpar := source_step_14 ht i j hi_ge hij hd_le hxi hxj hno
      have hxper_d : ∀ n : ℕ, x (i + d + n) = x (i + n) := by
        intro n
        induction n with
        | zero =>
            simp only [Nat.add_zero]
            rw [hd_eq, hxj, hxi]
        | succ n ih =>
            have hrec1 := hrec (i + n) (by omega)
            have hrec2 := hrec (i + d + n) (by omega)
            have hInt : (x (i + n + 1) : ℤ) = (x (i + d + n + 1) : ℤ) := by
              calc
                (x (i + n + 1) : ℤ) = (if x (i + n) ≤ L then Int.floor (α * (x (i + n) : ℝ)) else Int.floor ((x (i + n) : ℝ) / α)) := hrec1
                _ = (if x (i + d + n) ≤ L then Int.floor (α * (x (i + d + n) : ℝ)) else Int.floor ((x (i + d + n) : ℝ) / α)) := by rw [ih]
                _ = (x (i + d + n + 1) : ℤ) := (hrec2).symm
            have hNat : x (i + n + 1) = x (i + d + n + 1) := by exact_mod_cast hInt
            have harg1 : i + (n + 1) = i + n + 1 := by omega
            have harg2 : i + d + (n + 1) = i + d + n + 1 := by omega
            rw [harg1, harg2]
            exact hNat.symm
      have hxper_ev : ∀ n : ℕ, i ≤ n → x (n + d) = x n := by
        intro n hn
        calc
          x (n + d) = x (i + d + (n - i)) := by congr 1; omega
          _ = x (i + (n - i)) := hxper_d (n - i)
          _ = x n := by congr 1; omega
      refine ⟨d, ?_, ?_, ?_, ?_⟩
      · simpa [d] using hpar.1
      · refine ⟨i, ?_⟩
        intro n hn
        exact hxper_ev n hn
      · intro q hqpos hqper
        have hmin := hpar.2 q hqpos hqper
        simpa [d] using hmin
      · intro y hypos hyrec hy1
        have hy_shift := hshift y hypos hyrec hy1
        constructor
        · refine ⟨i + i0 + 1, ?_⟩
          intro n hn
          have hn1 : 1 ≤ n := by omega
          have hnd1 : 1 ≤ n + d := by omega
          have hyn := hy_shift n hn1
          have hynd := hy_shift (n + d) hnd1
          have hm_ge : i ≤ i0 + n - 1 := by omega
          have hxper := hxper_ev (i0 + n - 1) hm_ge
          calc
            y (n + d) = x (i0 + (n + d) - 1) := hynd
            _ = x ((i0 + n - 1) + d) := by congr 1; omega
            _ = x (i0 + n - 1) := hxper
            _ = y n := hyn.symm
        · intro q hqpos hqperY
          obtain ⟨Ny, hNy⟩ := hqperY
          have hqperX : ∃ N : ℕ, ∀ n : ℕ, N ≤ n → x (n + q) = x n := by
            refine ⟨i0 + Ny, ?_⟩
            intro M hM
            let n : ℕ := M - i0 + 1
            have hn_ge : Ny ≤ n := by dsimp [n]; omega
            have hn1 : 1 ≤ n := by dsimp [n]; omega
            have hshift_n := hy_shift n hn1
            have hshift_nq := hy_shift (n + q) (by omega)
            have hyperiod := hNy n hn_ge
            calc
              x (M + q) = y (n + q) := by
                rw [hshift_nq]
                congr 1
                dsimp [n]
                omega
              _ = y n := hyperiod
              _ = x M := by
                rw [hshift_n]
                congr 1
                dsimp [n]
                omega
          have hmin := hpar.2 q hqpos hqperX
          simpa [d] using hmin
  have source_step_17 :
      ∃ P : ℕ, Odd P ∧
        (∃ N : ℕ, ∀ n : ℕ, N ≤ n → x (n + P) = x n) ∧
        (∀ q : ℕ, 0 < q →
          (∃ N : ℕ, ∀ n : ℕ, N ≤ n → x (n + q) = x n) → P ≤ q) ∧
        (∀ y : ℕ → ℕ,
          (∀ n : ℕ, 1 ≤ n → 0 < y n) →
          y 1 > L →
          (∀ n : ℕ, 1 ≤ n →
            (y (n + 1) : ℤ) =
              if y n ≤ L then Int.floor (α * (y n : ℝ))
              else Int.floor ((y n : ℝ) / α)) →
          (∃ N : ℕ, ∀ n : ℕ, N ≤ n → y (n + P) = y n) ∧
          (∀ q : ℕ, 0 < q →
            (∃ N : ℕ, ∀ n : ℕ, N ≤ n → y (n + q) = y n) → P ≤ q)) := by
    classical
    obtain ⟨P, hPodd, hxper, hxmin, hy_from_a⟩ := source_step_16
    refine ⟨P, hPodd, hxper, hxmin, ?_⟩
    intro y hypos hy1 hyrec
    have hαpos : (0 : ℝ) < α := lt_trans zero_lt_one hα
    have ha_int : (a : ℤ) = Int.floor (((L : ℝ) + 1) / α) := by
      have hL1_nonneg : 0 ≤ (L : ℝ) + 1 := by positivity
      have hq_nonneg : 0 ≤ ((L : ℝ) + 1) / α :=
        div_nonneg hL1_nonneg (le_of_lt hαpos)
      have hfloor_nonneg : 0 ≤ Int.floor (((L : ℝ) + 1) / α) := by
        rw [Int.le_floor]
        simpa using hq_nonneg
      dsimp [a]
      exact Int.toNat_of_nonneg hfloor_nonneg
    have hy_le_exists : ∃ N : ℕ, 1 ≤ N ∧ y N ≤ L := by
      by_contra hnone
      have hgt : ∀ n : ℕ, 1 ≤ n → L < y n := by
        intro n hn
        have hnot : ¬ y n ≤ L := by
          intro hle
          exact hnone ⟨n, hn, hle⟩
        omega
      have hdec : ∀ n : ℕ, 1 ≤ n → y (n + 1) < y n := by
        intro n hn
        have hyn_gt : L < y n := hgt n hn
        have hnot : ¬ y n ≤ L := by omega
        have hrecn := hyrec n hn
        simp [hnot] at hrecn
        have hposn : (0 : ℝ) < (y n : ℝ) := by exact_mod_cast hypos n hn
        have hlt_real : ((y n : ℝ) / α) < (y n : ℝ) := by
          rw [div_lt_iff₀ hαpos]
          have hmul : (y n : ℝ) * 1 < (y n : ℝ) * α :=
            mul_lt_mul_of_pos_left hα hposn
          simpa using hmul
        have hfloor_lt : Int.floor ((y n : ℝ) / α) < (y n : ℤ) := by
          rw [Int.floor_lt]
          simpa using hlt_real
        have hlt_int : (y (n + 1) : ℤ) < (y n : ℤ) := by
          rw [hrecn]
          exact hfloor_lt
        exact_mod_cast hlt_int
      have hbound : ∀ k : ℕ, y (1 + k) + k ≤ y 1 := by
        intro k
        induction k with
        | zero => simp
        | succ k ih =>
            have hstep := hdec (1 + k) (by omega)
            have hstep' : y (1 + (k + 1)) < y (1 + k) := by
              simpa [Nat.add_assoc] using hstep
            omega
      have hbound0 := hbound (y 1)
      have hzero : y (1 + y 1) = 0 := by omega
      have hpos : 0 < y (1 + y 1) := hypos (1 + y 1) (by omega)
      omega
    let Q : ℕ → Prop := fun n => 1 ≤ n ∧ y n ≤ L
    have hQex : ∃ n, Q n := by
      obtain ⟨N, hN, hyle⟩ := hy_le_exists
      exact ⟨N, hN, hyle⟩
    let N0 : ℕ := Nat.find hQex
    have hN0spec : 1 ≤ N0 ∧ y N0 ≤ L := by
      dsimp [N0]
      simpa [Q] using Nat.find_spec hQex
    have hN0_le_of_Q : ∀ m, Q m → N0 ≤ m := by
      intro m hm
      dsimp [N0]
      exact Nat.find_min' hQex hm
    have hN0_first : ∀ m : ℕ, 1 ≤ m → m < N0 → L < y m := by
      intro m hm hmlt
      by_contra hnot_gt
      have hmQ : Q m := by
        dsimp [Q]
        constructor
        · exact hm
        · omega
      have hNm := hN0_le_of_Q m hmQ
      omega
    have hN0_ne_one : N0 ≠ 1 := by
      intro h
      have : y 1 ≤ L := by simpa [h] using hN0spec.2
      omega
    have hN0_ge2 : 2 ≤ N0 := by omega
    have hprev_ge1 : 1 ≤ N0 - 1 := by omega
    have hprev_lt : N0 - 1 < N0 := by omega
    have hprev_gt : L < y (N0 - 1) := hN0_first (N0 - 1) hprev_ge1 hprev_lt
    have hprev_not_le : ¬ y (N0 - 1) ≤ L := by omega
    have hprev_rec := hyrec (N0 - 1) hprev_ge1
    have hN_eq : N0 - 1 + 1 = N0 := by omega
    have hN0_rec : (y N0 : ℤ) = Int.floor ((y (N0 - 1) : ℝ) / α) := by
      simpa [hN_eq, hprev_not_le] using hprev_rec
    have hprev_ge_L1 : L + 1 ≤ y (N0 - 1) := by omega
    have hprev_ge_real : ((L : ℝ) + 1) ≤ (y (N0 - 1) : ℝ) := by exact_mod_cast hprev_ge_L1
    have hdiv_ge : (((L : ℝ) + 1) / α) ≤ (y (N0 - 1) : ℝ) / α := by
      exact div_le_div_of_nonneg_right hprev_ge_real (le_of_lt hαpos)
    have hfloor_ge : (a : ℤ) ≤ Int.floor ((y (N0 - 1) : ℝ) / α) := by
      rw [ha_int]
      exact Int.floor_mono hdiv_ge
    have hlow_int : (a : ℤ) ≤ (y N0 : ℤ) := by
      rw [hN0_rec]
      exact hfloor_ge
    have hN0_low : a ≤ y N0 := by exact_mod_cast hlow_int
    have hN0_le : y N0 ≤ L := hN0spec.2
    have hit_a_aux :
        ∀ d n : ℕ, y n - a = d → 1 ≤ n → a ≤ y n → y n ≤ L →
          ∃ k : ℕ, y (n + 2 * k) = a := by
      intro d
      induction d using Nat.strong_induction_on with
      | h d ih =>
        intro n hd hn hage hale
        by_cases hna : y n = a
        · exact ⟨0, by simpa using hna⟩
        · have hgt : a < y n := lt_of_le_of_ne hage (Ne.symm hna)
          have hnA_ge_a1 : a + 1 ≤ y n := by omega
          have hrecn := hyrec n hn
          have hnext_eq : (y (n + 1) : ℤ) = Int.floor (α * (y n : ℝ)) := by
            simpa [hale] using hrecn
          have hnext_ge_L1_int : (L + 1 : ℤ) ≤ Int.floor (α * (y n : ℝ)) := by
            have h1 : (((a + 1 : ℕ) : ℝ) ≤ (y n : ℝ)) := by exact_mod_cast hnA_ge_a1
            have hmul : α * (((a + 1 : ℕ) : ℝ)) ≤ α * (y n : ℝ) :=
              mul_le_mul_of_nonneg_left h1 (le_of_lt hαpos)
            exact le_trans source_step_7.2 (Int.floor_mono hmul)
          have hnext_ge_L1_int' : (L + 1 : ℤ) ≤ (y (n + 1) : ℤ) := by
            rw [hnext_eq]
            exact hnext_ge_L1_int
          have hnext_gtL : L < y (n + 1) := by
            have : L + 1 ≤ y (n + 1) := by exact_mod_cast hnext_ge_L1_int'
            omega
          have hn1_ge1 : 1 ≤ n + 1 := by omega
          have hnot_next_le : ¬ y (n + 1) ≤ L := by omega
          have hrecnext := hyrec (n + 1) hn1_ge1
          have hnext2_eq : (y (n + 2) : ℤ) = Int.floor ((y (n + 1) : ℝ) / α) := by
            have hidx : (n + 1) + 1 = n + 2 := by omega
            simpa [hidx, hnot_next_le] using hrecnext
          have hnext2_low_int : (a : ℤ) ≤ Int.floor ((y (n + 1) : ℝ) / α) := by
            have hL1_le : ((L : ℝ) + 1) ≤ (y (n + 1) : ℝ) := by
              exact_mod_cast (by omega : L + 1 ≤ y (n + 1))
            have hdiv_ge2 : (((L : ℝ) + 1) / α) ≤ (y (n + 1) : ℝ) / α :=
              div_le_div_of_nonneg_right hL1_le (le_of_lt hαpos)
            rw [ha_int]
            exact Int.floor_mono hdiv_ge2
          have hnext2_low : a ≤ y (n + 2) := by
            have hlow_int2 : (a : ℤ) ≤ (y (n + 2) : ℤ) := by
              rw [hnext2_eq]
              exact hnext2_low_int
            exact_mod_cast hlow_int2
          have hyn_ge1 : 1 ≤ y n := le_trans source_step_0 hage
          have hyn_pos_nat : 0 < y n := lt_of_lt_of_le zero_lt_one hyn_ge1
          have hyn_pos_real : (0 : ℝ) < (y n : ℝ) := by exact_mod_cast hyn_pos_nat
          have hyn_ne_real : (y n : ℝ) ≠ 0 := ne_of_gt hyn_pos_real
          have hαyn_nonint : ∀ z : ℤ, α * (y n : ℝ) ≠ (z : ℝ) := by
            intro z hz
            have hαeq : α = (z : ℝ) / (y n : ℝ) := by
              calc
                α = (α * (y n : ℝ)) / (y n : ℝ) := by field_simp [hyn_ne_real]
                _ = (z : ℝ) / (y n : ℝ) := by rw [hz]
            let q : ℚ := (z : ℚ) / (y n : ℚ)
            have hqreal : (q : ℝ) = (z : ℝ) / (y n : ℝ) := by
              dsimp [q]
              norm_num
            have hαq : α = (q : ℝ) := by rw [hαeq, hqreal]
            exact hαirr.ne_rat q hαq
          have hfloor_lt_arg : (Int.floor (α * (y n : ℝ)) : ℝ) < α * (y n : ℝ) := by
            by_contra hnot
            have hle : α * (y n : ℝ) ≤ (Int.floor (α * (y n : ℝ)) : ℝ) := le_of_not_gt hnot
            have hge : (Int.floor (α * (y n : ℝ)) : ℝ) ≤ α * (y n : ℝ) := Int.floor_le _
            have heq : (Int.floor (α * (y n : ℝ)) : ℝ) = α * (y n : ℝ) := le_antisymm hge hle
            exact (hαyn_nonint (Int.floor (α * (y n : ℝ)))) heq.symm
          have hnext_real_eq : (y (n + 1) : ℝ) = (Int.floor (α * (y n : ℝ)) : ℝ) := by
            have := congrArg (fun z : ℤ => (z : ℝ)) hnext_eq
            simpa using this
          have hw_lt : (y (n + 1) : ℝ) < α * (y n : ℝ) := by
            rw [hnext_real_eq]
            exact hfloor_lt_arg
          have hdiv_lt : (y (n + 1) : ℝ) / α < (y n : ℝ) := by
            rw [div_lt_iff₀ hαpos]
            calc
              (y (n + 1) : ℝ) < α * (y n : ℝ) := hw_lt
              _ = (y n : ℝ) * α := by ring
          have hfloor_next2_lt_int : Int.floor ((y (n + 1) : ℝ) / α) < (y n : ℤ) := by
            rw [Int.floor_lt]
            simpa using hdiv_lt
          have hnext2_lt : y (n + 2) < y n := by
            have hlt_int : (y (n + 2) : ℤ) < (y n : ℤ) := by
              rw [hnext2_eq]
              exact hfloor_next2_lt_int
            exact_mod_cast hlt_int
          have hnext2_le_L : y (n + 2) ≤ L := by omega
          have hsmall : y (n + 2) - a < d := by omega
          have hres := ih (y (n + 2) - a) hsmall (n + 2) rfl (by omega) hnext2_low hnext2_le_L
          rcases hres with ⟨k, hk⟩
          refine ⟨k + 1, ?_⟩
          have hidx : n + 2 * (k + 1) = (n + 2) + 2 * k := by omega
          rw [hidx]
          exact hk
    obtain ⟨k, hk⟩ := hit_a_aux (y N0 - a) N0 rfl (by omega) hN0_low hN0_le
    let n0 : ℕ := N0 + 2 * k
    have hya : y n0 = a := by
      dsimp [n0]
      exact hk
    have hn0_ge1 : 1 ≤ n0 := by dsimp [n0]; omega
    let z : ℕ → ℕ := fun n => y (n + n0 - 1)
    have hzpos : ∀ n : ℕ, 1 ≤ n → 0 < z n := by
      intro n hn
      dsimp [z]
      apply hypos
      omega
    have hzrec : ∀ n : ℕ, 1 ≤ n →
        (z (n + 1) : ℤ) =
          if z n ≤ L then Int.floor (α * (z n : ℝ))
          else Int.floor ((z n : ℝ) / α) := by
      intro n hn
      have hk1 : 1 ≤ n + n0 - 1 := by omega
      have hidx : (n + 1 + n0 - 1) = (n + n0 - 1) + 1 := by omega
      dsimp [z]
      rw [hidx]
      exact hyrec (n + n0 - 1) hk1
    have hz1 : z 1 = a := by
      dsimp [z]
      have hidx : 1 + n0 - 1 = n0 := by omega
      rw [hidx, hya]
    obtain ⟨hzper, hzmin⟩ := hy_from_a z hzpos hzrec hz1
    constructor
    · rcases hzper with ⟨Nz, hNz⟩
      refine ⟨Nz + n0, ?_⟩
      intro m hm
      let n1 : ℕ := m - n0 + 1
      have hn1_ge_Nz : Nz ≤ n1 := by dsimp [n1]; omega
      have hidx1 : n1 + n0 - 1 = m := by dsimp [n1]; omega
      have hidx2 : n1 + P + n0 - 1 = m + P := by dsimp [n1]; omega
      have hstep := hNz n1 hn1_ge_Nz
      have hzP : z (n1 + P) = y (m + P) := by
        dsimp [z]
        rw [hidx2]
      have hz0 : z n1 = y m := by
        dsimp [z]
        rw [hidx1]
      calc
        y (m + P) = z (n1 + P) := hzP.symm
        _ = z n1 := hstep
        _ = y m := hz0
    · intro q hqpos hyq
      rcases hyq with ⟨Ny, hNy⟩
      have hzqper : ∃ N : ℕ, ∀ n : ℕ, N ≤ n → z (n + q) = z n := by
        refine ⟨Ny + n0, ?_⟩
        intro n hn
        have hm_ge : Ny ≤ n + n0 - 1 := by omega
        have harg : n + q + n0 - 1 = (n + n0 - 1) + q := by omega
        dsimp [z]
        rw [harg]
        exact hNy (n + n0 - 1) hm_ge
      exact hzmin q hqpos hzqper
  exact ⟨source_step_4, source_step_17⟩