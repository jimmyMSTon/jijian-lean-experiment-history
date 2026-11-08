

theorem quadratic_fraction_recurrence_iff
    (x y z e : ℕ) (hz : 0 < z) :
    ((x : ℚ) = (((y : ℚ)^2 + (y : ℚ) + 1)^e) / (z : ℚ)) ↔
    x*z = (y^2 + y + 1)^e := by
  have hzq : (z : ℚ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt hz)
  constructor
  · intro h
    have hmul := (eq_div_iff hzq).mp h
    have hcast : ((x*z : ℕ) : ℚ) = (((y^2+y+1)^e : ℕ) : ℚ) := by
      simpa only [Nat.cast_pow,Nat.cast_add,Nat.cast_mul,Nat.cast_one] using hmul
    exact_mod_cast hcast
  · intro h
    apply (eq_div_iff hzq).mpr
    have hcast := congrArg (fun z : ℕ => (z : ℚ)) h
    simpa only [Nat.cast_pow,Nat.cast_add,Nat.cast_mul,Nat.cast_one] using hcast

theorem bmo2_2025_q4_latest_frozen_formal_statement :
  Set.ncard ({v : ℕ → ℕ | (∀ n : ℕ, 0 < v n) ∧
      (v 0 = 1) ∧
      (∀ n : ℕ, 2 ≤ n →
        (v n : ℚ) =
          (((v (n - 1) : ℚ)^2 + (v (n - 1) : ℚ) + 1)^2025) /
          (v (n - 2) : ℚ))} : Set (ℕ → ℕ)) = 2026 := by
  have heq :
      ({v : ℕ → ℕ | (∀ n : ℕ, 0 < v n) ∧
          (v 0 = 1) ∧
          (∀ n : ℕ, 2 ≤ n →
            (v n : ℚ) =
              (((v (n - 1) : ℚ)^2 + (v (n - 1) : ℚ) + 1)^2025) /
              (v (n - 2) : ℚ))} : Set (ℕ → ℕ)) =
        quadraticRecurrenceSolutions 1 2025 := by
    ext v
    constructor
    · rintro ⟨hpos,h0,hfrac⟩
      refine ⟨h0,hpos,?_⟩
      intro n
      have h := hfrac (n+2) (by omega)
      have hq : (v (n+2) : ℚ) =
           (((v (n+1) : ℚ)^2 + (v (n+1) : ℚ)+1)^2025) /
             (v n : ℚ) := by
        simpa only [show (n+2)-1 = n+1 by omega,
                    show (n+2)-2 = n by omega] using h
      have hh := (quadratic_fraction_recurrence_iff
             (v (n+2)) (v (n+1)) (v n) 2025 (hpos n)).mp hq
      simpa only [one_mul] using hh
    · rintro ⟨h0,hpos,hrec⟩
      refine ⟨hpos,h0,?_⟩
      intro n hn
      obtain ⟨m,rfl⟩ : ∃ m : ℕ, n = m+2 := ⟨n-2, by omega⟩
      have hnat : v (m+2) * v m =
          ((v (m+1))^2 + v (m+1)+1)^2025 := by
        simpa only [one_mul] using hrec m
      have hq := (quadratic_fraction_recurrence_iff
             (v (m+2)) (v (m+1)) (v m) 2025 (hpos m)).mpr hnat
      simpa only [show (m+2)-1 = m+1 by omega,
                  show (m+2)-2 = m by omega] using hq
  rw [heq, quadraticRecurrenceSolutions_count]
  simpa only [show (1:ℕ)+2=3 by decide] using count_three_power_divisors
