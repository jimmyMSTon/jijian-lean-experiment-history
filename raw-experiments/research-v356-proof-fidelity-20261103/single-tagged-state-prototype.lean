import Mathlib
example (p n : ℕ) (hp : Nat.Prime p) (hn : 1 < n) : 1 < n := by
  run_tac do
    let goal ← Lean.Elab.Tactic.getMainGoal
    Lean.logInfo m!"JJ_SOURCE_STEP_CONTEXT_37\n{goal}"
  exact hn
