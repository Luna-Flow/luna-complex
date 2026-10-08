///|
fn approx_equal(a : Double, b : Double, tol : Double) -> Bool {
  Double::abs(a - b) < tol
}

///|
fn complex_approx_equal(
  a : @float_backend.Complex[Double],
  b : @float_backend.Complex[Double],
  tol : Double,
) -> Bool {
  approx_equal(a.re, b.re, tol) && approx_equal(a.im, b.im, tol)
}

///|
fn complex_parts_match(
  actual : @float_backend.Complex[Double],
  expected_re : Double,
  expected_im : Double,
  tol : Double,
) -> Bool {
  approx_equal(actual.re, expected_re, tol) &&
  approx_equal(actual.im, expected_im, tol)
}

///|
test "float_backend elementary smoke test" {
  let z = @float_backend.Complex::new(1.0, 2.0)

  assert_true(
    complex_approx_equal(
      @float_backend.polar(1.0, 0.7853981633974483),
      @float_backend.Complex::new(0.7071067811865476, 0.7071067811865475),
      1.0e-12,
    ),
  )
  assert_true(
    approx_equal(
      @float_backend.arg(@float_backend.Complex::new(0.0, 1.0)),
      1.5707963267948966,
      1.0e-12,
    ),
  )
  assert_true(
    complex_approx_equal(
      @float_backend.sqrt(@float_backend.Complex::new(-3.0, 4.0)),
      @float_backend.Complex::new(1.0, 2.0),
      1.0e-12,
    ),
  )
  assert_true(
    complex_approx_equal(@float_backend.exp(@float_backend.log(z)), z, 1.0e-12),
  )
  assert_true(
    complex_approx_equal(
      @float_backend.pow_real(z, 2.0),
      @float_backend.Complex::new(-3.0, 4.0),
      1.0e-12,
    ),
  )
}

///|
test "float_backend elementary stability regression" {
  assert_true(
    complex_parts_match(@float_backend.sqrt_real(-9.0), 0.0, 3.0, 1.0e-12),
  )
  assert_eq(
    @float_backend.abs_log(@float_backend.Complex::new(0.0, 0.0)).is_neg_inf(),
    true,
  )

  let neg_axis = @float_backend.arg(@float_backend.Complex::new(-1.0, -0.0))
  assert_true(approx_equal(neg_axis, 6.283185307179586, 1.0e-12))

  let finite_over_infinite = @float_backend.div(
    @float_backend.Complex::new(1.0, 2.0),
    @float_backend.Complex::new(@double.infinity, @double.infinity),
  )
  assert_eq(finite_over_infinite.re == 0.0, true)
  assert_eq(finite_over_infinite.im == 0.0, true)

  let zero_pow_zero = @float_backend.pow_real(
    @float_backend.Complex::new(0.0, 0.0),
    0.0,
  )
  assert_true(complex_parts_match(zero_pow_zero, 1.0, 0.0, 1.0e-12))

  let zero_pow_negative = @float_backend.pow_real(
    @float_backend.Complex::new(0.0, 0.0),
    -1.0,
  )
  assert_eq(zero_pow_negative.re.is_nan(), true)
  assert_eq(zero_pow_negative.im.is_nan(), true)
}

///|
test "float_backend trig and hyperbolic smoke test" {
  let z = @float_backend.Complex::new(1.0, 1.0)

  assert_true(
    complex_approx_equal(@float_backend.sin(@float_backend.asin(z)), z, 1.0e-10),
  )
  assert_true(
    complex_approx_equal(@float_backend.cos(@float_backend.acos(z)), z, 1.0e-10),
  )
  assert_true(
    complex_approx_equal(@float_backend.tan(@float_backend.atan(z)), z, 1.0e-10),
  )
  assert_true(
    complex_approx_equal(
      @float_backend.sinh(@float_backend.asinh(z)),
      z,
      1.0e-10,
    ),
  )
  assert_true(
    complex_approx_equal(
      @float_backend.tanh(
        @float_backend.atanh(@float_backend.Complex::new(0.25, 0.25)),
      ),
      @float_backend.Complex::new(0.25, 0.25),
      1.0e-10,
    ),
  )
}

///|
test "float_backend trig and hyperbolic stability regression" {
  let huge = 1.0e308

  let asin_huge = @float_backend.asin(@float_backend.Complex::new(huge, huge))
  assert_true(approx_equal(asin_huge.re, 0.7853981633974483, 1.0e-12))
  assert_eq(asin_huge.im.is_pos_inf(), false)
  assert_eq(asin_huge.im.is_nan(), false)

  let atan_pole = @float_backend.atan(@float_backend.Complex::new(0.0, 2.0))
  assert_true(approx_equal(atan_pole.re, 1.5707963267948966, 1.0e-12))

  let atanh_inf = @float_backend.atanh(
    @float_backend.Complex::new(@double.infinity, 1.0),
  )
  assert_true(complex_parts_match(atanh_inf, 0.0, 1.5707963267948966, 1.0e-12))

  let acosh_inf = @float_backend.acosh(
    @float_backend.Complex::new(@double.infinity, 1.0),
  )
  assert_eq(acosh_inf.re.is_pos_inf(), true)
  assert_true(approx_equal(acosh_inf.im, 0.0, 1.0e-12))
}
