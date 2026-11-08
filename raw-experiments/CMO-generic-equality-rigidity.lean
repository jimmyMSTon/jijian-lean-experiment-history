import Mathlib
set_option autoImplicit false
set_option maxHeartbeats 800000

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
