import Mathlib

set_option maxHeartbeats 1000000

theorem bmo1_diagnostic_q2 :
  ∀ n : ℕ, 1 ≤ n →
  ((∃ l : List ℤ,
      List.Perm l ((List.range n).map (fun i : ℕ => (i : ℤ) + 1)) ∧
      ∀ x : ℤ, List.foldl (fun y a => a - y) x l + x = 0) ↔
    n % 4 = 3) :=
by
  have h_affine : ∀ (l : List ℤ) (x c : ℤ),
      List.foldl (fun y a => a - y) (x + c) l =
        List.foldl (fun y a => a - y) x l + c * (-1 : ℤ) ^ l.length := by
    intro l
    induction l with
    | nil =>
        intro x c
        simp
    | cons a t ih =>
        intro x c
        simp only [List.foldl_cons, List.length_cons, pow_succ]
        rw [show a - (x + c) = (a - x) + (-c) by ring]
        rw [ih (a - x) (-c)]
        ring
  have h_mod2 : ∀ (l : List ℤ) (y : ℤ), ∃ k : ℤ,
      List.foldl (fun y a => a - y) y l - (y + l.sum) = 2 * k := by
    intro l
    induction l with
    | nil =>
        intro y
        refine ⟨0, ?_⟩
        simp
    | cons a t ih =>
        intro y
        rcases ih (a - y) with ⟨k, hk⟩
        refine ⟨k - y, ?_⟩
        simp only [List.foldl_cons, List.sum_cons]
        calc
          List.foldl (fun y a => a - y) (a - y) t - (y + (a + t.sum))
              = (List.foldl (fun y a => a - y) (a - y) t - ((a - y) + t.sum)) +
                (((a - y) + t.sum) - (y + (a + t.sum))) := by ring
          _ = 2 * k + (((a - y) + t.sum) - (y + (a + t.sum))) := by rw [hk]
          _ = 2 * (k - y) := by ring
  have h_sum_range : ∀ n : ℕ,
      2 * ((List.range n).map (fun i : ℕ => (i : ℤ) + 1)).sum =
        (n : ℤ) * ((n : ℤ) + 1) := by
    intro n
    induction n with
    | zero => simp
    | succ n ih =>
        rw [List.range_succ]
        rw [List.map_append]
        simp only [List.map_cons, List.map_nil, List.sum_append, List.sum_cons, List.sum_nil]
        norm_num [Nat.cast_add, Nat.cast_one]
        nlinarith [ih]
  have hblock_perm_gen : ∀ m : ℕ,
      (([((m : ℤ) + 1), ((m : ℤ) + 2), ((m : ℤ) + 4), ((m : ℤ) + 3)] : List ℤ).Perm
        [((m : ℤ) + 1), ((m : ℤ) + 2), ((m : ℤ) + 3), ((m : ℤ) + 4)]) := by
    intro m
    have hswap : (([((m : ℤ) + 4), ((m : ℤ) + 3)] : List ℤ).Perm
        [((m : ℤ) + 3), ((m : ℤ) + 4)]) := by
      simpa using (List.Perm.swap ((m : ℤ) + 4) ((m : ℤ) + 3) ([] : List ℤ))
    exact ((hswap.cons ((m : ℤ) + 2)).cons ((m : ℤ) + 1))
  have hrange_gen : ∀ m : ℕ,
      (List.range (m + 4)).map (fun i : ℕ => (i : ℤ) + 1) =
        (List.range m).map (fun i : ℕ => (i : ℤ) + 1) ++
          [((m : ℤ) + 1), ((m : ℤ) + 2), ((m : ℤ) + 3), ((m : ℤ) + 4)] := by
    intro m
    rw [show m + 4 = (m + 3) + 1 by omega, List.range_succ]
    rw [show m + 3 = (m + 2) + 1 by omega, List.range_succ]
    rw [show m + 2 = (m + 1) + 1 by omega, List.range_succ]
    rw [List.range_succ]
    simp only [List.map_append, List.map_cons, List.map_nil, List.append_assoc]
    norm_num [Nat.cast_add, Nat.cast_one]
    ring_nf
  intro n hn
  have hiff :
      ((∃ l : List ℤ,
          List.Perm l ((List.range n).map (fun i : ℕ => (i : ℤ) + 1)) ∧
          ∀ x : ℤ, List.foldl (fun y a => a - y) x l + x = 0) ↔
        n % 4 = 3) := by
    constructor
    · intro h
      rcases h with ⟨l, hperm, hzero⟩
      have hlen : l.length = n := by
        simpa using hperm.length_eq
      have hzero0 : List.foldl (fun y a => a - y) (0 : ℤ) l = 0 := by
        have := hzero 0
        simpa using this
      have hcoef : (-1 : ℤ) ^ l.length = -1 := by
        have h1 : List.foldl (fun y a => a - y) (1 : ℤ) l + 1 = 0 := hzero 1
        have hsh := h_affine l 0 1
        have hc : List.foldl (fun y a => a - y) (1 : ℤ) l = (-1 : ℤ) ^ l.length := by
          simpa [hzero0] using hsh
        linarith
      have hodd_len : Odd l.length := by
        rcases Nat.even_or_odd l.length with he | ho
        · have hone : (-1 : ℤ) ^ l.length = 1 := he.neg_one_pow
          linarith
        · exact ho
      have hodd_n : Odd n := by
        simpa [hlen] using hodd_len
      have hsum_even : ∃ k : ℤ, l.sum = 2 * k := by
        rcases h_mod2 l 0 with ⟨k, hk⟩
        refine ⟨-k, ?_⟩
        linarith
      have hsum_eq : l.sum = ((List.range n).map (fun i : ℕ => (i : ℤ) + 1)).sum := by
        exact hperm.sum_eq
      have h2sum : 2 * l.sum = (n : ℤ) * ((n : ℤ) + 1) := by
        calc
          2 * l.sum = 2 * ((List.range n).map (fun i : ℕ => (i : ℤ) + 1)).sum := by rw [hsum_eq]
          _ = (n : ℤ) * ((n : ℤ) + 1) := h_sum_range n
      have h4 : ∃ m : ℤ, (n : ℤ) * ((n : ℤ) + 1) = 4 * m := by
        rcases hsum_even with ⟨s, hs⟩
        refine ⟨s, ?_⟩
        calc
          (n : ℤ) * ((n : ℤ) + 1) = 2 * l.sum := by linarith [h2sum]
          _ = 2 * (2 * s) := by rw [hs]
          _ = 4 * s := by ring
      have hodd_mod2 : n % 2 = 1 := by
        rcases hodd_n with ⟨k, hk⟩
        omega
      have hmod4 : n % 4 = 3 := by
        have hcases : n % 4 = 0 ∨ n % 4 = 1 ∨ n % 4 = 2 ∨ n % 4 = 3 := by
          have hlt : n % 4 < 4 := Nat.mod_lt n (by norm_num)
          omega
        rcases hcases with h0 | h1 | h2 | h3
        · omega
        · have hn_eq : n = 4 * (n / 4) + 1 := by omega
          rcases h4 with ⟨m, hm⟩
          have hz : ((n : ZMod 4) * ((n : ZMod 4) + 1)) = 0 := by
            have hcast : ((((n : ℤ) * ((n : ℤ) + 1) : ℤ) : ZMod 4)) = 0 := by
              rw [hm]
              norm_num
            simpa using hcast
          have hz' : ((((4 * (n / 4) + 1 : ℕ) : ZMod 4)) * ((((4 * (n / 4) + 1 : ℕ) : ZMod 4)) + 1)) = 0 := by
            simpa [hn_eq, Nat.cast_add, Nat.cast_mul, Nat.cast_one] using hz
          have h4z : (4 : ZMod 4) = 0 := by norm_num
          rw [h4z, zero_mul, zero_add] at hz'
          norm_num at hz'
        · omega
        · exact h3
      have source_step_0 : List.Perm l ((List.range n).map (fun i : ℕ => (i : ℤ) + 1)) := hperm
      have source_step_1 : l.length = n := hlen
      have source_step_2 : ∀ x : ℤ,
          List.foldl (fun y a => a - y) (x + 1) l =
            List.foldl (fun y a => a - y) x l + (-1 : ℤ) ^ l.length := by
        intro x
        simpa using h_affine l x 1
      have source_step_3 : (-1 : ℤ) ^ l.length = -1 := hcoef
      have source_step_4 : ∃ k : ℤ, l.sum = 2 * k := hsum_even
      have source_step_5 : ∃ m : ℤ, (n : ℤ) * ((n : ℤ) + 1) = 4 * m := h4
      have source_step_6 : n % 4 = 3 := hmod4
      exact hmod4
    · intro hnmod
      have source_step_7 : n % 4 = 3 := hnmod
      have hex : ∃ k : ℕ, n = 4 * k + 3 := by
        refine ⟨(n - 3) / 4, ?_⟩
        omega
      rcases hex with ⟨k, hk⟩
      have hgen : ∀ k : ℕ, ∃ l : List ℤ,
          List.Perm l ((List.range (4 * k + 3)).map (fun i : ℕ => (i : ℤ) + 1)) ∧
          (∀ x : ℤ, List.foldl (fun y a => a - y) x l + x = 0) := by
        intro k
        induction k with
        | zero =>
            have source_step_8 : ∃ l : List ℤ,
                List.Perm l ((List.range (4 * 0 + 3)).map (fun i : ℕ => (i : ℤ) + 1)) ∧
                (∀ x : ℤ, List.foldl (fun y a => a - y) x l + x = 0) := by
              refine ⟨[(1 : ℤ), 3, 2], ?_, ?_⟩
              · decide
              · intro x
                simp [List.foldl]
                ring
            exact source_step_8
        | succ k ih =>
            rcases ih with ⟨l, hperm, hfold⟩
            let m : ℕ := 4 * k + 3
            let block : List ℤ := [((m : ℤ) + 1), ((m : ℤ) + 2), ((m : ℤ) + 4), ((m : ℤ) + 3)]
            have source_step_9 : List.Perm l ((List.range m).map (fun i : ℕ => (i : ℤ) + 1)) := by
              simpa [m] using hperm
            have source_step_10 : block = [((m : ℤ) + 1), ((m : ℤ) + 2), ((m : ℤ) + 4), ((m : ℤ) + 3)] := rfl
            have source_step_11 : ∀ y : ℤ,
                List.foldl (fun y a => a - y) y block = y := by
              intro y
              dsimp [block]
              simp
              ring
            refine ⟨l ++ block, ?_, ?_⟩
            · have hblock : block.Perm [((m : ℤ) + 1), ((m : ℤ) + 2), ((m : ℤ) + 3), ((m : ℤ) + 4)] := by
                exact hblock_perm_gen m
              have hperm_append : (l ++ block).Perm
                  (((List.range m).map (fun i : ℕ => (i : ℤ) + 1)) ++
                    [((m : ℤ) + 1), ((m : ℤ) + 2), ((m : ℤ) + 3), ((m : ℤ) + 4)]) :=
                source_step_9.append hblock
              have hm : 4 * (k + 1) + 3 = m + 4 := by dsimp [m]; omega
              rw [hm]
              rw [hrange_gen m]
              exact hperm_append
            · intro x
              rw [List.foldl_append]
              have hblock_fold :
                  List.foldl (fun y a => a - y) (List.foldl (fun y a => a - y) x l) block =
                    List.foldl (fun y a => a - y) x l := by
                exact source_step_11 (List.foldl (fun y a => a - y) x l)
              rw [hblock_fold]
              exact hfold x
      have source_step_12 : ∃ l : List ℤ,
          List.Perm l ((List.range (4 * k + 3)).map (fun i : ℕ => (i : ℤ) + 1)) ∧
          (∀ x : ℤ, List.foldl (fun y a => a - y) x l + x = 0) := hgen k
      rw [hk]
      exact source_step_12
  have source_step_13 :
      ((∃ l : List ℤ,
          List.Perm l ((List.range n).map (fun i : ℕ => (i : ℤ) + 1)) ∧
          ∀ x : ℤ, List.foldl (fun y a => a - y) x l + x = 0) ↔
        n % 4 = 3) := hiff
  exact source_step_13
