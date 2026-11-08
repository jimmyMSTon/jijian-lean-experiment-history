import Mathlib
set_option autoImplicit false

-- 原文步骤: s_method
theorem step_0 :
∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
True :=
fun (v0 : (ℕ))  =>
fun (v1 : (ℕ))  =>
by trivial

-- 原文步骤: s_base_empty
theorem step_1 :
∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
(∑ v1 ∈ Finset.range 0, (2 * v1 + 1)) = (0 : ℕ) :=
fun (v0 : (ℕ))  =>
fun (v1 : (ℕ))  =>
by rw [Finset.sum_range_zero]

-- 原文步骤: s_base_right
theorem step_2 :
∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
(0 : ℕ) ^ 2 = 0 :=
fun (v0 : (ℕ))  =>
fun (v1 : (ℕ))  =>
by norm_num

-- 原文步骤: s_base_conclusion
theorem step_3 :
∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
∀ (s1 : (∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
(∑ v1 ∈ Finset.range 0, (2 * v1 + 1)) = (0 : ℕ))) ,
∀ (s2 : (∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
(0 : ℕ) ^ 2 = 0)) ,
(∑ v1 ∈ Finset.range 0, (2 * v1 + 1)) = (0 : ℕ) ^ 2 :=
fun (v0 : (ℕ))  =>
fun (v1 : (ℕ))  =>
fun (s1 : (∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
(∑ v1 ∈ Finset.range 0, (2 * v1 + 1)) = (0 : ℕ)))  =>
fun (s2 : (∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
(0 : ℕ) ^ 2 = 0))  =>
by rw [s1 v0 v1, s2 v0 v1]

-- 原文步骤 s_consider_n_plus_1 尚无可验证证明片段

-- 原文步骤: s_sum_rewrite
theorem step_5 :
∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
∀ (h0 : ((∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) = v0 ^ 2)) ,
(∑ v1 ∈ Finset.range (v0 + 1), (2 * v1 + 1)) = (∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) + (2 * v0 + 1) :=
fun (v0 : (ℕ))  =>
fun (v1 : (ℕ))  =>
fun (h0 : ((∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) = v0 ^ 2))  =>
by rw [Finset.sum_range_succ (fun k => 2 * k + 1) v0]

-- 原文步骤: s_apply_IH
theorem step_6 :
∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
∀ (h0 : ((∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) = v0 ^ 2)) ,
∀ (s5 : (∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
∀ (h0 : ((∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) = v0 ^ 2)) ,
(∑ v1 ∈ Finset.range (v0 + 1), (2 * v1 + 1)) = (∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) + (2 * v0 + 1))) ,
(∑ v1 ∈ Finset.range (v0 + 1), (2 * v1 + 1)) = v0 ^ 2 + 2 * v0 + 1 :=
fun (v0 : (ℕ))  =>
fun (v1 : (ℕ))  =>
fun (h0 : ((∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) = v0 ^ 2))  =>
fun (s5 : (∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
∀ (h0 : ((∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) = v0 ^ 2)) ,
(∑ v1 ∈ Finset.range (v0 + 1), (2 * v1 + 1)) = (∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) + (2 * v0 + 1)))  =>
by rw [s5 v0 v1 h0, h0]; ring

-- 原文步骤: s_simplify
theorem step_7 :
∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
∀ (h0 : ((∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) = v0 ^ 2)) ,
∀ (s6 : (∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
∀ (h0 : ((∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) = v0 ^ 2)) ,
(∑ v1 ∈ Finset.range (v0 + 1), (2 * v1 + 1)) = v0 ^ 2 + 2 * v0 + 1)) ,
v0 ^ 2 + 2 * v0 + 1 = (v0 + 1) ^ 2 :=
fun (v0 : (ℕ))  =>
fun (v1 : (ℕ))  =>
fun (h0 : ((∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) = v0 ^ 2))  =>
fun (s6 : (∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
∀ (h0 : ((∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) = v0 ^ 2)) ,
(∑ v1 ∈ Finset.range (v0 + 1), (2 * v1 + 1)) = v0 ^ 2 + 2 * v0 + 1))  =>
by ring

-- 原文步骤: s_ind_conclusion
theorem step_8 :
∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
∀ (h0 : ((∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) = v0 ^ 2)) ,
∀ (s6 : (∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
∀ (h0 : ((∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) = v0 ^ 2)) ,
(∑ v1 ∈ Finset.range (v0 + 1), (2 * v1 + 1)) = v0 ^ 2 + 2 * v0 + 1)) ,
∀ (s7 : (∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
∀ (h0 : ((∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) = v0 ^ 2)) ,
v0 ^ 2 + 2 * v0 + 1 = (v0 + 1) ^ 2)) ,
(∑ v1 ∈ Finset.range (v0 + 1), (2 * v1 + 1)) = (v0 + 1) ^ 2 :=
fun (v0 : (ℕ))  =>
fun (v1 : (ℕ))  =>
fun (h0 : ((∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) = v0 ^ 2))  =>
fun (s6 : (∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
∀ (h0 : ((∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) = v0 ^ 2)) ,
(∑ v1 ∈ Finset.range (v0 + 1), (2 * v1 + 1)) = v0 ^ 2 + 2 * v0 + 1))  =>
fun (s7 : (∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
∀ (h0 : ((∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) = v0 ^ 2)) ,
v0 ^ 2 + 2 * v0 + 1 = (v0 + 1) ^ 2))  =>
by rw [s6 v0 v1 h0, s7 v0 v1 h0]

-- 原文步骤: s_final_induction_conclusion
theorem step_9 :
∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
∀ (s0 : (∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
True)) ,
∀ (s3 : (∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
(∑ v1 ∈ Finset.range 0, (2 * v1 + 1)) = (0 : ℕ) ^ 2)) ,
∀ (s8 : (∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
∀ (h0 : ((∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) = v0 ^ 2)) ,
(∑ v1 ∈ Finset.range (v0 + 1), (2 * v1 + 1)) = (v0 + 1) ^ 2)) ,
∀ v0 : ℕ, (∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) = v0 ^ 2 :=
fun (v0 : (ℕ))  =>
fun (v1 : (ℕ))  =>
fun (s0 : (∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
True))  =>
fun (s3 : (∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
(∑ v1 ∈ Finset.range 0, (2 * v1 + 1)) = (0 : ℕ) ^ 2))  =>
fun (s8 : (∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
∀ (h0 : ((∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) = v0 ^ 2)) ,
(∑ v1 ∈ Finset.range (v0 + 1), (2 * v1 + 1)) = (v0 + 1) ^ 2))  =>
by
  intro n
  induction n with
  | zero => simpa using s3 v0 v1
  | succ n ih => simpa using s8 n v1 ih

-- 原文步骤: g_main
theorem step_10 :
∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
∀ (s9 : (∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
∀ v0 : ℕ, (∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) = v0 ^ 2)) ,
∀ v0 : ℕ, (∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) = v0 ^ 2 :=
fun (v0 : (ℕ))  =>
fun (v1 : (ℕ))  =>
fun (s9 : (∀ (v0 : (ℕ)) ,
∀ (v1 : (ℕ)) ,
∀ v0 : ℕ, (∑ v1 ∈ Finset.range v0, (2 * v1 + 1)) = v0 ^ 2))  =>
by exact s9 v0 v1
