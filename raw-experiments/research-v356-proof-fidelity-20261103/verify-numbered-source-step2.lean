import Mathlib

private def poly (n : ℕ) : ℕ :=
  (n + 2)^5 + (n + 2)^4 + (n + 2)^3 + (n + 2)^2 + (n + 2) + 1

example (p n : ℕ) (hp : Nat.Prime p) (hn : 1 < n) (h : p ∣ n + 1) :
    p ∣ ((n + 2)^6 - 1) := by
  have hid : (n+2)^6 - 1 = (n+1)*poly n := by
    have heq : (n+2)^6 = 1 + (n+1)*poly n := by
      dsimp [poly]
      ring
    omega
  rcases h with ⟨k, hk⟩
  rw [hid, hk]
  refine ⟨k * poly n, ?_⟩
  ring
