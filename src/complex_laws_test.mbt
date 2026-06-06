///|
test "generic complex algebraic laws over ints" {
  let z = Complex::new(3, -4)
  let w = Complex::new(-2, 5)
  let u = Complex::new(1, 7)

  assert_true(z + Complex::zero() == z)
  assert_true(z * Complex::one() == z)
  assert_true(z.conjugate().conjugate() == z)
  assert_true(z + w + u == z + (w + u))
  assert_true(z * w * u == z * (w * u))
  assert_true((z * w).conjugate() == z.conjugate() * w.conjugate())
}
