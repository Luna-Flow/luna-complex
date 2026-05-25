///|
test "complex real-axis branch values" {
  assert_true(
    complex_approx_equal_relaxed(
      Complex::asin_real(2.0),
      Complex::new(@lm.DOUBLE_PI / 2.0, 1.3169578969248166),
    ),
  )
  assert_true(
    complex_approx_equal_relaxed(
      Complex::asin_real(-2.0),
      Complex::new(-@lm.DOUBLE_PI / 2.0, 1.3169578969248166),
    ),
  )
  assert_true(
    complex_approx_equal_relaxed(
      Complex::acos_real(2.0),
      Complex::new(0.0, -1.3169578969248166),
    ),
  )
  assert_true(
    complex_approx_equal_relaxed(
      Complex::acos_real(-2.0),
      Complex::new(@lm.DOUBLE_PI, -1.3169578969248166),
    ),
  )
  assert_true(
    complex_approx_equal_relaxed(
      Complex::acosh_real(-1.0),
      Complex::new(0.0, @lm.DOUBLE_PI),
    ),
  )
  assert_true(
    complex_approx_equal_relaxed(
      Complex::acosh_real(2.0),
      Complex::new(1.3169578969248166, 0.0),
    ),
  )
  assert_true(
    complex_approx_equal_relaxed(
      Complex::atanh_real(2.0),
      Complex::new(0.5493061443340549, @lm.DOUBLE_PI / 2.0),
    ),
  )
  assert_true(
    complex_approx_equal_relaxed(
      Complex::atanh_real(-2.0),
      Complex::new(-0.5493061443340549, @lm.DOUBLE_PI / 2.0),
    ),
  )
  assert_true(
    assert_complex_special(
      Complex::atanh_real(1.0),
      false,
      true,
      false,
      false,
      false,
      false,
    ),
  )
  assert_true(Complex::atanh_real(1.0).im == 0.0)
  assert_true(
    assert_complex_special(
      Complex::atanh_real(-1.0),
      false,
      false,
      true,
      false,
      false,
      false,
    ),
  )
  assert_true(Complex::atanh_real(-1.0).im == 0.0)
  assert_true(
    complex_approx_equal_relaxed(
      Complex::asec_real(0.5),
      Complex::new(0.0, -1.3169578969248166),
    ),
  )
  assert_true(
    complex_approx_equal_relaxed(
      Complex::asec_real(-0.5),
      Complex::new(@lm.DOUBLE_PI, -1.3169578969248166),
    ),
  )
  assert_true(
    complex_approx_equal_relaxed(
      Complex::acsc_real(0.5),
      Complex::new(@lm.DOUBLE_PI / 2.0, 1.3169578969248166),
    ),
  )
  assert_true(
    complex_approx_equal_relaxed(
      Complex::acsc_real(-0.5),
      Complex::new(-@lm.DOUBLE_PI / 2.0, 1.3169578969248166),
    ),
  )
}

///|
test "complex branch-sensitive values" {
  assert_true(
    complex_approx_equal_relaxed(
      Complex::new(2.0, 0.0).asin(),
      Complex::new(@lm.DOUBLE_PI / 2.0, 1.3169578969248166),
    ),
  )
  assert_true(
    complex_approx_equal_relaxed(
      Complex::new(-2.0, 0.0).acos(),
      Complex::new(@lm.DOUBLE_PI, -1.3169578969248166),
    ),
  )
  assert_true(
    complex_approx_equal_relaxed(
      Complex::new(-1.0, 0.0).acosh(),
      Complex::new(0.0, @lm.DOUBLE_PI),
    ),
  )
  assert_true(
    complex_approx_equal_relaxed(
      Complex::new(2.0, 0.0).atanh(),
      Complex::new(0.5493061443340549, @lm.DOUBLE_PI / 2.0),
    ),
  )
  assert_true(
    complex_approx_equal_relaxed(
      Complex::new(-2.0, 0.0).atanh(),
      Complex::new(-0.5493061443340549, @lm.DOUBLE_PI / 2.0),
    ),
  )
  assert_true(
    assert_complex_special(
      Complex::new(1.0, 0.0).atanh(),
      false,
      true,
      false,
      false,
      false,
      false,
    ),
  )
  assert_true(Complex::new(1.0, 0.0).atanh().im == 0.0)
  assert_true(
    assert_complex_special(
      Complex::new(-1.0, 0.0).atanh(),
      false,
      false,
      true,
      false,
      false,
      false,
    ),
  )
  assert_true(Complex::new(-1.0, 0.0).atanh().im == 0.0)
  assert_true(
    complex_approx_equal_relaxed(
      Complex::new(0.5, 0.0).asec(),
      Complex::asec_real(0.5),
    ),
  )
  assert_true(
    complex_approx_equal_relaxed(
      Complex::new(-0.5, 0.0).asec(),
      Complex::asec_real(-0.5),
    ),
  )
  assert_true(
    complex_approx_equal_relaxed(
      Complex::new(0.5, 0.0).acsc(),
      Complex::acsc_real(0.5),
    ),
  )
  assert_true(
    complex_approx_equal_relaxed(
      Complex::new(-0.5, 0.0).acsc(),
      Complex::acsc_real(-0.5),
    ),
  )
}
