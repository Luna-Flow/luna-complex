///|
const Tol = 1.0e-15

///|
fn approx_equal(a : Double, b : Double, tol : Double) -> Bool {
  Double::abs(a - b) < tol
}

///|
fn complex_approx_equal(a : Complex, b : Complex, tol : Double) -> Bool {
  approx_equal(a.re, b.re, tol) && approx_equal(a.im, b.im, tol)
}

///|
test "basic operations" {
  let a = Complex::new(1, 2)
  let b = Complex::new(3, 4)
  let b_ = Complex::new(0.5, 1)
  let c = a + b
  assert_true!(c == Complex::new(4, 6))
  let c = a - b
  assert_true!(c == Complex::new(-2, -2))
  let c = a * b
  assert_true!(c == Complex::new(-5, 10))
  let c = a / b_
  assert_true!(c == Complex::new(2, 0))
  let c = -a
  assert_true!(c == Complex::new(-1, -2))
  let c = a.conjugate()
  assert_true!(c == Complex::new(1, -2))
  let c = a.abs_sqr()
  assert_true!(c == 5)
  let c = a.abs()
  assert_true!(c == 2.23606797749979)
  let c = b.abs_log()
  assert_true!(c == 1.6094379124341003)
  let c = a.inv()
  assert_true!(c == Complex::new(0.2, -0.4))

  //math
  let x = Complex::new(1, 1)
  //polar
  let c = Complex::polar(1.0, @lm.PI_OVER_4)
  assert_true!(c == Complex::new(0.7071067811865476, 0.7071067811865475))
  //sqrt
  let c = Complex::sqrt_real(-9)
  assert_true!(c == Complex::new(0, 3))
  let c = Complex::new(-3, 4).sqrt()
  assert_true!(c == Complex::new(1, 2) || c == Complex::new(-1, -2))
  //pow 
  let c = a.pow_real(2)
  assert_true!(complex_approx_equal(c, Complex::new(-3, 4), Tol))
  let c = x.pow(x)
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(0.2739572538301211, 0.5837007587586147),
      Tol,
    ),
  )
  //arg 
  let c = Complex::new(0, 1).arg()
  assert_true!(c == 1.5707963267948966)
  //exp
  let c = Complex::new(1, 1).exp()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(1.4686939399158851, 2.2873552871788423),
      Tol,
    ),
  )
  //log
  let c = x.log()
  assert_true!(c == Complex::new(0.34657359027997264, 0.7853981633974483))
  let c = x.log_10()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(0.15051499783199057, 0.3410940884604603),
      Tol,
    ),
  )
  let c = x.log_b(a)
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(0.6130442078620816, 0.13255193491810882),
      Tol,
    ),
  )
}

///|
test "struct related" {
  let a = Complex::new(1, 2)
  let arr : Array[Double] = [1, 2, 3, 4]
  a.pack(arr, 1)
  assert_eq!(arr, [1, 2, 1, 2])
  a.pack(arr, 2)
  assert_eq!(arr, [1, 2, 1, 2, 1, 2])
}

///|
test "update operation" {
  let a = Complex::new(1, 2)
  a.set(2, 1)
  assert_true!(a == Complex::new(2, 1))
  a.set_re(1)
  assert_true!(a == Complex::new(1, 1))
  a.set_im(2)
  assert_true!(a == Complex::new(1, 2))
}

///|
test "trigonometric functions" {
  let a = Complex::new(1, 1)
  let c = a.sin()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(1.2984575814159773, 0.6349639147847361),
      Tol,
    ),
  )
  let c = a.cos()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(0.8337300251311491, -0.9888977057628651),
      Tol,
    ),
  )
  let c = a.tan()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(0.2717525853121625, 1.0839233273386946),
      Tol,
    ),
  )
  let c = a.sec()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(0.49833703055518674, 0.5910838417210449),
      Tol,
    ),
  )
  let c = a.csc()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(0.6215180171704283, -0.3039310016284264),
      Tol,
    ),
  )
  let c = a.cot()
  assert_true!(
    complex_approx_equal(
      c, 
      Complex::new(0.217621561849, -0.868014142899), 
      Tol,
    ),
  )
}

///|
test "inverse trigonometric functions" {
  let a = Complex::new(1, 1)
  let c = a.asin()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(0.6662394324925153, 1.0612750619050355),
      Tol,
    ),
  )
  let c = a.acos()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(0.9045568943023813, -1.0612750619050355),
      Tol,
    ),
  )
  let c = a.atan()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(1.0172219678978514, 0.40235947810852507),
      Tol,
    ),
  )
  let c = a.asec()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(1.1185178796437059, 0.5306375309525179),
      Tol,
    ),
  )
  let c = a.acsc()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(0.45227844715119064, -0.5306375309525179),
      Tol,
    ),
  )
  let c = a.acot()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(0.5535743588970452, -0.402359478108525),
      Tol,
    ),
  )
}

///|
test "hyperbolic functions" {
  let a = Complex::new(1, 1)
  let c = a.sinh()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(0.634963914784736128, 1.298457581415977335),
      Tol,
    ),
  )
  let c = a.cosh()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(0.833730025131149133, 0.988897705762865065),
      Tol,
    ),
  )
  let c = a.tanh()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(1.0839233273386948, 0.27175258531951174),
      Tol,
    ),
  )
  let c = a.sech()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(0.49833703055518686, -0.5910838417210451),
      Tol,
    ),
  )
  let c = a.csch()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(0.30393100162842646, -0.6215180171704285),
      Tol,
    ),
  )
  let c = a.coth()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(0.868014142895925, -0.2176215618544027),
      Tol,
    ),
  )
}

///|
test "inverse hyperbolic functions" {
  let a = Complex::new(1, 1)
  let c = a.asinh()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(1.0612750619050357, 0.6662394324925153),
      Tol,
    ),
  )
  let c = a.acosh()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(1.0612750619050355, 0.9045568943023813),
      Tol,
    ),
  )
  let c = a.atanh()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(0.40235947810852507, 1.0172219678978514),
      Tol,
    ),
  )
  let c = a.asech()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(0.5306375309525179, -1.1185178796437059),
      Tol,
    ),
  )
  let c = a.acsch()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(0.5306375309525179, -0.45227844715119064),
      Tol,
    ),
  )
  let c = a.acoth()
  assert_true!(
    complex_approx_equal(
      c,
      Complex::new(0.40235947810852507, -0.5535743588970452),
      Tol,
    ),
  )
}

