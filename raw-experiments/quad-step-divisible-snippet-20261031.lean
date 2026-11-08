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
