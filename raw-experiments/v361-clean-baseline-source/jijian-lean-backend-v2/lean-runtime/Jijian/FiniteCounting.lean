import Mathlib
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


namespace Jijian.GenericCounting

-- Rigidity of a finite nonnegative sum at its cardinality lower bound.
theorem sum_equals_card_rigidity {α : Type*} [Fintype α]
    (s : Finset α) (f : α → ℝ)
    (hnonneg : ∀ i : α, 0 ≤ f i)
    (hge : ∀ i ∈ s, 1 ≤ f i)
    (hsum : (∑ i : α, f i) = (s.card : ℝ)) :
    (∀ i ∈ s, f i = 1) ∧ (∀ i ∉ s, f i = 0) := by
  classical
  have hcard : (s.card : ℝ) = (∑ _i ∈ s, (1 : ℝ)) := by simp
  have hlo : (s.card : ℝ) ≤ ∑ i ∈ s, f i := by
    rw [hcard]
    exact Finset.sum_le_sum (fun i hi => hge i hi)
  have hhi : (∑ i ∈ s, f i) ≤ ∑ i : α, f i :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ s)
      (by intro i hi hnot; exact hnonneg i)
  have heq : (∑ i ∈ s, f i) = (s.card : ℝ) := by linarith
  have hones : ∀ i ∈ s, f i = 1 := by
    have hh : (∑ _i ∈ s, (1 : ℝ)) = (∑ i ∈ s, f i) := by rw [← hcard, heq]
    have heach := (Finset.sum_eq_sum_iff_of_le (fun i hi => hge i hi)).mp hh
    intro i hi
    exact (heach i hi).symm
  have htailzero : (∑ i ∈ Finset.univ \ s, f i) = 0 := by
    have he := Finset.sum_sdiff (Finset.subset_univ s) (f := f)
    linarith
  have htail : ∀ i ∈ Finset.univ \ s, f i = 0 :=
    (Finset.sum_eq_zero_iff_of_nonneg
      (fun i hi => hnonneg i)).mp htailzero
  constructor
  · exact hones
  · intro i hi
    exact htail i (Finset.mem_sdiff.mpr ⟨Finset.mem_univ _, hi⟩)
end Jijian.GenericCounting
