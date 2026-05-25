///|
test "complex trigonometric functions" {
  let a = Complex::new(1.0, 1.0)

  assert_true(
    complex_approx_equal(
      a.sin(),
      Complex::new(1.2984575814159773, 0.6349639147847361),
      tol,
    ),
  )
  assert_true(
    complex_approx_equal(
      a.cos(),
      Complex::new(0.8337300251311491, -0.9888977057628651),
      tol,
    ),
  )
  assert_true(
    complex_approx_equal(
      a.tan(),
      Complex::new(0.27175258531951174, 1.0839233273386948),
      tol,
    ),
  )
  assert_true(
    complex_approx_equal(
      a.sec(),
      Complex::new(0.49833703055518674, 0.5910838417210449),
      tol,
    ),
  )
  assert_true(
    complex_approx_equal(
      a.csc(),
      Complex::new(0.6215180171704283, -0.3039310016284264),
      tol,
    ),
  )
  assert_true(
    complex_approx_equal(
      a.cot(),
      Complex::new(0.2176215618544027, -0.868014142895925),
      tol,
    ),
  )
}

///|
test "complex inverse trigonometric functions" {
  let a = Complex::new(1.0, 1.0)

  assert_true(
    complex_approx_equal(
      a.asin(),
      Complex::new(0.6662394324925153, 1.0612750619050355),
      tol,
    ),
  )
  assert_true(
    complex_approx_equal(
      a.acos(),
      Complex::new(0.9045568943023813, -1.0612750619050355),
      tol,
    ),
  )
  assert_true(
    complex_approx_equal(
      a.atan(),
      Complex::new(1.0172219678978514, 0.40235947810852507),
      tol,
    ),
  )
  assert_true(
    complex_approx_equal(
      a.asec(),
      Complex::new(1.1185178796437059, 0.5306375309525179),
      tol,
    ),
  )
  assert_true(
    complex_approx_equal(
      a.acsc(),
      Complex::new(0.45227844715119064, -0.5306375309525179),
      tol,
    ),
  )
  assert_true(
    complex_approx_equal(
      a.acot(),
      Complex::new(0.5535743588970452, -0.402359478108525),
      tol,
    ),
  )

  let b = Complex::new(-0.75, -0.25)
  assert_true(
    complex_approx_equal_relaxed(
      b.asin(),
      Complex::new(-0.7853981633974483, -0.34657359027997264),
    ),
  )
  assert_true(complex_approx_equal_relaxed(b.asin().sin(), b))
}
