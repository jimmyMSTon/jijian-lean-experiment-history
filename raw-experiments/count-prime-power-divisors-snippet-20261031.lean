theorem count_prime_power_divisors (p e : ℕ) (hp : Nat.Prime p) :
    (Nat.divisors (p^e)).card = e+1 := by
  rw [Nat.divisors_prime_pow hp e]
  simp
theorem count_three_power_divisors :
    (Nat.divisors (3^2025)).card = 2026 := by
  simpa only [show (2025 : ℕ) + 1 = 2026 by decide]
    using count_prime_power_divisors 3 2025 (by norm_num)
