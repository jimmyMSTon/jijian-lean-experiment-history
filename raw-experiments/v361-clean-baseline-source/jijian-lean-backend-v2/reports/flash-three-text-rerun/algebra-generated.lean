import Mathlib
set_option autoImplicit false

-- 原文步骤: p1
theorem step_0 :
∀ (v0 : (ℝ)) ,
∀ (v1 : (ℝ)) ,
∀ (h0 : (v0 ∈ (Set.univ : Set ℝ) ∧ v1 ∈ (Set.univ : Set ℝ))) ,
∀ (h1 : (∀ r : ℝ, r ^ 2 ≥ 0)) ,
2 * (v0 ^ 2 + v1 ^ 2) - (v0 + v1) ^ 2 = v0 ^ 2 - 2 * v0 * v1 + v1 ^ 2 ∧ v0 ^ 2 - 2 * v0 * v1 + v1 ^ 2 = (v0 - v1) ^ 2 :=
fun (v0 : (ℝ))  =>
fun (v1 : (ℝ))  =>
fun (h0 : (v0 ∈ (Set.univ : Set ℝ) ∧ v1 ∈ (Set.univ : Set ℝ)))  =>
fun (h1 : (∀ r : ℝ, r ^ 2 ≥ 0))  =>
by
  constructor <;> ring

-- 原文步骤: p2
theorem step_1 :
∀ (v0 : (ℝ)) ,
∀ (v1 : (ℝ)) ,
∀ (h0 : (v0 ∈ (Set.univ : Set ℝ) ∧ v1 ∈ (Set.univ : Set ℝ))) ,
∀ (h1 : (∀ r : ℝ, r ^ 2 ≥ 0)) ,
(v0 - v1) ^ 2 ≥ 0 :=
fun (v0 : (ℝ))  =>
fun (v1 : (ℝ))  =>
fun (h0 : (v0 ∈ (Set.univ : Set ℝ) ∧ v1 ∈ (Set.univ : Set ℝ)))  =>
fun (h1 : (∀ r : ℝ, r ^ 2 ≥ 0))  =>
by
  exact h1 (v0 - v1)

-- 原文步骤: p3
theorem step_2 :
∀ (v0 : (ℝ)) ,
∀ (v1 : (ℝ)) ,
∀ (h0 : (v0 ∈ (Set.univ : Set ℝ) ∧ v1 ∈ (Set.univ : Set ℝ))) ,
∀ (h1 : (∀ r : ℝ, r ^ 2 ≥ 0)) ,
∀ (s0 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (ℝ)) ,
∀ (h0 : (v0 ∈ (Set.univ : Set ℝ) ∧ v1 ∈ (Set.univ : Set ℝ))) ,
∀ (h1 : (∀ r : ℝ, r ^ 2 ≥ 0)) ,
2 * (v0 ^ 2 + v1 ^ 2) - (v0 + v1) ^ 2 = v0 ^ 2 - 2 * v0 * v1 + v1 ^ 2 ∧ v0 ^ 2 - 2 * v0 * v1 + v1 ^ 2 = (v0 - v1) ^ 2)) ,
∀ (s1 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (ℝ)) ,
∀ (h0 : (v0 ∈ (Set.univ : Set ℝ) ∧ v1 ∈ (Set.univ : Set ℝ))) ,
∀ (h1 : (∀ r : ℝ, r ^ 2 ≥ 0)) ,
(v0 - v1) ^ 2 ≥ 0)) ,
2 * (v0 ^ 2 + v1 ^ 2) - (v0 + v1) ^ 2 ≥ 0 :=
fun (v0 : (ℝ))  =>
fun (v1 : (ℝ))  =>
fun (h0 : (v0 ∈ (Set.univ : Set ℝ) ∧ v1 ∈ (Set.univ : Set ℝ)))  =>
fun (h1 : (∀ r : ℝ, r ^ 2 ≥ 0))  =>
fun (s0 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (ℝ)) ,
∀ (h0 : (v0 ∈ (Set.univ : Set ℝ) ∧ v1 ∈ (Set.univ : Set ℝ))) ,
∀ (h1 : (∀ r : ℝ, r ^ 2 ≥ 0)) ,
2 * (v0 ^ 2 + v1 ^ 2) - (v0 + v1) ^ 2 = v0 ^ 2 - 2 * v0 * v1 + v1 ^ 2 ∧ v0 ^ 2 - 2 * v0 * v1 + v1 ^ 2 = (v0 - v1) ^ 2))  =>
fun (s1 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (ℝ)) ,
∀ (h0 : (v0 ∈ (Set.univ : Set ℝ) ∧ v1 ∈ (Set.univ : Set ℝ))) ,
∀ (h1 : (∀ r : ℝ, r ^ 2 ≥ 0)) ,
(v0 - v1) ^ 2 ≥ 0))  =>
by
  have h := s0 v0 v1 h0 h1
  rw [h.1, h.2]
  exact s1 v0 v1 h0 h1

-- 原文步骤: g
theorem step_3 :
∀ (v0 : (ℝ)) ,
∀ (v1 : (ℝ)) ,
∀ (h0 : (v0 ∈ (Set.univ : Set ℝ) ∧ v1 ∈ (Set.univ : Set ℝ))) ,
∀ (h1 : (∀ r : ℝ, r ^ 2 ≥ 0)) ,
∀ (s2 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (ℝ)) ,
∀ (h0 : (v0 ∈ (Set.univ : Set ℝ) ∧ v1 ∈ (Set.univ : Set ℝ))) ,
∀ (h1 : (∀ r : ℝ, r ^ 2 ≥ 0)) ,
2 * (v0 ^ 2 + v1 ^ 2) - (v0 + v1) ^ 2 ≥ 0)) ,
(v0 + v1) ^ 2 ≤ 2 * (v0 ^ 2 + v1 ^ 2) :=
fun (v0 : (ℝ))  =>
fun (v1 : (ℝ))  =>
fun (h0 : (v0 ∈ (Set.univ : Set ℝ) ∧ v1 ∈ (Set.univ : Set ℝ)))  =>
fun (h1 : (∀ r : ℝ, r ^ 2 ≥ 0))  =>
fun (s2 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (ℝ)) ,
∀ (h0 : (v0 ∈ (Set.univ : Set ℝ) ∧ v1 ∈ (Set.univ : Set ℝ))) ,
∀ (h1 : (∀ r : ℝ, r ^ 2 ≥ 0)) ,
2 * (v0 ^ 2 + v1 ^ 2) - (v0 + v1) ^ 2 ≥ 0))  =>
by
  exact sub_nonneg.mp (s2 v0 v1 h0 h1)
