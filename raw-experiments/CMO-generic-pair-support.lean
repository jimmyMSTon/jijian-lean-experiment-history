import Mathlib
import Jijian.FiniteCounting
set_option maxHeartbeats 800000
set_option autoImplicit false

namespace Jijian.GenericCounting

theorem symmetric_support_pairs {α : Type*} [Fintype α] [LinearOrder α]
    (s : Finset α) :
    2 * (Finset.univ.filter (fun q : α × α => q.1 ≤ q.2 ∧ q.1 ∈ s ∧ q.2 ∈ s)).card =
    s.card * s.card + s.card := by
  classical
  have hsym : ∀ i j : α, (i ∈ s ∧ j ∈ s) ↔ (j ∈ s ∧ i ∈ s) := by
    intro i j
    exact and_comm
  have h := symmetric_filtered_pairs (fun i j : α => i ∈ s ∧ j ∈ s) hsym
  have hpairs : (Finset.univ.filter (fun q : α × α => q.1 ∈ s ∧ q.2 ∈ s)) = s.product s := by
    ext q
    simp [Finset.mem_product]
  have hdiag : (Finset.univ.filter (fun i : α => i ∈ s ∧ i ∈ s)) = s := by
    ext i
    simp
  have hcardprod : (s.product s).card = s.card * s.card := by simpa using Finset.card_product s s
  rw [hpairs, hcardprod, hdiag] at h
  exact h

end Jijian.GenericCounting
