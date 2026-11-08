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
