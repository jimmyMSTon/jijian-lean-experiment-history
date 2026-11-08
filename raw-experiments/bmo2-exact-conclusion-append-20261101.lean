

-- Exact fixed statement produced by the real 2025 BMO2 Q4 model run.
theorem bmo2_2025_q4_frozen_formal_statement :
  Set.ncard ({u : ℕ → ℕ |
      u 0 = 1 ∧
      (∀ n : ℕ, 0 < u n) ∧
      (∀ n : ℕ, 1 ≤ n →
        u (n + 1) * u (n - 1) =
          (u n ^ 2 + u n + 1) ^ 2025)} : Set (ℕ → ℕ)) = 2026 := by
  have heq :
      ({u : ℕ → ℕ |
         u 0 = 1 ∧ (∀ n : ℕ, 0 < u n) ∧
         (∀ n : ℕ, 1 ≤ n →
             u (n + 1) * u (n - 1) =
               (u n ^ 2 + u n + 1) ^ 2025)} : Set (ℕ → ℕ)) =
           quadraticRecurrenceSolutions 1 2025 := by
    ext u
    constructor
    · rintro ⟨h0,hpos,hrec⟩
      refine ⟨h0,hpos,?_⟩
      intro n
      have h := hrec (n+1) (by omega)
      simpa [Nat.add_assoc] using h
    · rintro ⟨h0,hpos,hrec⟩
      refine ⟨h0,hpos,?_⟩
      intro n hn
      obtain ⟨m,rfl⟩ : ∃ m : ℕ, n = m+1 :=
        ⟨n-1, by omega⟩
      have h := hrec m
      simpa [Nat.add_assoc] using h
  rw [heq, quadraticRecurrenceSolutions_count]
  simpa only [show (1:ℕ)+2=3 by decide] using
    count_three_power_divisors
