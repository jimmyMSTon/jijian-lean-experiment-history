

def quadraticRecurrenceSolutions (a e : ℕ) : Set (ℕ → ℕ) :=
  {u | u 0 = 1 ∧ (∀ n, 0 < u n) ∧
       ∀ n, u (n+2) * u n =
         ((u (n+1))^2 + a*(u (n+1)) + 1)^e}

theorem quadraticRecurrenceSolutions_initial_dvd
    (a e : ℕ) (u : ℕ → ℕ) (hu : u ∈ quadraticRecurrenceSolutions a e) :
    u 1 ∣ (a+2)^e := by
  rcases hu with ⟨hu0, _hpos, hrec⟩
  apply quadratic_recurrence_initial_bound a (u 1) (u 2) (u 3) e
  · simpa [hu0] using hrec 0
  · exact hrec 1

noncomputable def quadraticRecurrenceFromDivisor
    (a e x : ℕ) (hx : x ∈ Nat.divisors ((a+2)^e)) : ℕ → ℕ :=
  quadraticRecurrenceSequence a e x ((Nat.mem_divisors.mp hx).1)

theorem quadraticRecurrenceFromDivisor_spec (a e x : ℕ)
    (hx : x ∈ Nat.divisors ((a+2)^e)) :
    quadraticRecurrenceFromDivisor a e x hx ∈ quadraticRecurrenceSolutions a e ∧
    quadraticRecurrenceFromDivisor a e x hx 1 = x := by
  rcases quadraticRecurrenceSequence_spec a e x ((Nat.mem_divisors.mp hx).1)
    with ⟨h0, h1, hpos, hrec⟩
  exact ⟨⟨h0,hpos,hrec⟩,h1⟩

theorem quadraticRecurrenceSolutions_count (a e : ℕ) :
    (quadraticRecurrenceSolutions a e).ncard =
      (Nat.divisors ((a+2)^e)).card := by
  classical
  let s : Set ℕ := (Nat.divisors ((a+2)^e) : Set ℕ)
  have hcard : s.ncard = (quadraticRecurrenceSolutions a e).ncard := by
    apply Set.ncard_congr
      (s:=s) (t:=quadraticRecurrenceSolutions a e)
      (f:=fun x hx => quadraticRecurrenceFromDivisor a e x (show x ∈ Nat.divisors ((a+2)^e) from hx))
    · intro x hx
      exact (quadraticRecurrenceFromDivisor_spec a e x (show x ∈ Nat.divisors ((a+2)^e) from hx)).1
    · intro x y hx hy heq
      have ha := congrArg (fun u : ℕ → ℕ => u 1) heq
      simpa only [(quadraticRecurrenceFromDivisor_spec a e x (show x ∈ Nat.divisors ((a+2)^e) from hx)).2,
                  (quadraticRecurrenceFromDivisor_spec a e y (show y ∈ Nat.divisors ((a+2)^e) from hy)).2] using ha
    · intro u hu
      have hd : u 1 ∈ Nat.divisors ((a+2)^e) := by
        apply Nat.mem_divisors.mpr
        exact ⟨quadraticRecurrenceSolutions_initial_dvd a e u hu, by positivity⟩
      refine ⟨u 1, hd, ?_⟩
      rcases hu with ⟨hu0,hpos,hrec⟩
      have hs := quadraticRecurrenceSequence_spec a e (u 1) ((Nat.mem_divisors.mp hd).1)
      exact (quadraticRecurrenceSequence_unique a e
        u (quadraticRecurrenceFromDivisor a e (u 1) hd)
        (by simpa only [quadraticRecurrenceFromDivisor] using hu0.trans hs.1.symm)
        (by exact hs.2.1.symm)
        hpos hrec hs.2.2.2).symm
  simpa [s] using hcard.symm
