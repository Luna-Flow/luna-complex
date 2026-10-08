///|
test "generic complex algebraic laws over ints" {
  let z = @luna-complex.Complex::new(3, -4)
  let w = @luna-complex.Complex::new(-2, 5)
  let u = @luna-complex.Complex::new(1, 7)

  assert_true(z + @luna-complex.Complex::zero() == z)
  assert_true(z * @luna-complex.Complex::one() == z)
  assert_true(z.conjugate().conjugate() == z)
  assert_true(z + w + u == z + (w + u))
  assert_true(z * w * u == z * (w * u))
  assert_true((z * w).conjugate() == z.conjugate() * w.conjugate())
}
