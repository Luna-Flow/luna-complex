///|
test "complex algebraic laws" {
  let z = Complex::new(1.5, -2.0)
  let w = Complex::new(-0.25, 3.0)
  let u = Complex::new(2.0, 0.5)

  assert_true(complex_approx_equal(z + Complex::zero(), z, tol))
  assert_true(complex_approx_equal(z * Complex::one(), z, tol))
  assert_true(complex_approx_equal(z.conjugate().conjugate(), z, tol))
  assert_true(complex_approx_equal(z + w + u, z + (w + u), tol))
  assert_true(complex_approx_equal(z * w * u, z * (w * u), tol))
  assert_true(
    complex_approx_equal(
      (z * w).conjugate(),
      z.conjugate() * w.conjugate(),
      tol,
    ),
  )
}

///|
test "complex analytic identities" {
  let z = Complex::new(1.0, 1.0)
  let w = Complex::new(0.5, -0.25)
  let magnitude_sq = z * z.conjugate()

  assert_true(approx_equal(magnitude_sq.im, 0.0, tol))
  assert_true(approx_equal(magnitude_sq.re, z.abs_sqr(), tol))
  assert_true(complex_approx_equal(z.exp().log(), z, tol))
  assert_true(complex_approx_equal(w.sin().asin(), w, tol))
  assert_true(complex_approx_equal(w.sinh().asinh(), w, tol))
}
