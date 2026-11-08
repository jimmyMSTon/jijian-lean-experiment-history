import Mathlib
import Jijian

set_option autoImplicit false
set_option Elab.async false

example (a b : ℝ) (h : a = b) : a + 1 = b + 1 := by rw [h]
example : ¬ (∀ x : ℝ, x > 0 → x ^ 2 > x) := by
  intro h
  have bad := h (1 / 2) (by norm_num)
  norm_num at bad
