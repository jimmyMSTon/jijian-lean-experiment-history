import Mathlib
set_option autoImplicit false
set_option maxRecDepth 2048

private def badMatrix : Matrix (Fin 3) (Fin 3) (ZMod 2) :=
  fun i j => if i.val = 0 ∧ j.val < 2 then 1 else 0

private def rowParity (X : Matrix (Fin 3) (Fin 3) (ZMod 2)) (i : Fin 3) : ZMod 2 :=
  ∑ j : Fin 3, X i j

private def oneCount (X : Matrix (Fin 3) (Fin 3) (ZMod 2)) : ℕ :=
  (Finset.univ.filter (fun p : Fin 3 × Fin 3 => X p.1 p.2 = (1 : ZMod 2))).card

-- This is the exact missing-column-premise pattern in the saved CMO scaffold.
theorem cmo2018P5_sourceStep18_generated_statement_is_false :
    ¬ (∀ (Y : Matrix (Fin 3) (Fin 3) (ZMod 2)),
         (∀ i : Fin 3, rowParity (badMatrix + Y) i = 0) →
         3 - 1 ≤ oneCount Y) := by
  intro h
  have hr : ∀ i : Fin 3, rowParity (badMatrix + (0 : Matrix (Fin 3) (Fin 3) (ZMod 2))) i = 0 := by
    decide
  have hc : oneCount (0 : Matrix (Fin 3) (Fin 3) (ZMod 2)) = 0 := by
    decide
  have hbound := h 0 hr
  simp only [hc] at hbound
  omega

#print axioms cmo2018P5_sourceStep18_generated_statement_is_false
