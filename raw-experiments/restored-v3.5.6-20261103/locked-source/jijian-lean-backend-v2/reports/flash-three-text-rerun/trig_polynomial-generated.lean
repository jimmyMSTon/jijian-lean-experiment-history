import Mathlib
set_option autoImplicit false

-- 原文步骤: ps1_addition
theorem step_0 :
∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
Real.cos (3 * v0) = Real.cos (2 * v0) * Real.cos v0 - Real.sin (2 * v0) * Real.sin v0 :=
fun (v0 : (ℝ))  =>
fun (v1 : (Polynomial ℝ))  =>
fun (v2 : (Polynomial ℝ))  =>
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
by
  rw [show (3 : ℝ) * v0 = 2 * v0 + v0 by ring]
  exact Real.cos_add (2 * v0) v0

-- 原文步骤: ps2_cos2
theorem step_1 :
∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
Real.cos (2 * v0) = 2 * Real.cos v0 ^ 2 - 1 :=
fun (v0 : (ℝ))  =>
fun (v1 : (Polynomial ℝ))  =>
fun (v2 : (Polynomial ℝ))  =>
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
by
  exact Real.cos_two_mul v0

-- 原文步骤: ps3_sin2
theorem step_2 :
∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
Real.sin (2 * v0) = 2 * Real.sin v0 * Real.cos v0 :=
fun (v0 : (ℝ))  =>
fun (v1 : (Polynomial ℝ))  =>
fun (v2 : (Polynomial ℝ))  =>
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
by
  exact Real.sin_two_mul v0

-- 原文步骤: ps4_substitute
theorem step_3 :
∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
∀ (s0 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
Real.cos (3 * v0) = Real.cos (2 * v0) * Real.cos v0 - Real.sin (2 * v0) * Real.sin v0)) ,
∀ (s1 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
Real.cos (2 * v0) = 2 * Real.cos v0 ^ 2 - 1)) ,
∀ (s2 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
Real.sin (2 * v0) = 2 * Real.sin v0 * Real.cos v0)) ,
Real.cos (3 * v0) = (2 * Real.cos v0 ^ 2 - 1) * Real.cos v0 - 2 * Real.sin v0 ^ 2 * Real.cos v0 :=
fun (v0 : (ℝ))  =>
fun (v1 : (Polynomial ℝ))  =>
fun (v2 : (Polynomial ℝ))  =>
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
fun (s0 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
Real.cos (3 * v0) = Real.cos (2 * v0) * Real.cos v0 - Real.sin (2 * v0) * Real.sin v0))  =>
fun (s1 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
Real.cos (2 * v0) = 2 * Real.cos v0 ^ 2 - 1))  =>
fun (s2 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
Real.sin (2 * v0) = 2 * Real.sin v0 * Real.cos v0))  =>
by
  have h0 : Real.cos (3 * v0) = Real.cos (2 * v0) * Real.cos v0 - Real.sin (2 * v0) * Real.sin v0 := s0 v0 v1 v2
  have h1 : Real.cos (2 * v0) = 2 * Real.cos v0 ^ 2 - 1 := s1 v0 v1 v2
  have h2 : Real.sin (2 * v0) = 2 * Real.sin v0 * Real.cos v0 := s2 v0 v1 v2
  rw [h0, h1, h2]
  ring

-- 原文步骤: ps5_sin2_identity
theorem step_4 :
∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
Real.sin v0 ^ 2 = 1 - Real.cos v0 ^ 2 :=
fun (v0 : (ℝ))  =>
fun (v1 : (Polynomial ℝ))  =>
fun (v2 : (Polynomial ℝ))  =>
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
by
  have h := Real.sin_sq_add_cos_sq v0
  linarith

-- 原文步骤: ps6_simplify
theorem step_5 :
∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
∀ (s3 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
Real.cos (3 * v0) = (2 * Real.cos v0 ^ 2 - 1) * Real.cos v0 - 2 * Real.sin v0 ^ 2 * Real.cos v0)) ,
∀ (s4 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
Real.sin v0 ^ 2 = 1 - Real.cos v0 ^ 2)) ,
Real.cos (3 * v0) = 4 * Real.cos v0 ^ 3 - 3 * Real.cos v0 :=
fun (v0 : (ℝ))  =>
fun (v1 : (Polynomial ℝ))  =>
fun (v2 : (Polynomial ℝ))  =>
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
fun (s3 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
Real.cos (3 * v0) = (2 * Real.cos v0 ^ 2 - 1) * Real.cos v0 - 2 * Real.sin v0 ^ 2 * Real.cos v0))  =>
fun (s4 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
Real.sin v0 ^ 2 = 1 - Real.cos v0 ^ 2))  =>
by
  have h3 : Real.cos (3 * v0) = (2 * Real.cos v0 ^ 2 - 1) * Real.cos v0 - 2 * Real.sin v0 ^ 2 * Real.cos v0 := s3 v0 v1 v2
  have h4 : Real.sin v0 ^ 2 = 1 - Real.cos v0 ^ 2 := s4 v0 v1 v2
  rw [h3, h4]
  ring

-- 原文步骤 ps7_take_P 尚无可验证证明片段

-- 原文步骤: ps8_final
theorem step_7 :
∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
∀ (s6 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
v1 = (4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X)) ,
∀ (s5 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
Real.cos (3 * v0) = 4 * Real.cos v0 ^ 3 - 3 * Real.cos v0)) ,
Real.cos (3 * v0) = Polynomial.eval (Real.cos v0) v1 :=
fun (v0 : (ℝ))  =>
fun (v1 : (Polynomial ℝ))  =>
fun (v2 : (Polynomial ℝ))  =>
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
fun (s6 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
v1 = (4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X))  =>
fun (s5 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
Real.cos (3 * v0) = 4 * Real.cos v0 ^ 3 - 3 * Real.cos v0))  =>
by
  have hs5 : Real.cos (3 * v0) = 4 * Real.cos v0 ^ 3 - 3 * Real.cos v0 := s5 v0 v1 v2
  have hs6 : v1 = (4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X := s6 v0 v1 v2
  rw [hs5, hs6]
  simp [Polynomial.eval_sub, Polynomial.eval_mul, Polynomial.eval_pow, Polynomial.eval_X]

-- 原文步骤: goal_exists_P
theorem step_8 :
∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
∀ (s6 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
v1 = (4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X)) ,
∀ (s7 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
Real.cos (3 * v0) = Polynomial.eval (Real.cos v0) v1)) ,
∃ P : Polynomial ℝ, ∀ θ : ℝ, Real.cos (3 * θ) = Polynomial.eval (Real.cos θ) P :=
fun (v0 : (ℝ))  =>
fun (v1 : (Polynomial ℝ))  =>
fun (v2 : (Polynomial ℝ))  =>
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
fun (s6 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
v1 = (4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X))  =>
fun (s7 : (∀ (v0 : (ℝ)) ,
∀ (v1 : (Polynomial ℝ)) ,
∀ (v2 : (Polynomial ℝ)) ,
let d0 : (Polynomial ℝ) := ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X);
Real.cos (3 * v0) = Polynomial.eval (Real.cos v0) v1))  =>
by
  refine ⟨(4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X, ?_⟩
  intro θ
  exact s7 θ ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X) ((4 : Polynomial ℝ) * Polynomial.X ^ 3 - (3 : Polynomial ℝ) * Polynomial.X)
