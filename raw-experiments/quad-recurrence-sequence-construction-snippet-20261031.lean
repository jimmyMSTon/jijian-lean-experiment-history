structure QuadraticRecurrenceState (a e : ℕ) where
  b : ℕ
  c : ℕ
  d : ℕ
  b_pos : 0 < b
  c_pos : 0 < c
  d_pos : 0 < d
  step : b*d = (c^2+a*c+1)^e
  prev_div : c ∣ (b^2+a*b+1)^e

def quadraticRecurrenceInitial
    (a e x : ℕ) (hx : x ∣ (a+2)^e) :
    QuadraticRecurrenceState a e := by
  have hxpos : 0 < x := by
    by_contra hn
    have hx0 : x = 0 := Nat.eq_zero_of_not_pos hn
    have hpow : 0 < (a+2)^e := by positivity
    rcases hx with ⟨t, ht⟩
    simp [hx0] at ht
  refine ⟨1, x, (x^2+a*x+1)^e, ?_, hxpos, ?_, ?_, ?_⟩
  · decide
  · positivity
  · simp
  · simpa [add_assoc, add_comm, add_left_comm] using hx

noncomputable def quadraticRecurrenceNext
    (a e : ℕ) (s : QuadraticRecurrenceState a e) :
    QuadraticRecurrenceState a e := by
  classical
  let hdiv : s.c ∣ (s.d^2 + a*s.d + 1)^e :=
    quadratic_recurrence_step_divisible a s.b s.c s.d e s.step s.prev_div
  let t := Classical.choose hdiv
  have ht : (s.d^2 + a*s.d + 1)^e = s.c*t := Classical.choose_spec hdiv
  have htpos : 0 < t := by
    by_contra hn
    have hz : t = 0 := Nat.eq_zero_of_not_pos hn
    have hp : 0 < (s.d^2+a*s.d+1)^e := by positivity
    simp [hz] at ht
  refine ⟨s.c, s.d, t, s.c_pos, s.d_pos, htpos, ?_, ?_⟩
  · simpa [mul_comm] using ht.symm
  · exact ⟨s.b, by simpa [mul_comm] using s.step.symm⟩

noncomputable def quadraticRecurrenceStates (a e x : ℕ)
    (hx : x ∣ (a+2)^e) : ℕ → QuadraticRecurrenceState a e
  | 0 => quadraticRecurrenceInitial a e x hx
  | n+1 => quadraticRecurrenceNext a e (quadraticRecurrenceStates a e x hx n)

noncomputable def quadraticRecurrenceSequence
    (a e x : ℕ) (hx : x ∣ (a+2)^e) (n : ℕ) : ℕ :=
  (quadraticRecurrenceStates a e x hx n).b

theorem quadraticRecurrenceSequence_spec
    (a e x : ℕ) (hx : x ∣ (a+2)^e) :
    quadraticRecurrenceSequence a e x hx 0 = 1 ∧
    quadraticRecurrenceSequence a e x hx 1 = x ∧
    (∀ n, 0 < quadraticRecurrenceSequence a e x hx n) ∧
    (∀ n,
      quadraticRecurrenceSequence a e x hx (n+2) *
      quadraticRecurrenceSequence a e x hx n =
      ((quadraticRecurrenceSequence a e x hx (n+1))^2 +
       a*(quadraticRecurrenceSequence a e x hx (n+1))+1)^e) := by
  let st := quadraticRecurrenceStates a e x hx
  let u := quadraticRecurrenceSequence a e x hx
  have first (n : ℕ) : u n = (st n).b := rfl
  have shift1 (n : ℕ) : u (n+1) = (st n).c := by
    simp [u,st,quadraticRecurrenceSequence,quadraticRecurrenceStates,
          quadraticRecurrenceNext]
  have shift2 (n : ℕ) : u (n+2) = (st n).d := by
    simp [u,st,quadraticRecurrenceSequence,quadraticRecurrenceStates,
          quadraticRecurrenceNext,show n+2=(n+1)+1 by omega]
  refine ⟨rfl, rfl, ?_, ?_⟩
  · intro n
    change 0 < u n
    rw [first]
    exact (st n).b_pos
  · intro n
    change u (n+2)*u n = ((u (n+1))^2+a*(u (n+1))+1)^e
    rw [first n,shift1 n,shift2 n]
    simpa [mul_comm] using (st n).step

theorem quadraticRecurrenceSequence_exists
    (a e x : ℕ) (hx : x ∣ (a+2)^e) :
    ∃ u : ℕ → ℕ,
        u 0 = 1 ∧ u 1 = x ∧ (∀ n, 0 < u n) ∧
        (∀ n, u (n+2)*u n = ((u (n+1))^2 + a*(u (n+1))+1)^e) := by
  exact ⟨quadraticRecurrenceSequence a e x hx,
         quadraticRecurrenceSequence_spec a e x hx⟩
