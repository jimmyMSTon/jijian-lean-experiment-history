import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic.NormNum

-- Conditional diagnostic for the literal reading with a leading 2.
-- This does not choose an OCR reading or prove the user's complete theorem.
theorem original_blue_formula_fails_at_zero (k : ℕ) :
    (2 : ℝ) * Real.cos (((k : ℝ) + 2) * 0) ≠
      2 * Real.cos 0 * Real.cos (((k : ℝ) + 1) * 0) - Real.cos ((k : ℝ) * 0) := by
  norm_num
