import Mathlib
set_option autoImplicit false
set_option Elab.async false

-- 0: mod_nat
theorem jj_elementary_0 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((v_n % v_m) = (v_n % v_m))))))))))))))))) := by
  intros
  rfl

-- 1: mod_int
theorem jj_elementary_1 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((v_i % v_j) = (v_i % v_j))))))))))))))))) := by
  intros
  rfl

-- 2: divides
theorem jj_elementary_2 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((v_n ∣ v_m) ↔ (v_n ∣ v_m))))))))))))))))) := by
  intros
  rfl

-- 3: gcd
theorem jj_elementary_3 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Nat.gcd v_n v_m) = (Nat.gcd v_n v_m))))))))))))))))) := by
  intros
  rfl

-- 4: lcm
theorem jj_elementary_4 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Nat.lcm v_n v_m) = (Nat.lcm v_n v_m))))))))))))))))) := by
  intros
  rfl

-- 5: choose
theorem jj_elementary_5 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Nat.choose v_n v_m) = (Nat.choose v_n v_m))))))))))))))))) := by
  intros
  rfl

-- 6: coprime
theorem jj_elementary_6 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Nat.Coprime v_n v_m) ↔ (Nat.Coprime v_n v_m))))))))))))))))) := by
  intros
  rfl

-- 7: factorial
theorem jj_elementary_7 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Nat.factorial v_n) = (Nat.factorial v_n))))))))))))))))) := by
  intros
  rfl

-- 8: prime
theorem jj_elementary_8 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Nat.Prime v_n) ↔ (Nat.Prime v_n))))))))))))))))) := by
  intros
  rfl

-- 9: even
theorem jj_elementary_9 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Even v_n) ↔ (Even v_n))))))))))))))))) := by
  intros
  rfl

-- 10: odd
theorem jj_elementary_10 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Odd v_i) ↔ (Odd v_i))))))))))))))))) := by
  intros
  rfl

-- 11: nat_abs
theorem jj_elementary_11 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Int.natAbs v_i) = (Int.natAbs v_i))))))))))))))))) := by
  intros
  rfl

-- 12: min_real
theorem jj_elementary_12 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((min v_r v_s) = (min v_r v_s))))))))))))))))) := by
  intros
  rfl

-- 13: max_real
theorem jj_elementary_13 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((max v_r v_s) = (max v_r v_s))))))))))))))))) := by
  intros
  rfl

-- 14: abs_real
theorem jj_elementary_14 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((abs v_r) = (abs v_r))))))))))))))))) := by
  intros
  rfl

-- 15: sqrt
theorem jj_elementary_15 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Real.sqrt v_r) = (Real.sqrt v_r))))))))))))))))) := by
  intros
  rfl

-- 16: exp
theorem jj_elementary_16 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Real.exp v_r) = (Real.exp v_r))))))))))))))))) := by
  intros
  rfl

-- 17: log
theorem jj_elementary_17 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Real.log v_r) = (Real.log v_r))))))))))))))))) := by
  intros
  rfl

-- 18: tan
theorem jj_elementary_18 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Real.tan v_r) = (Real.tan v_r))))))))))))))))) := by
  intros
  rfl

-- 19: floor
theorem jj_elementary_19 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Int.floor v_r) = (Int.floor v_r))))))))))))))))) := by
  intros
  rfl

-- 20: ceil
theorem jj_elementary_20 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Int.ceil v_r) = (Int.ceil v_r))))))))))))))))) := by
  intros
  rfl

-- 21: compose
theorem jj_elementary_21 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Function.comp v_a v_b) = (Function.comp v_a v_b))))))))))))))))) := by
  intros
  rfl

-- 22: set_mem
theorem jj_elementary_22 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((v_n ∈ v_S) ↔ (v_n ∈ v_S))))))))))))))))) := by
  intros
  rfl

-- 23: set_subset
theorem jj_elementary_23 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((v_S ⊆ v_T) ↔ (v_S ⊆ v_T))))))))))))))))) := by
  intros
  rfl

-- 24: set_union
theorem jj_elementary_24 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((v_S ∪ v_T) = (v_S ∪ v_T))))))))))))))))) := by
  intros
  rfl

-- 25: set_inter
theorem jj_elementary_25 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((v_S ∩ v_T) = (v_S ∩ v_T))))))))))))))))) := by
  intros
  rfl

-- 26: set_diff
theorem jj_elementary_26 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((v_S \ v_T) = (v_S \ v_T))))))))))))))))) := by
  intros
  rfl

-- 27: set_compl
theorem jj_elementary_27 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Set.compl v_S) = (Set.compl v_S))))))))))))))))) := by
  intros
  rfl

-- 28: set_empty
theorem jj_elementary_28 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), (((∅ : (Set ℕ)) : (Set ℕ)) = ((∅ : (Set ℕ)) : (Set ℕ)))))))))))))))))) := by
  intros
  rfl

-- 29: set_univ
theorem jj_elementary_29 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), (((Set.univ : (Set ℕ)) : (Set ℕ)) = ((Set.univ : (Set ℕ)) : (Set ℕ)))))))))))))))))) := by
  intros
  rfl

-- 30: set_singleton
theorem jj_elementary_30 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), (({v_n} : Set ℕ) = ({v_n} : Set ℕ))))))))))))))))) := by
  intros
  rfl

-- 31: set_insert
theorem jj_elementary_31 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Set.insert v_n v_S) = (Set.insert v_n v_S))))))))))))))))) := by
  intros
  rfl

-- 32: set_image
theorem jj_elementary_32 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Set.image v_a v_S) = (Set.image v_a v_S))))))))))))))))) := by
  intros
  rfl

-- 33: set_preimage
theorem jj_elementary_33 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Set.preimage v_a v_U) = (Set.preimage v_a v_U))))))))))))))))) := by
  intros
  rfl

-- 34: set_finite
theorem jj_elementary_34 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Set.Finite v_S) ↔ (Set.Finite v_S))))))))))))))))) := by
  intros
  rfl

-- 35: set_infinite
theorem jj_elementary_35 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Set.Infinite v_S) ↔ (Set.Infinite v_S))))))))))))))))) := by
  intros
  rfl

-- 36: finset_mem
theorem jj_elementary_36 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((v_n ∈ v_F) ↔ (v_n ∈ v_F))))))))))))))))) := by
  intros
  rfl

-- 37: finset_card
theorem jj_elementary_37 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Finset.card v_F) = (Finset.card v_F))))))))))))))))) := by
  intros
  rfl

-- 38: finset_empty
theorem jj_elementary_38 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), (((∅ : (Finset ℕ)) : (Finset ℕ)) = ((∅ : (Finset ℕ)) : (Finset ℕ)))))))))))))))))) := by
  intros
  rfl

-- 39: finset_sum
theorem jj_elementary_39 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Finset.sum v_F v_b) = (Finset.sum v_F v_b))))))))))))))))) := by
  intros
  rfl

-- 40: finset_prod
theorem jj_elementary_40 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_k : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((Finset.prod v_F v_b) = (Finset.prod v_F v_b))))))))))))))))) := by
  intros
  rfl

-- 41: finite_prod
theorem jj_elementary_41 : (∀ (v_n : ℕ), (∀ (v_m : ℕ), (∀ (v_i : ℤ), (∀ (v_j : ℤ), (∀ (v_q : ℚ), (∀ (v_r : ℝ), (∀ (v_s : ℝ), (∀ (v_a : (ℕ → ℝ)), (∀ (v_b : (ℕ → ℕ)), (∀ (v_pred : (ℕ → Prop)), (∀ (v_S : (Set ℕ)), (∀ (v_T : (Set ℕ)), (∀ (v_U : (Set ℝ)), (∀ (v_F : (Finset ℕ)), ((∏ v_k ∈ Finset.Icc (0 : ℕ) (5 : ℕ), v_k) = (∏ v_k ∈ Finset.Icc (0 : ℕ) (5 : ℕ), v_k)))))))))))))))) := by
  intros
  rfl

