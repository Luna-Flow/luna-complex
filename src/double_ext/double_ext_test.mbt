///|
fn approx_equal(a : Double, b : Double, tol : Double) -> Bool {
  Double::abs(a - b) < tol
}

///|
fn complex_approx_equal(
  a : Complex[Double],
  b : Complex[Double],
  tol : Double,
) -> Bool {
  approx_equal(a.re, b.re, tol) && approx_equal(a.im, b.im, tol)
}

///|
fn complex_parts_match(
  actual : Complex[Double],
  expected_re : Double,
  expected_im : Double,
  tol : Double,
) -> Bool {
  approx_equal(actual.re, expected_re, tol) &&
  approx_equal(actual.im, expected_im, tol)
}

///|
test "double_ext elementary smoke test" {
  let z = Complex::new(1.0, 2.0)

  assert_true(
    complex_approx_equal(
      polar(1.0, 0.7853981633974483),
      Complex::new(0.7071067811865476, 0.7071067811865475),
      1.0e-12,
    ),
  )
  assert_true(
    approx_equal(arg(Complex::new(0.0, 1.0)), 1.5707963267948966, 1.0e-12),
  )
  assert_true(
    complex_approx_equal(
      sqrt(Complex::new(-3.0, 4.0)),
      Complex::new(1.0, 2.0),
      1.0e-12,
    ),
  )
  assert_true(complex_approx_equal(exp(log(z)), z, 1.0e-12))
  assert_true(
    complex_approx_equal(pow_real(z, 2.0), Complex::new(-3.0, 4.0), 1.0e-12),
  )
}

///|
test "double_ext elementary stability regression" {
  assert_true(complex_parts_match(sqrt_real(-9.0), 0.0, 3.0, 1.0e-12))
  assert_eq(abs_log(Complex::new(0.0, 0.0)).is_neg_inf(), true)

  let neg_axis = arg(Complex::new(-1.0, -0.0))
  assert_true(approx_equal(neg_axis, 6.283185307179586, 1.0e-12))

  let finite_over_infinite = div(
    Complex::new(1.0, 2.0),
    Complex::new(@double.infinity, @double.infinity),
  )
  assert_eq(finite_over_infinite.re == 0.0, true)
  assert_eq(finite_over_infinite.im == 0.0, true)

  let zero_pow_zero = pow_real(Complex::new(0.0, 0.0), 0.0)
  assert_true(complex_parts_match(zero_pow_zero, 1.0, 0.0, 1.0e-12))

  let zero_pow_negative = pow_real(Complex::new(0.0, 0.0), -1.0)
  assert_eq(zero_pow_negative.re.is_nan(), true)
  assert_eq(zero_pow_negative.im.is_nan(), true)
}

///|
test "double_ext trig and hyperbolic smoke test" {
  let z = Complex::new(1.0, 1.0)

  assert_true(complex_approx_equal(sin(asin(z)), z, 1.0e-10))
  assert_true(complex_approx_equal(cos(acos(z)), z, 1.0e-10))
  assert_true(complex_approx_equal(tan(atan(z)), z, 1.0e-10))
  assert_true(complex_approx_equal(sinh(asinh(z)), z, 1.0e-10))
  assert_true(
    complex_approx_equal(
      tanh(atanh(Complex::new(0.25, 0.25))),
      Complex::new(0.25, 0.25),
      1.0e-10,
    ),
  )
}

///|
test "double_ext trig and hyperbolic stability regression" {
  let huge = 1.0e308

  let asin_huge = asin(Complex::new(huge, huge))
  assert_true(approx_equal(asin_huge.re, 0.7853981633974483, 1.0e-12))
  assert_eq(asin_huge.im.is_pos_inf(), false)
  assert_eq(asin_huge.im.is_nan(), false)

  let atan_pole = atan(Complex::new(0.0, 2.0))
  assert_true(approx_equal(atan_pole.re, 1.5707963267948966, 1.0e-12))

  let atanh_inf = atanh(Complex::new(@double.infinity, 1.0))
  assert_true(complex_parts_match(atanh_inf, 0.0, 1.5707963267948966, 1.0e-12))

  let acosh_inf = acosh(Complex::new(@double.infinity, 1.0))
  assert_eq(acosh_inf.re.is_pos_inf(), true)
  assert_true(approx_equal(acosh_inf.im, 0.0, 1.0e-12))
}
