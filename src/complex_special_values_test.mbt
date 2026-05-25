///|
test "complex special values on infinities" {
  let pos_inf = @double.infinity
  let neg_inf = @double.neg_infinity

  let log_pos = Complex::new(pos_inf, 0.0).log()
  assert_true(log_pos.re.is_pos_inf())
  assert_true(log_pos.im == 0.0)

  let log_neg = Complex::new(neg_inf, 0.0).log()
  assert_true(log_neg.re.is_pos_inf())
  assert_true(approx_equal_relaxed(log_neg.im, @lm.DOUBLE_PI))

  let sqrt_pos = Complex::new(pos_inf, 0.0).sqrt()
  assert_true(sqrt_pos.re.is_pos_inf())
  assert_true(sqrt_pos.im == 0.0)

  let sqrt_neg = Complex::new(neg_inf, 0.0).sqrt()
  assert_true(sqrt_neg.re == 0.0)
  assert_true(sqrt_neg.im.is_pos_inf())

  let asin_pos = Complex::new(pos_inf, 0.0).asin()
  assert_true(approx_equal_relaxed(asin_pos.re, @lm.DOUBLE_PI / 2.0))
  assert_true(asin_pos.im.is_pos_inf())

  let acos_neg = Complex::new(neg_inf, 0.0).acos()
  assert_true(approx_equal_relaxed(acos_neg.re, @lm.DOUBLE_PI))
  assert_true(acos_neg.im.is_neg_inf())

  let asinh_pos_im = Complex::new(0.0, pos_inf).asinh()
  assert_true(asinh_pos_im.re.is_pos_inf())
  assert_true(approx_equal_relaxed(asinh_pos_im.im, @lm.DOUBLE_PI / 2.0))

  let acosh_neg = Complex::new(neg_inf, 0.0).acosh()
  assert_true(acosh_neg.re.is_pos_inf())
  assert_true(approx_equal_relaxed(acosh_neg.im, @lm.DOUBLE_PI))

  let atanh_pos = Complex::new(pos_inf, 0.0).atanh()
  assert_true(approx_equal_relaxed(atanh_pos.re, 0.0))
  assert_true(approx_equal_relaxed(atanh_pos.im, @lm.DOUBLE_PI / 2.0))

  let atanh_pos_im = Complex::new(0.0, pos_inf).atanh()
  assert_true(approx_equal_relaxed(atanh_pos_im.re, 0.0))
  assert_true(approx_equal_relaxed(atanh_pos_im.im, @lm.DOUBLE_PI / 2.0))
}

///|
test "complex special values on nan inputs" {
  let nan = @double.not_a_number

  assert_true(assert_complex_special(Complex::new(nan, 0.0).asin(), true, false, false, true, false, false))
  assert_true(assert_complex_special(Complex::new(nan, 0.0).acos(), true, false, false, true, false, false))

  let atan_nan = Complex::new(nan, 0.0).atan()
  assert_true(atan_nan.re.is_nan())
  assert_true(atan_nan.im == 0.0)

  let asinh_nan = Complex::new(nan, 0.0).asinh()
  assert_true(asinh_nan.re.is_nan())
  assert_true(asinh_nan.im == 0.0)

  assert_true(assert_complex_special(Complex::new(nan, 0.0).acosh(), true, false, false, true, false, false))
  assert_true(assert_complex_special(Complex::new(nan, 0.0).atanh(), true, false, false, true, false, false))
}

///|
test "complex branch cuts are sided near endpoints" {
  let eps = 1.0e-12

  let acosh_above = Complex::new(-1.0, eps).acosh()
  let acosh_below = Complex::new(-1.0, -eps).acosh()
  assert_true(acosh_above.re > 0.0 && acosh_above.re < 1.0e-5)
  assert_true(acosh_below.re > 0.0 && acosh_below.re < 1.0e-5)
  assert_true(acosh_above.im > 3.0)
  assert_true(acosh_below.im < -3.0)

  let atanh_one_above = Complex::new(1.0, eps).atanh()
  let atanh_one_below = Complex::new(1.0, -eps).atanh()
  assert_true(atanh_one_above.re > 10.0)
  assert_true(atanh_one_below.re > 10.0)
  assert_true(atanh_one_above.im > 0.7 && atanh_one_above.im < 0.8)
  assert_true(atanh_one_below.im < -0.7 && atanh_one_below.im > -0.8)

  let atanh_neg_above = Complex::new(-1.0, eps).atanh()
  let atanh_neg_below = Complex::new(-1.0, -eps).atanh()
  assert_true(atanh_neg_above.re < -10.0)
  assert_true(atanh_neg_below.re < -10.0)
  assert_true(atanh_neg_above.im > 0.7 && atanh_neg_above.im < 0.8)
  assert_true(atanh_neg_below.im < -0.7 && atanh_neg_below.im > -0.8)
}

///|
test "complex inverse functions stay stable on extreme magnitudes" {
  let huge = Complex::new(1.0e308, 1.0e308)
  let tiny = Complex::new(1.0e-308, 1.0e-308)

  let asin_huge = huge.asin()
  assert_true(approx_equal_relaxed(asin_huge.re, @lm.PI_OVER_4))
  assert_true(asin_huge.im > 700.0)

  let acos_huge = huge.acos()
  assert_true(approx_equal_relaxed(acos_huge.re, @lm.PI_OVER_4))
  assert_true(acos_huge.im < -700.0)

  let asinh_huge = huge.asinh()
  assert_true(asinh_huge.re > 700.0)
  assert_true(approx_equal_relaxed(asinh_huge.im, @lm.PI_OVER_4))

  let acosh_huge = huge.acosh()
  assert_true(acosh_huge.re > 700.0)
  assert_true(approx_equal_relaxed(acosh_huge.im, @lm.PI_OVER_4))

  let atanh_huge = huge.atanh()
  assert_true(atanh_huge.re.abs() < 1.0e-307)
  assert_true(approx_equal_relaxed(atanh_huge.im, @lm.DOUBLE_PI / 2.0))

  let asin_tiny = tiny.asin()
  assert_true(!asin_tiny.re.is_nan() && !asin_tiny.im.is_nan())
  assert_true(asin_tiny.re.abs() < 1.0e-300 && asin_tiny.im.abs() < 1.0e-300)

  let atan_tiny = tiny.atan()
  assert_true(!atan_tiny.re.is_nan() && !atan_tiny.im.is_nan())
  assert_true(atan_tiny.re.abs() < 1.0e-300 && atan_tiny.im.abs() < 1.0e-300)

  let asinh_tiny = tiny.asinh()
  assert_true(!asinh_tiny.re.is_nan() && !asinh_tiny.im.is_nan())
  assert_true(asinh_tiny.re.abs() < 1.0e-300 && asinh_tiny.im.abs() < 1.0e-300)

  let atanh_tiny = tiny.atanh()
  assert_true(!atanh_tiny.re.is_nan() && !atanh_tiny.im.is_nan())
  assert_true(atanh_tiny.re.abs() < 1.0e-300 && atanh_tiny.im.abs() < 1.0e-300)
}
