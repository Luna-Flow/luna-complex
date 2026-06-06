///|
fn nested_complex_approx_equal(
  a : Complex[Complex[Double]],
  b : Complex[Complex[Double]],
  tol : Double,
) -> Bool {
  Double::abs(a.re.re - b.re.re) < tol &&
  Double::abs(a.re.im - b.re.im) < tol &&
  Double::abs(a.im.re - b.im.re) < tol &&
  Double::abs(a.im.im - b.im.im) < tol
}

///|
test "generic complex constructors and algebra over ints" {
  assert_true(Complex::zero() == Complex::new(0, 0))
  assert_true(Complex::one() == Complex::new(1, 0))

  let a = Complex::new(1, 2)
  let b = Complex::new(3, 4)

  assert_true(a + b == Complex::new(4, 6))
  assert_true(a - b == Complex::new(-2, -2))
  assert_true(a * b == Complex::new(-5, 10))
  assert_true(-a == Complex::new(-1, -2))
  assert_true(a.conjugate() == Complex::new(1, -2))

  a.set(2, 1)
  assert_true(a == Complex::new(2, 1))
  a.set_re(1)
  assert_true(a == Complex::new(1, 1))
  a.set_im(2)
  assert_true(a == Complex::new(1, 2))
}

///|
test "generic complex field operations over doubles" {
  let a = Complex::new(1.0, 2.0)
  let b = Complex::new(0.5, 1.0)

  assert_true(a / b == Complex::new(2.0, 0.0))
  assert_true(a.inv() == Complex::new(0.2, -0.4))
}

///|
test "nested complex field operations compose" {
  let a = Complex::new(1.0, 2.0)
  let b = Complex::new(-0.5, 0.25)
  let z = Complex::new(a, b)
  let one = Complex::one()

  assert_true(z.conjugate() == Complex::new(a, -b))
  assert_true(z * one == z)
  assert_true(nested_complex_approx_equal(z / z, one, 1.0e-12))
  assert_true(nested_complex_approx_equal(z.inv() * z, one, 1.0e-12))
}
