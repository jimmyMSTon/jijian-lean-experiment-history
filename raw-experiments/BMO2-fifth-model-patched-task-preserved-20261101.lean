import Mathlib
import Jijian.FiniteCounting
import Jijian.FiniteSums
set_option autoImplicit false
set_option Elab.async false
def JijianLockedProp_42d387765f657a4b1882319e : Prop := (Set.ncard ({v : ℕ → ℕ | (∀ n : ℕ, 0 < v n) ∧ (v 0 = 1) ∧ (∀ n : ℕ, 2 ≤ n → (v n : ℚ) = (((v (n - 1) : ℚ) ^ 2 + (v (n - 1) : ℚ) + 1) ^ 2025) / (v (n - 2) : ℚ))} : Set (ℕ → ℕ)) = 2026)
theorem JijianAuthorStep_1 : (∀ (a x y z e : ℕ), y = (x ^ 2 + a * x + 1) ^ e → z * x = (y ^ 2 + a * y + 1) ^ e → x ∣ (a + 2) ^ e) :=
by
  intro a x y z e hy hz
  have hx0 : (x : ZMod x) = 0 := ZMod.natCast_self x
  have hy1 : (y : ZMod x) = 1 := by
    rw [hy]
    rw [Nat.cast_pow]
    have hbase : ((x ^ 2 + a * x + 1 : ℕ) : ZMod x) = 1 := by
      rw [Nat.cast_add, Nat.cast_add, Nat.cast_mul, Nat.cast_pow, hx0]
      simp
    rw [hbase, one_pow]
  have hz0 : ((((y ^ 2 + a * y + 1 : ℕ) : ZMod x)) ^ e) = 0 := by
    have h := congrArg (fun n : ℕ => (n : ZMod x)) hz
    simpa [Nat.cast_mul, Nat.cast_pow, hx0] using h.symm
  have hbase2 : (((y ^ 2 + a * y + 1 : ℕ) : ZMod x)) = ((a + 2 : ℕ) : ZMod x) := by
    calc
      (((y ^ 2 + a * y + 1 : ℕ) : ZMod x))
          = (y : ZMod x)^2 + (a : ZMod x)*(y : ZMod x) + 1 := by
              push_cast
              ring
      _ = (1 : ZMod x)^2 + (a : ZMod x)*1 + 1 := by rw [hy1]
      _ = (a : ZMod x) + 1 + 1 := by ring
      _ = ((a + 2 : ℕ) : ZMod x) := by
              rw [Nat.cast_add]
              norm_num
              ring
  have hpow : (((a + 2 : ℕ) : ZMod x) ^ e) = 0 := by
    rw [← hbase2]
    exact hz0
  have hpowNat : (((a + 2) ^ e : ℕ) : ZMod x) = 0 := by
    simpa [Nat.cast_pow] using hpow
  exact (ZMod.natCast_eq_zero_iff ((a + 2) ^ e) x).mp hpowNat


theorem JijianAuthorStep_3 : (∀ (a b c d e : ℕ), b * d = (c ^ 2 + a * c + 1) ^ e → c ∣ (b ^ 2 + a * b + 1) ^ e → c ∣ (d ^ 2 + a * d + 1) ^ e) :=
by
  intro a b c d e hprod hdiv
  by_cases hc0 : c = 0
  · subst c
    rcases hdiv with ⟨k, hk⟩
    have hN0 : (b ^ 2 + a * b + 1) ^ e = 0 := by simpa using hk
    have hbase : 0 < b ^ 2 + a * b + 1 := by
      exact Nat.succ_pos (b ^ 2 + a * b)
    have hpowpos : 0 < (b ^ 2 + a * b + 1) ^ e := pow_pos hbase e
    have hne : (b ^ 2 + a * b + 1) ^ e ≠ 0 := ne_of_gt hpowpos
    exact False.elim (hne hN0)
  · let Fd : ZMod c := (d : ZMod c) ^ 2 + (a : ZMod c) * (d : ZMod c) + 1
    let Fb : ZMod c := (b : ZMod c) ^ 2 + (a : ZMod c) * (b : ZMod c) + 1
    have hbdZ : (b : ZMod c) * (d : ZMod c) = 1 := by
      have hcast := congrArg (fun n : ℕ => (n : ZMod c)) hprod
      have hbaseZ : ((c ^ 2 + a * c + 1 : ℕ) : ZMod c) = 1 := by
        have hc : (c : ZMod c) = 0 := ZMod.natCast_self c
        simp [Nat.cast_add, Nat.cast_mul, Nat.cast_pow, hc]
      calc
        (b : ZMod c) * (d : ZMod c) = ((b * d : ℕ) : ZMod c) := by rw [Nat.cast_mul]
        _ = ((c ^ 2 + a * c + 1 : ℕ) : ZMod c) ^ e := by
          simpa [Nat.cast_pow] using hcast
        _ = (1 : ZMod c) ^ e := by rw [hbaseZ]
        _ = 1 := by simp
    have hzeroZ : Fb ^ e = 0 := by
      have hz : (((b ^ 2 + a * b + 1 : ℕ) ^ e : ℕ) : ZMod c) = 0 :=
        (ZMod.natCast_eq_zero_iff ((b ^ 2 + a * b + 1) ^ e) c).2 hdiv
      simpa [Fb, Nat.cast_add, Nat.cast_mul, Nat.cast_pow] using hz
    have hF : (b : ZMod c) ^ 2 * Fd = Fb := by
      dsimp [Fd, Fb]
      calc
        (b : ZMod c) ^ 2 * ((d : ZMod c) ^ 2 + (a : ZMod c) * (d : ZMod c) + 1)
            = ((b : ZMod c) * (d : ZMod c)) ^ 2
                + (a : ZMod c) * ((b : ZMod c) * (d : ZMod c)) * (b : ZMod c)
                + (b : ZMod c) ^ 2 := by ring
        _ = 1 ^ 2 + (a : ZMod c) * 1 * (b : ZMod c) + (b : ZMod c) ^ 2 := by rw [hbdZ]
        _ = (b : ZMod c) ^ 2 + (a : ZMod c) * (b : ZMod c) + 1 := by ring
    have hFd0 : Fd ^ e = 0 := by
      have h1 : (((b : ZMod c) ^ 2) * Fd) ^ e = 0 := by
        rw [hF, hzeroZ]
      have h2 : (b : ZMod c) ^ (2 * e) * Fd ^ e = 0 := by
        simpa [mul_pow, pow_mul] using h1
      have h3 : (d : ZMod c) ^ (2 * e) *
          ((b : ZMod c) ^ (2 * e) * Fd ^ e) = 0 := by
        rw [h2, mul_zero]
      have hdb : (d : ZMod c) ^ (2 * e) * (b : ZMod c) ^ (2 * e) = 1 := by
        rw [← mul_pow]
        rw [mul_comm (d : ZMod c) (b : ZMod c), hbdZ, one_pow]
      rw [← mul_assoc, hdb, one_mul] at h3
      exact h3
    have htargetZ : (((d ^ 2 + a * d + 1 : ℕ) ^ e : ℕ) : ZMod c) = 0 := by
      simpa [Fd, Nat.cast_add, Nat.cast_mul, Nat.cast_pow] using hFd0
    exact (ZMod.natCast_eq_zero_iff ((d ^ 2 + a * d + 1) ^ e) c).1 htargetZ

def Phi (n : ℕ) : ℕ := n ^ 2 + n + 1

def JijianStep (p : ℕ × ℕ) : ℕ × ℕ :=
  (p.2, (Phi p.2) ^ 2025 / p.1)

def JijianState (j : ℕ) : ℕ → ℕ × ℕ
  | 0 => (1, 3 ^ j)
  | n + 1 => JijianStep (JijianState j n)

def seq (j n : ℕ) : ℕ := (JijianState j n).1

@[simp] lemma seq_zero (j : ℕ) : seq j 0 = 1 := by
  rfl

@[simp] lemma seq_one (j : ℕ) : seq j 1 = 3 ^ j := by
  rfl

lemma seq_add_two (j n : ℕ) :
    seq j (n + 2) =
      (((seq j (n + 1)) ^ 2 + seq j (n + 1) + 1) ^ 2025) / seq j n := by
  rfl

lemma pow3_injective {a b : ℕ} (h : 3 ^ a = 3 ^ b) : a = b := by
  wlog hle : a ≤ b generalizing a b with H
  · exact (H h.symm (le_of_not_ge hle)).symm
  rcases Nat.exists_eq_add_of_le hle with ⟨d, rfl⟩
  have h' : 3 ^ a * 1 = 3 ^ a * 3 ^ d := by
    simpa [pow_add] using h
  have h3a : 0 < 3 ^ a := pow_pos (by norm_num) a
  have hd : 1 = 3 ^ d := Nat.eq_of_mul_eq_mul_left h3a h'
  cases d with
  | zero => rfl
  | succ d =>
      have hge : 3 ≤ 3 ^ (d + 1) := by
        rw [pow_succ]
        have hpos1 : 1 ≤ 3 ^ d := Nat.succ_le_of_lt (pow_pos (by norm_num) d)
        nlinarith
      omega

lemma natCast_div_of_dvd {a b : ℕ} (hb : b ∣ a) (hbn : b ≠ 0) :
    ((a / b : ℕ) : ℚ) = (a : ℚ) / (b : ℚ) := by
  have hmul : (a / b) * b = a := Nat.div_mul_cancel hb
  have hcast : (((a / b : ℕ) : ℚ) * (b : ℚ)) = (a : ℚ) := by
    exact_mod_cast hmul
  have hbq : (b : ℚ) ≠ 0 := by exact_mod_cast hbn
  calc
    ((a / b : ℕ) : ℚ) = (((a / b : ℕ) : ℚ) * (b : ℚ)) / (b : ℚ) := by
      field_simp [hbq]
    _ = (a : ℚ) / (b : ℚ) := by rw [hcast]

def GoodDiv (j n : ℕ) : Prop :=
  seq j n ∣ Phi (seq j (n + 1)) ^ 2025

lemma D_one (j : ℕ) (hj : j ≤ 2025) : GoodDiv j 1 := by
  dsimp [GoodDiv]
  rw [seq_one]
  have hseq2 : seq j 2 = Phi (3 ^ j) ^ 2025 := by
    rw [show 2 = 0 + 2 by norm_num, seq_add_two]
    simp [seq_zero, Phi]
  rw [hseq2]
  let m := 3 ^ j
  have hm_dvd : m ∣ 3 ^ 2025 := by
    dsimp [m]
    exact pow_dvd_pow 3 hj
  have hm0 : (m : ZMod m) = 0 := ZMod.natCast_self m
  have hFm : ((Phi m : ℕ) : ZMod m) = 1 := by
    dsimp [Phi]
    push_cast
    rw [hm0]
    norm_num
  have hseq2mod : (((Phi m) ^ 2025 : ℕ) : ZMod m) = 1 := by
    rw [Nat.cast_pow, hFm, one_pow]
  have hQ : (((m : ZMod m) ^ 2 + (m : ZMod m) + 1) ^ 2025) = 1 := by
    simpa [Phi, Nat.cast_pow] using hseq2mod
  have hFseqmod : ((Phi ((Phi m) ^ 2025) : ℕ) : ZMod m) = 3 := by
    dsimp [Phi]
    push_cast
    rw [hQ]
    norm_num
  have htarget : (((Phi ((Phi m) ^ 2025)) ^ 2025 : ℕ) : ZMod m) = 0 := by
    rw [Nat.cast_pow, hFseqmod]
    have h3 : (((3 ^ 2025 : ℕ) : ZMod m) = 0) :=
      (ZMod.natCast_eq_zero_iff (3 ^ 2025) m).2 hm_dvd
    simpa only [Nat.cast_pow] using h3
  done
  change m ∣ Phi ((Phi m) ^ 2025) ^ 2025
  exact (ZMod.natCast_eq_zero_iff _ m).1 htarget

lemma D_all (j : ℕ) (hj : j ≤ 2025) : ∀ n, GoodDiv j n := by
  intro n
  induction n using Nat.strong_induction_on with
  | h n ih =>
    by_cases h0 : n = 0
    · subst n
      dsimp [GoodDiv]
      simp
    · by_cases h1 : n = 1
      · subst n
        exact D_one j hj
      · have hn2 : 2 ≤ n := by omega
        have hD1 : seq j (n - 1) ∣ Phi (seq j n) ^ 2025 := by
          have h := ih (n - 1) (by omega)
          change seq j (n - 1) ∣ Phi (seq j ((n - 1) + 1)) ^ 2025 at h
          rw [show (n - 1) + 1 = n by omega] at h
          exact h
        have hD2 : seq j (n - 2) ∣ Phi (seq j (n - 1)) ^ 2025 := by
          have h := ih (n - 2) (by omega)
          change seq j (n - 2) ∣ Phi (seq j ((n - 2) + 1)) ^ 2025 at h
          rw [show (n - 2) + 1 = n - 1 by omega] at h
          exact h
        have hd : seq j (n + 1) = Phi (seq j n) ^ 2025 / seq j (n - 1) := by
          rw [show n + 1 = (n - 1) + 2 by omega, seq_add_two]
          simp [Phi, show (n - 1) + 1 = n by omega]
        have hbd : seq j (n - 1) * seq j (n + 1) = Phi (seq j n) ^ 2025 := by
          rw [hd, mul_comm]
          exact Nat.div_mul_cancel hD1
        have hc : seq j n = Phi (seq j (n - 1)) ^ 2025 / seq j (n - 2) := by
          rw [show n = (n - 2) + 2 by omega, seq_add_two]
          simp [Phi, show (n - 2) + 1 = n - 1 by omega]
        have hcdiv : seq j n ∣ Phi (seq j (n - 1)) ^ 2025 := by
          refine ⟨seq j (n - 2), ?_⟩
          rw [hc]
          exact (Nat.div_mul_cancel hD2).symm
        have hstep := JijianAuthorStep_3 1 (seq j (n - 1)) (seq j n) (seq j (n + 1)) 2025 ?_ ?_
        · simpa [GoodDiv, Phi, one_mul] using hstep
        · simpa [Phi, one_mul] using hbd
        · simpa [Phi, one_mul] using hcdiv

lemma seq_pos (j : ℕ) (hj : j ≤ 2025) : ∀ n, 0 < seq j n := by
  intro n
  induction n using Nat.strong_induction_on with
  | h n ih =>
    by_cases h0 : n = 0
    · subst n
      simp [seq_zero]
    · by_cases h1 : n = 1
      · subst n
        rw [seq_one]
        positivity
      · have hn2 : 2 ≤ n := by omega
        have hD : seq j (n - 2) ∣ Phi (seq j (n - 1)) ^ 2025 := by
          have h := D_all j (by omega) (n - 2)
          change seq j (n - 2) ∣ Phi (seq j ((n - 2) + 1)) ^ 2025 at h
          rw [show (n - 2) + 1 = n - 1 by omega] at h
          exact h
        have hrec : seq j n = Phi (seq j (n - 1)) ^ 2025 / seq j (n - 2) := by
          rw [show n = (n - 2) + 2 by omega, seq_add_two]
          simp [Phi, show (n - 2) + 1 = n - 1 by omega]
        have hbase : 0 < Phi (seq j (n - 1)) := by
          dsimp [Phi]
          positivity
        have hnum_pos : 0 < Phi (seq j (n - 1)) ^ 2025 := pow_pos hbase _
        have hmul : seq j n * seq j (n - 2) = Phi (seq j (n - 1)) ^ 2025 := by
          rw [hrec]
          exact Nat.div_mul_cancel hD
        by_contra hnot
        have hz : seq j n = 0 := Nat.eq_zero_of_not_pos hnot
        rw [hz, zero_mul] at hmul
        exact (ne_of_gt hnum_pos) hmul.symm

lemma seq_rat_rec (j : ℕ) (hj : j ≤ 2025) (n : ℕ) :
    (seq j (n + 2) : ℚ) =
      ((((seq j (n + 1) : ℚ) ^ 2 + (seq j (n + 1) : ℚ) + 1) ^ 2025) /
        (seq j n : ℚ)) := by
  have hD : seq j n ∣ Phi (seq j (n + 1)) ^ 2025 := D_all j hj n
  have hpos : 0 < seq j n := seq_pos j hj n
  have hne : (seq j n : ℕ) ≠ 0 := ne_of_gt hpos
  have hdef : seq j (n + 2) = Phi (seq j (n + 1)) ^ 2025 / seq j n := by
    rw [seq_add_two]
    simp [Phi]
  calc
    (seq j (n + 2) : ℚ) = (((Phi (seq j (n + 1))) ^ 2025 / seq j n : ℕ) : ℚ) := by
      rw [hdef]
    _ = (((Phi (seq j (n + 1))) ^ 2025 : ℕ) : ℚ) / (seq j n : ℚ) :=
      natCast_div_of_dvd hD hne
    _ = ((((seq j (n + 1) : ℚ) ^ 2 + (seq j (n + 1) : ℚ) + 1) ^ 2025) /
        (seq j n : ℚ)) := by
      congr 1
      rw [Nat.cast_pow]
      congr 1
      dsimp [Phi]
      push_cast
      ring

set_option maxRecDepth 4096 in
lemma seq_mem_rec (j : ℕ) (hj : j ≤ 2025) (n : ℕ) (hn : 2 ≤ n) :
    (seq j n : ℚ) =
      ((((seq j (n - 1) : ℚ) ^ 2 + (seq j (n - 1) : ℚ) + 1) ^ 2025) /
        (seq j (n - 2) : ℚ)) := by
  have h := seq_rat_rec j hj (n - 2)
  have hn : n - 2 + 2 = n := by omega
  have hn1 : n - 2 + 1 = n - 1 := by omega
  rw [hn, hn1] at h
  exact h

lemma seq_mem (j : ℕ) (hj : j ≤ 2025) :
    seq j ∈ {v : ℕ → ℕ | (∀ n : ℕ, 0 < v n) ∧ (v 0 = 1) ∧
      (∀ n : ℕ, 2 ≤ n → (v n : ℚ) = (((v (n - 1) : ℚ) ^ 2 + (v (n - 1) : ℚ) + 1) ^ 2025) / (v (n - 2) : ℚ))} := by
  constructor
  · exact seq_pos j hj
  constructor
  · rw [seq_zero]
  · intro n hn
    exact seq_mem_rec j hj n hn

set_option maxHeartbeats 800000 in
lemma eq_seq_of_mem {v : ℕ → ℕ}
    (hv : v ∈ {v : ℕ → ℕ | (∀ n : ℕ, 0 < v n) ∧ (v 0 = 1) ∧
      (∀ n : ℕ, 2 ≤ n → (v n : ℚ) = (((v (n - 1) : ℚ) ^ 2 + (v (n - 1) : ℚ) + 1) ^ 2025) / (v (n - 2) : ℚ))}) :
    ∃ j, j ≤ 2025 ∧ v = seq j := by
  rcases hv with ⟨hpos, hv0, hrec⟩
  have hv2 : v 2 = Phi (v 1) ^ 2025 := by
    apply Nat.cast_injective (R := ℚ)
    rw [hrec 2 (by norm_num), hv0]
    norm_num
    rw [Phi]
    push_cast
    ring_nf
  have hv3mul : v 3 * v 1 = Phi (v 2) ^ 2025 := by
    apply Nat.cast_injective (R := ℚ)
    rw [Nat.cast_mul, hrec 3 (by norm_num)]
    have hv1ne : (v 1 : ℚ) ≠ 0 := by
      exact_mod_cast (ne_of_gt (hpos 1))
    field_simp [hv1ne]
    rw [Phi]
    push_cast
    ring_nf
  have hv1dvd : v 1 ∣ 3 ^ 2025 := by
    have h := JijianAuthorStep_1 1 (v 1) (v 2) (v 3) 2025 ?_ ?_
    · simpa [Phi, one_mul] using h
    · simpa [Phi, one_mul] using hv2
    · simpa [Phi, one_mul] using hv3mul
  have hp3 : Nat.Prime 3 := by norm_num
  rcases (Nat.dvd_prime_pow hp3).1 hv1dvd with ⟨j, hjle, hv1eq⟩
  refine ⟨j, hjle, ?_⟩
  funext n
  induction n using Nat.strong_induction_on with
  | h n ih =>
    by_cases h0 : n = 0
    · subst n
      rw [hv0, seq_zero]
    · by_cases h1 : n = 1
      · subst n
        rw [hv1eq, seq_one]
      · have hn2 : 2 ≤ n := by omega
        have hvv := hrec n hn2
        have hss := seq_mem_rec j hjle n hn2
        have ih1 : v (n - 1) = seq j (n - 1) := ih (n - 1) (by omega)
        have ih2 : v (n - 2) = seq j (n - 2) := ih (n - 2) (by omega)
        apply Nat.cast_injective (R := ℚ)
        calc
          (v n : ℚ) = ((((v (n - 1) : ℚ) ^ 2 + (v (n - 1) : ℚ) + 1) ^ 2025) / (v (n - 2) : ℚ)) := hvv
          _ = ((((seq j (n - 1) : ℚ) ^ 2 + (seq j (n - 1) : ℚ) + 1) ^ 2025) / (seq j (n - 2) : ℚ)) := by rw [ih1, ih2]
          _ = (seq j n : ℚ) := hss.symm

theorem JijianWholeModuleProof_42d387765f657a4b1882319e : _root_.JijianLockedProp_42d387765f657a4b1882319e :=
by
  classical
  let S : Set (ℕ → ℕ) := {v : ℕ → ℕ | (∀ n : ℕ, 0 < v n) ∧ (v 0 = 1) ∧ (∀ n : ℕ, 2 ≤ n → (v n : ℚ) = (((v (n - 1) : ℚ) ^ 2 + (v (n - 1) : ℚ) + 1) ^ 2025) / (v (n - 2) : ℚ))}
  let T : Finset (ℕ → ℕ) := (Finset.range 2026).image (fun j : ℕ => seq j)
  have hS_eq : S = (T : Set (ℕ → ℕ)) := by
    ext v
    constructor
    · intro hv
      rcases eq_seq_of_mem hv with ⟨j, hj, hvseq⟩
      rw [hvseq]
      apply Finset.mem_image.mpr
      refine ⟨j, ?_, rfl⟩
      rw [Finset.mem_range]
      omega
    · intro hvT
      change v ∈ T at hvT
      rcases Finset.mem_image.mp hvT with ⟨j, hj, hvj⟩
      rw [Finset.mem_range] at hj
      rw [← hvj]
      exact seq_mem j (by omega)
  change Set.ncard S = 2026
  have hseq_inj : Function.Injective (fun j : ℕ => seq j) := by
    intro a b hab
    apply pow3_injective
    have h := congrFun hab 1
    simpa [seq_one] using h
  have hcard : T.card = 2026 := by
    dsimp [T]
    rw [Finset.card_image_of_injective (Finset.range 2026) hseq_inj]
    simp
  have hncard : (T : Set (ℕ → ℕ)).ncard = T.card := by
    exact Set.ncard_coe_Finset T
  rw [hS_eq, hncard]
  exact hcard
#print axioms JijianWholeModuleProof_42d387765f657a4b1882319e
