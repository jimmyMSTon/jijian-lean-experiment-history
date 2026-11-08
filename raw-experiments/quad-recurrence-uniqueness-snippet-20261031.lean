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
