///|
fn nested_complex_approx_equal(
  a : @luna-complex.Complex[@luna-complex.Complex[Double]],
  b : @luna-complex.Complex[@luna-complex.Complex[Double]],
  tol : Double,
) -> Bool {
  Double::abs(a.re.re - b.re.re) < tol &&
  Double::abs(a.re.im - b.re.im) < tol &&
  Double::abs(a.im.re - b.im.re) < tol &&
  Double::abs(a.im.im - b.im.im) < tol
}

///|
test "generic complex constructors and algebra over ints" {
  assert_true(@luna-complex.Complex::zero() == @luna-complex.Complex::new(0, 0))
  assert_true(@luna-complex.Complex::one() == @luna-complex.Complex::new(1, 0))

  let a = @luna-complex.Complex::new(1, 2)
  let b = @luna-complex.Complex::new(3, 4)

  assert_true(a + b == @luna-complex.Complex::new(4, 6))
  assert_true(a - b == @luna-complex.Complex::new(-2, -2))
  assert_true(a * b == @luna-complex.Complex::new(-5, 10))
  assert_true(-a == @luna-complex.Complex::new(-1, -2))
  assert_true(a.conjugate() == @luna-complex.Complex::new(1, -2))

  a.set(2, 1)
  assert_true(a == @luna-complex.Complex::new(2, 1))
  a.set_re(1)
  assert_true(a == @luna-complex.Complex::new(1, 1))
  a.set_im(2)
  assert_true(a == @luna-complex.Complex::new(1, 2))
}

///|
test "generic complex field operations over doubles" {
  let a = @luna-complex.Complex::new(1.0, 2.0)
  let b = @luna-complex.Complex::new(0.5, 1.0)

  assert_true(a / b == @luna-complex.Complex::new(2.0, 0.0))
  assert_true(a.inv() == @luna-complex.Complex::new(0.2, -0.4))
}

///|
test "nested complex field operations compose" {
  let a = @luna-complex.Complex::new(1.0, 2.0)
  let b = @luna-complex.Complex::new(-0.5, 0.25)
  let z = @luna-complex.Complex::new(a, b)
  let one = @luna-complex.Complex::one()

  assert_true(z.conjugate() == @luna-complex.Complex::new(a, -b))
  assert_true(z * one == z)
  assert_true(nested_complex_approx_equal(z / z, one, 1.0e-12))
  assert_true(nested_complex_approx_equal(z.inv() * z, one, 1.0e-12))
}

///|
test "complex supports assert_eq via Debug" {
  assert_eq(
    @luna-complex.Complex::new(1, 2) + @luna-complex.Complex::new(3, 4),
    @luna-complex.Complex::new(4, 6),
  )
  debug_inspect(@luna-complex.Complex::new(1, -2), content="{ re: 1, im: -2 }")
}
