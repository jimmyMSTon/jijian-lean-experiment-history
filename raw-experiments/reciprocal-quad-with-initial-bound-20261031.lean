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
