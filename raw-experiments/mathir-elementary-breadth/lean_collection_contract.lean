import Mathlib
set_option autoImplicit false
set_option Elab.async false

#check Set.insert
#check Set.compl
#check Set.univ
#check Set.image
#check Set.preimage
#check Function.comp
#check Nat.Coprime
#check Int.floor
#check Int.ceil
#check Finset.card
#check Nat.factorial

example (s : Set ℕ) (x : ℕ) : Set.insert x s = Set.insert x s := by rfl
example (s : Set ℕ) : Set.compl s = Set.compl s := by rfl
example (s : Set ℕ) : Set.Finite s ↔ Set.Finite s := by rfl
example (s : Set ℕ) : Set.Infinite s ↔ Set.Infinite s := by rfl
example (s t : Set ℕ) : s \ t = s \ t := by rfl
example (s : Set ℕ) : s ⊆ s := by intro x h; exact h
example (s : Set ℕ) : s ∩ s = s := by simp
example (s : Set ℕ) : s ∪ s = s := by simp
example (s : Set ℕ) : Set.univ ∩ s = s := by simp
example (s : Set ℕ) (f : ℕ → ℝ) : Set.image f s = Set.image f s := by rfl
example (s : Set ℝ) (f : ℕ → ℝ) : Set.preimage f s = Set.preimage f s := by rfl
example (f g : ℕ → ℕ) : Function.comp f g = Function.comp f g := by rfl
example (s : Finset ℕ) : (∅ : Finset ℕ) = ∅ := by rfl
example (s : Finset ℕ) (f : ℕ → ℤ) : Finset.sum s f = Finset.sum s f := by rfl
example (s : Finset ℕ) (f : ℕ → ℤ) : Finset.prod s f = Finset.prod s f := by rfl
example (a b : ℕ) : Nat.Coprime a b ↔ Nat.Coprime a b := by rfl
example (n : ℕ) : (∏ k ∈ Finset.Icc 1 n, k) = ∏ k ∈ Finset.Icc 1 n, k := by rfl
