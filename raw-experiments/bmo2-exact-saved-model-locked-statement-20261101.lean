import Mathlib
set_option autoImplicit false
theorem quadratic_recurrence_invariant
    {R : Type*} [CommRing R]
    (a b d : R) (e : ℕ)
    (h : b * d = 1)
    (hz : (b^2 + a*b + 1)^e = 0) :
    (d^2 + a*d + 1)^e = 0 := by
  have key : b^2 * (d^2 + a*d + 1) = b^2+a*b+1 := by
    calc
      b^2 * (d^2+a*d+1) = (b*d)^2 + (b*d)*a*b + b^2 := by ring
      _ = b^2+a*b+1 := by rw [h]; ring
  have hpow := congrArg (fun x : R => x^e) key
  rw [mul_pow,hz] at hpow
  have hbd : (b^2)^e * (d^2)^e = 1 := by
    calc
      (b^2)^e * (d^2)^e = ((b*d)^2)^e := by ring
      _ = 1 := by rw [h]; simp
  have hdb : (d^2)^e * (b^2)^e = 1 := by
    simpa only [mul_comm] using hbd
  calc
    (d^2+a*d+1)^e = 1 * (d^2+a*d+1)^e := by ring
    _ = ((d^2)^e * (b^2)^e) * (d^2+a*d+1)^e := by rw [hdb]
    _ = (d^2)^e * ((b^2)^e * (d^2+a*d+1)^e) := by ring
    _ = 0 := by rw [hpow]; ring

theorem quadratic_recurrence_nat_divisibility
    (a b c d e : ℕ)
    (hbd : b*d % c = 1 % c)
    (hdiv : c ∣ (b^2 + a*b + 1)^e) :
    c ∣ (d^2 + a*d + 1)^e := by
  have hbdz : (b : ZMod c) * (d : ZMod c) = 1 := by
    have h : ((b*d : ℕ) : ZMod c) = ((1 : ℕ) : ZMod c) :=
      (ZMod.natCast_eq_natCast_iff' (b*d) 1 c).mpr hbd
    simpa only [Nat.cast_mul, Nat.cast_one] using h
  have hz : ((b : ZMod c)^2 + (a:ZMod c)*b + 1)^e = 0 := by
    have h : (((b^2+a*b+1)^e : ℕ) : ZMod c) = 0 :=
      (ZMod.natCast_eq_zero_iff ((b^2+a*b+1)^e) c).mpr hdiv
    simpa only [Nat.cast_pow, Nat.cast_add, Nat.cast_mul, Nat.cast_one] using h
  have hrez := quadratic_recurrence_invariant
    (a: ZMod c) (b : ZMod c) (d : ZMod c) e hbdz hz
  apply (ZMod.natCast_eq_zero_iff ((d^2+a*d+1)^e) c).mp
  simpa only [Nat.cast_pow, Nat.cast_add, Nat.cast_mul, Nat.cast_one] using hrez

theorem quadratic_recurrence_initial_bound
    (a x y z e : ℕ)
    (hy : y = (x^2 + a*x + 1)^e)
    (hz : z*x = (y^2 + a*y + 1)^e) :
    x ∣ (a+2)^e := by
  have hyz : (y : ZMod x) = 1 := by
    rw [hy]
    push_cast
    simp
  have hpoly : (((y^2 + a*y + 1)^e : ℕ) : ZMod x) = (((a+2)^e : ℕ) : ZMod x) := by
    push_cast
    rw [hyz]
    ring
  have hdiv : x ∣ (y^2 + a*y + 1)^e := by
    exact ⟨z, by simpa [mul_comm] using hz.symm⟩
  have hzero : (((y^2 + a*y + 1)^e : ℕ) : ZMod x) = 0 :=
    (ZMod.natCast_eq_zero_iff ((y^2+a*y+1)^e) x).mpr hdiv
  exact (ZMod.natCast_eq_zero_iff ((a+2)^e) x).mp (hpoly.symm.trans hzero)

theorem count_prime_power_divisors (p e : ℕ) (hp : Nat.Prime p) :
    (Nat.divisors (p^e)).card = e+1 := by
  rw [Nat.divisors_prime_pow hp e]
  simp
theorem count_three_power_divisors :
    (Nat.divisors (3^2025)).card = 2026 := by
  simpa only [show (2025 : ℕ) + 1 = 2026 by decide]
    using count_prime_power_divisors 3 2025 (by norm_num)

theorem quadratic_recurrence_step_divisible
    (a b c d e : ℕ)
    (hprev : b*d = (c^2 + a*c + 1)^e)
    (holder : c ∣ (b^2 + a*b + 1)^e) :
    c ∣ (d^2 + a*d + 1)^e := by
  have hbd : b*d % c = 1 % c := by
    apply (ZMod.natCast_eq_natCast_iff' (b*d) 1 c).mp
    rw [hprev]
    push_cast
    simp
  exact quadratic_recurrence_nat_divisibility a b c d e hbd holder

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

theorem quadraticRecurrenceSequence_unique
    (a e : ℕ) (u v : ℕ → ℕ)
    (h0 : u 0 = v 0) (h1 : u 1 = v 1)
    (hpos : ∀ n, 0 < u n)
    (hu : ∀ n, u (n+2)*u n = (u (n+1)^2 + a*u (n+1)+1)^e)
    (hv : ∀ n, v (n+2)*v n = (v (n+1)^2 + a*v (n+1)+1)^e) :
    u = v := by
  funext n
  induction n using Nat.twoStepInduction with
  | zero => exact h0
  | one => exact h1
  | more n hn hn1 =>
      apply Nat.eq_of_mul_eq_mul_right (hpos n)
      calc
        u (n+2)*u n = (u (n+1)^2+a*u (n+1)+1)^e := hu n
        _ = (v (n+1)^2+a*v (n+1)+1)^e := by rw [hn1]
        _ = v (n+2)*v n := (hv n).symm
        _ = v (n+2)*u n := by rw [hn]


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

-- The goal below is copied verbatim from the REAL DeepSeek locked theorem.
theorem replay_exact_saved_locked_statement :
  Set.ncard ({v : ℕ → ℕ | (∀ n : ℕ, 0 < v n) ∧ (v 0 = 1) ∧ (∀ n : ℕ, 2 ≤ n → (v n : ℚ) = (((v (n - 1) : ℚ) ^ 2 + (v (n - 1) : ℚ) + 1) ^ 2025) / (v (n - 2) : ℚ))} : Set (ℕ → ℕ)) = 2026 := by
  exact bmo2_2025_q4_frozen_formal_statement
#print axioms replay_exact_saved_locked_statement
