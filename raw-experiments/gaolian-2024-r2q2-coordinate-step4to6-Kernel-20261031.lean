import Mathlib

set_option maxHeartbeats 2000000

private def cyc3 (nB bX bY nD dX dY nP pX pY nQ qX qY : ℝ) : ℝ :=
  (nB - nQ) * ((dX - qX) * (pY - qY) - (dY - qY) * (pX - qX)) -
  (bX - qX) * ((nD - nQ) * (pY - qY) - (dY - qY) * (nP - nQ)) +
  (bY - qY) * ((nD - nQ) * (pX - qX) - (dX - qX) * (nP - nQ))

theorem olympiad_coordinate_cyclic_factor
    (u v b d c t Es Fs : ℝ)
    (hEs : Es = (c * (1-t) + t*b*u)^2 + (t*b*v)^2)
    (hFs : Fs = (c * (1-t) + t*d*u)^2 + (-t*d*v)^2)
    (hneE : Es ≠ 0) (hneF : Fs ≠ 0) :
    let N := u^2 + v^2
    let h := b*d*t
    cyc3 (b^2*N) (b*u) (b*v)
      (d^2*N) (d*u) (-d*v)
      (h^2/Fs) (-h*(c*(1-t)+t*d*u)/Fs) (-h*(-t*d*v)/Fs)
      (h^2/Es) (-h*(c*(1-t)+t*b*u)/Es) (-h*(t*b*v)/Es)
    =
    b^2*c*d^2*t^3*v*(b-d)*(t-1)*(N-1)*
      (b^2*N-2*b*d*u^2+2*b*d*v^2+d^2*N)/(Es*Fs) := by
  dsimp only
  unfold cyc3
  field_simp [hneE, hneF]
  rw [hEs, hFs]
  ring


theorem general_det4_cyclic_condition
    (nB bx b_y nD dx dy nP px py nQ qx qy : ℝ) :
    Matrix.det !![nB, bx, b_y, 1; nD, dx, dy, 1; nP, px, py, 1; nQ, qx, qy, 1]
      = cyc3 nB bx b_y nD dx dy nP px py nQ qx qy := by
  simp [Matrix.det_succ_row_zero, Fin.sum_univ_succ, Fin.succAbove, cyc3]
  ring

theorem olympiad_coordinate_full_four_by_four_det_zero
    (u v b d c t Es Fs : ℝ)
    (hEs : Es = (c * (1-t) + t*b*u)^2 + (t*b*v)^2)
    (hFs : Fs = (c * (1-t) + t*d*u)^2 + (-t*d*v)^2)
    (hneE : Es ≠ 0) (hneF : Fs ≠ 0)
    (hunit : u^2 + v^2 = 1) :
    Matrix.det !![
      b^2*(u^2+v^2), b*u, b*v, 1;
      d^2*(u^2+v^2), d*u, -d*v, 1;
      (b*d*t)^2/Fs, -(b*d*t)*(c*(1-t)+t*d*u)/Fs, -(b*d*t)*(-t*d*v)/Fs, 1;
      (b*d*t)^2/Es, -(b*d*t)*(c*(1-t)+t*b*u)/Es, -(b*d*t)*(t*b*v)/Es, 1
    ] = 0 := by
  rw [general_det4_cyclic_condition]
  have hid := olympiad_coordinate_cyclic_factor u v b d c t Es Fs hEs hFs hneE hneF
  dsimp only at hid
  rw [hid, hunit]
  ring

theorem circle_ray_parameter_from_quadratic
    (x y r p lam : ℝ)
    (hr : r = x^2 + y^2)
    (hr0 : r ≠ 0) (hp : p ≠ 0)
    (hc : (p*x)^2 + (p*y)^2 + lam*(p*y) = 0) :
    p = -(lam*y)/r := by
  have hprod : p*(p*r+lam*y)=0 := by
    calc
      p*(p*r+lam*y) = (p*x)^2 + (p*y)^2 + lam*(p*y) := by rw [hr]; ring
      _ = 0 := hc
  have hlin : p*r+lam*y=0 := (mul_eq_zero.mp hprod).resolve_left hp
  apply (eq_div_iff hr0).2
  linear_combination hlin
