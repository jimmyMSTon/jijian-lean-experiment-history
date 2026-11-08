import Mathlib
set_option maxHeartbeats 1000000
set_option autoImplicit false

namespace Jijian.GenericCounting

variable {α : Type*} [Fintype α] [LinearOrder α]

private def allCount (P : α → α → Prop) [DecidableRel P] : ℕ :=
  ∑ i : α, ∑ j : α, if P i j then 1 else 0
private def upperCount (P : α → α → Prop) [DecidableRel P] : ℕ :=
  ∑ i : α, ∑ j : α, if i ≤ j ∧ P i j then 1 else 0
private def diagCount (P : α → α → Prop) [DecidableRel P] : ℕ :=
  ∑ i : α, if P i i then 1 else 0
private def lowerCount (P : α → α → Prop) [DecidableRel P] : ℕ :=
  ∑ i : α, ∑ j : α, if j < i ∧ P i j then 1 else 0

private theorem split_all (P : α → α → Prop) [DecidableRel P] :
   allCount P = upperCount P + lowerCount P := by
  unfold allCount upperCount lowerCount
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i hi
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro j hj
  by_cases hp : P i j <;> by_cases hij : i ≤ j <;> simp [hp, hij]

private theorem swap_lower (P : α → α → Prop) [DecidableRel P]
    (hsym : ∀ i j, P i j ↔ P j i) :
    lowerCount P = (∑ i : α, ∑ j : α, if i < j ∧ P i j then 1 else 0) := by
  unfold lowerCount
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro i hi
  apply Finset.sum_congr rfl
  intro j hj
  simp only [hsym i j]

private theorem split_upper (P : α → α → Prop) [DecidableRel P] :
    upperCount P = (∑ i : α, ∑ j : α, if i < j ∧ P i j then 1 else 0) + diagCount P := by
  unfold upperCount diagCount
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i hi
  have hdiagonal : (∑ j : α, if i = j ∧ P i j then (1:ℕ) else 0) =
      (if P i i then 1 else 0) := by
    calc
      (∑ j : α, if i = j ∧ P i j then (1:ℕ) else 0) =
          ∑ j : α, if j = i then (if P i i then 1 else 0) else 0 := by
            apply Finset.sum_congr rfl
            intro j _
            by_cases h : j = i
            · subst j; simp
            · simp [h, Ne.symm h]
      _ = _ := by simp
  rw [← hdiagonal, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro j hj
  by_cases hp : P i j
  · rcases lt_trichotomy i j with h | h | h
    · simp [hp, h.le, h.ne]; exact h
    · subst j; simp [hp]
    · simp [hp, not_le_of_gt h, h.ne']; exact h.le
  · simp [hp]

theorem symmetric_double_count (P : α → α → Prop) [DecidableRel P]
    (hsym : ∀ i j, P i j ↔ P j i) :
    2 * upperCount P = allCount P + diagCount P := by
  rw [split_all, split_upper, swap_lower P hsym]
  omega

end Jijian.GenericCounting

namespace Jijian.GenericCounting

variable {β : Type*} [Fintype β] [LinearOrder β]

theorem symmetric_filtered_pairs (P : β → β → Prop) [DecidableRel P]
    (hsym : ∀ i j, P i j ↔ P j i) :
    2 * (Finset.univ.filter (fun q : β × β => q.1 ≤ q.2 ∧ P q.1 q.2)).card =
    (Finset.univ.filter (fun q : β × β => P q.1 q.2)).card +
    (Finset.univ.filter (fun i : β => P i i)).card := by
  have hh := symmetric_double_count P hsym
  unfold upperCount allCount diagCount at hh
  classical
  simpa only [Fintype.sum_prod_type, Finset.card_filter] using hh

theorem card_subtype_as_filter {γ : Type*} [Fintype γ] (P : γ → Prop) [DecidablePred P] :
    Nat.card {x : γ // P x} = (Finset.univ.filter P).card := by
  classical
  simp [Nat.card_eq_fintype_card, Fintype.card_subtype]

end Jijian.GenericCounting
