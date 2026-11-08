def QuadraticRecurrenceValid (a e : ℕ) (u : ℕ → ℕ) : Prop :=
  u 0 = 1 ∧ (∀ n, 0 < u n) ∧
  ∀ n, u (n+2)*u n = ((u (n+1))^2+a*(u (n+1))+1)^e

theorem quadraticRecurrenceStartDivides
    (a e : ℕ) (u : ℕ → ℕ)
    (hu : QuadraticRecurrenceValid a e u) :
    u 1 ∣ (a+2)^e := by
  obtain ⟨hzero, hpos, hrec⟩ := hu
  have hy : u 2 = ((u 1)^2 + a*(u 1)+1)^e := by
    have h := hrec 0
    simpa [hzero] using h
  have hz : u 3 * u 1 = ((u 2)^2+a*(u 2)+1)^e := by
    simpa using hrec 1
  exact quadratic_recurrence_initial_bound a (u 1) (u 2) (u 3) e hy hz
