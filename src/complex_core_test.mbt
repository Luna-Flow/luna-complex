///|
test "complex constructors and algebra" {
  assert_true(Complex::zero() == Complex::new(0.0, 0.0))
  assert_true(Complex::one() == Complex::new(1.0, 0.0))

  let a = Complex::new(1.0, 2.0)
  let b = Complex::new(3.0, 4.0)
  let b_div = Complex::new(0.5, 1.0)

  assert_true(a + b == Complex::new(4.0, 6.0))
  assert_true(a - b == Complex::new(-2.0, -2.0))
  assert_true(a * b == Complex::new(-5.0, 10.0))
  assert_true(a / b_div == Complex::new(2.0, 0.0))
  assert_true(-a == Complex::new(-1.0, -2.0))
  assert_true(a.conjugate() == Complex::new(1.0, -2.0))
  assert_true(a.inv() == Complex::new(0.2, -0.4))
  assert_true(a.abs_sqr() == 5.0)
  assert_true(a.abs() == 2.23606797749979)
  assert_true(b.abs_log() == 1.6094379124341003)
}

///|
test "complex packing and updates" {
  let z = Complex::new(1.0, 2.0)
  let arr : Array[Double] = [1.0, 2.0, 3.0, 4.0]

  z.pack(arr, 1)
  assert_true(arr == [1.0, 2.0, 1.0, 2.0])

  z.pack(arr, 2)
  assert_true(arr == [1.0, 2.0, 1.0, 2.0, 1.0, 2.0])

  z.set(2.0, 1.0)
  assert_true(z == Complex::new(2.0, 1.0))
  z.set_re(1.0)
  assert_true(z == Complex::new(1.0, 1.0))
  z.set_im(2.0)
  assert_true(z == Complex::new(1.0, 2.0))
}

///|
test "complex elementary functions" {
  let a = Complex::new(1.0, 2.0)
  let x = Complex::new(1.0, 1.0)

  assert_true(
    complex_approx_equal(
      Complex::polar(1.0, @lm.PI_OVER_4),
      Complex::new(0.7071067811865476, 0.7071067811865475),
      tol,
    ),
  )
  assert_true(Complex::sqrt_real(-9.0) == Complex::new(0.0, 3.0))
  assert_true(
    Complex::new(-3.0, 4.0).sqrt() == Complex::new(1.0, 2.0) ||
    Complex::new(-3.0, 4.0).sqrt() == Complex::new(-1.0, -2.0),
  )
  assert_true(
    complex_approx_equal(a.pow_real(2.0), Complex::new(-3.0, 4.0), tol),
  )
  assert_true(
    complex_approx_equal(
      x.pow(x),
      Complex::new(0.2739572538301211, 0.5837007587586147),
      tol,
    ),
  )
  assert_true(Complex::new(0.0, 1.0).arg() == 1.5707963267948966)
  assert_true(
    complex_approx_equal(
      x.exp(),
      Complex::new(1.4686939399158851, 2.2873552871788423),
      tol,
    ),
  )
  assert_true(x.log() == Complex::new(0.34657359027997264, 0.7853981633974483))
  assert_true(
    complex_approx_equal(
      x.log_10(),
      Complex::new(0.15051499783199057, 0.3410940884604603),
      tol,
    ),
  )
  assert_true(
    complex_approx_equal(
      x.log_b(a),
      Complex::new(0.6130442078620816, 0.13255193491810882),
      tol,
    ),
  )
}
