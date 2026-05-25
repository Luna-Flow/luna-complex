///|
test "complex hyperbolic functions" {
  let a = Complex::new(1.0, 1.0)

  assert_true(
    complex_approx_equal(
      a.sinh(),
      Complex::new(0.6349639147847361, 1.2984575814159773),
      tol,
    ),
  )
  assert_true(
    complex_approx_equal(
      a.cosh(),
      Complex::new(0.8337300251311491, 0.9888977057628651),
      tol,
    ),
  )
  assert_true(
    complex_approx_equal(
      a.tanh(),
      Complex::new(1.0839233273386948, 0.27175258531951174),
      tol,
    ),
  )
  assert_true(
    complex_approx_equal(
      a.sech(),
      Complex::new(0.49833703055518686, -0.5910838417210451),
      tol,
    ),
  )
  assert_true(
    complex_approx_equal(
      a.csch(),
      Complex::new(0.30393100162842646, -0.6215180171704285),
      tol,
    ),
  )
  assert_true(
    complex_approx_equal(
      a.coth(),
      Complex::new(0.868014142895925, -0.2176215618544027),
      tol,
    ),
  )
}

///|
test "complex inverse hyperbolic functions" {
  let a = Complex::new(1.0, 1.0)

  assert_true(
    complex_approx_equal(
      a.asinh(),
      Complex::new(1.0612750619050357, 0.6662394324925153),
      tol,
    ),
  )
  assert_true(
    complex_approx_equal(
      a.acosh(),
      Complex::new(1.0612750619050355, 0.9045568943023813),
      tol,
    ),
  )
  assert_true(
    complex_approx_equal(
      a.atanh(),
      Complex::new(0.40235947810852507, 1.0172219678978514),
      tol,
    ),
  )
  assert_true(
    complex_approx_equal(
      a.asech(),
      Complex::new(0.5306375309525179, -1.1185178796437059),
      tol,
    ),
  )
  assert_true(
    complex_approx_equal(
      a.acsch(),
      Complex::new(0.5306375309525179, -0.45227844715119064),
      tol,
    ),
  )
  assert_true(
    complex_approx_equal(
      a.acoth(),
      Complex::new(0.40235947810852507, -0.5535743588970452),
      tol,
    ),
  )
}

///|
test "complex hyperbolic large real inputs stay stable" {
  let z = Complex::new(30.0, 0.75)
  let tanh_z = z.tanh()

  assert_true(approx_equal_relaxed(tanh_z.re, 1.0))
  assert_true(tanh_z.im.abs() < 1.0e-24)

  let neg = Complex::new(-30.0, 0.75).tanh()
  assert_true(approx_equal_relaxed(neg.re, -1.0))
  assert_true(neg.im.abs() < 1.0e-24)
}

///|
test "complex inverse hyperbolic pure imaginary branch values" {
  assert_true(
    complex_approx_equal_relaxed(
      Complex::new(0.0, 2.0).asinh(),
      Complex::new(1.3169578969248166, @lm.DOUBLE_PI / 2.0),
    ),
  )
  assert_true(
    complex_approx_equal_relaxed(
      Complex::new(0.0, 2.0).acosh(),
      Complex::new(1.4436354751788103, @lm.DOUBLE_PI / 2.0),
    ),
  )
  assert_true(
    complex_approx_equal_relaxed(
      Complex::new(0.0, 2.0).atanh(),
      Complex::new(0.0, 1.1071487177940904),
    ),
  )
}
