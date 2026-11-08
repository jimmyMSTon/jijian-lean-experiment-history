import Mathlib
set_option autoImplicit false
set_option Elab.async false

#check Nat.gcd
#check Nat.lcm
#check Nat.factorial
#check Nat.choose
#check Nat.Prime
#check Nat.Coprime
#check Int.natAbs
#check Real.sqrt
#check Real.log
#check Real.exp
#check Real.tan
#check Int.floor
#check Int.ceil
#check Set.image
#check Set.preimage
#check Set.Finite
#check Set.Infinite
#check Finset.sum
#check Finset.prod
#check Even
#check Odd

example (x y : ℕ) : (x % y) = (x % y) := by rfl
example (n : ℕ) : Nat.factorial n = Nat.factorial n := by rfl
example (n k : ℕ) : Nat.choose n k = Nat.choose n k := by rfl
example (n m : ℕ) : Nat.gcd n m = Nat.gcd n m := by rfl
example (x y : ℤ) : (x ∣ y) ↔ (x ∣ y) := by rfl
example (n : ℕ) : Even n ↔ Even n := by rfl
example (n : ℤ) : Odd n ↔ Odd n := by rfl
example (x : ℝ) : Real.sqrt x = Real.sqrt x := by rfl
example (x : ℝ) : Real.exp x = Real.exp x := by rfl
example (x : ℝ) : Real.log x = Real.log x := by rfl
example (x : ℝ) : Real.tan x = Real.tan x := by rfl
example (x : ℝ) : Int.floor x = Int.floor x := by rfl
example (x : ℝ) : Int.ceil x = Int.ceil x := by rfl
example (s : Set ℕ) : s ∪ s = s := by simp
example (s : Set ℕ) : s ∩ s = s := by simp
example (s : Set ℕ) (f : ℕ → ℤ) : Set.image f s = Set.image f s := by rfl
example (s : Set ℤ) (f : ℕ → ℤ) : Set.preimage f s = Set.preimage f s := by rfl
example (s : Finset ℕ) (f : ℕ → ℤ) : Finset.sum s f = Finset.sum s f := by rfl
example (s : Finset ℕ) (f : ℕ → ℤ) : Finset.prod s f = Finset.prod s f := by rfl
example (s : Finset ℕ) : s.card = s.card := by rfl
example (x : ℕ) : x ∈ (Set.univ : Set ℕ) := by simp
example (x : ℕ) : x ∉ (∅ : Set ℕ) := by simp
example (x : ℕ) : x ∈ ({x} : Set ℕ) := by simp
example (x : ℕ) (s : Set ℕ) : x ∈ insert x s := by simp
example (a b : ℝ) : max a b = max a b := by rfl
example (a b : ℝ) : min a b = min a b := by rfl
example (a : ℝ) : |a| = |a| := by rfl
