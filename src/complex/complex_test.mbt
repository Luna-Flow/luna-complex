///|
const Tol = 1.0e-6

// Helper function to compare two Double values within a given tolerance.
///|
fn approx_equal(a : Double, b : Double, tol : Double) -> Bool {
  Double::abs(a - b) < tol
}

// Helper function to compare two Complex numbers approximately.
///|
fn complex_approx_equal(a : Complex, b : Complex, tol : Double) -> Bool {
  approx_equal(a.re, b.re, tol) && approx_equal(a.im, b.im, tol)
}

test "Complex/construction" {
  let z = Complex::new(3.7, -4.1)
  // Using inspect! to check that the real and imaginary parts match.
  inspect!(z.re, content="3.7")
  inspect!(z.im, content="-4.1")
}

test "Complex/setters" {
  let z = Complex::new(0.0, 0.0)
  z.set(5.1, -2.1)
  inspect!(z.re, content="5.1")
  inspect!(z.im, content="-2.1")
  z.set_re(10.5)
  inspect!(z.re, content="10.5")
  z.set_im(20.6)
  inspect!(z.im, content="20.6")
}

test "Complex/native_pack and pack" {
  let z = Complex::new(1.5, -3.0)
  let arr = Array::make(10, 0.0) // array of sufficient length (holds 5 complex numbers)
  // Pack using native_pack directly.
  Complex::native_pack(z.re, z.im, arr, 1)
  // Verify that arr[2] and arr[3] hold the correct values.
  println(arr)
  inspect!(arr[2], content="1.5")
  inspect!(arr[3], content="-3")

  // Pack using the object's pack method.
  let arr2 = Array::make(10, 0.0)
  z.pack(arr2, 2)
  inspect!(arr2[4], content="1.5")
  inspect!(arr2[5], content="-3")
}

test "Complex/polar, arg, abs, abs_sqr, abs_log" {
  // Create a complex number from polar coordinates.
  let r = 5.0
  let theta = @luna_math.PI / 4.0
  let z = Complex::polar(r, theta)
  // Expected real and imaginary parts are r*cos(theta) and r*sin(theta)
  let expected = Complex::new(
    r * @luna_math.cos(theta),
    r * @luna_math.sin(theta),
  )
  assert_eq!(complex_approx_equal(z, expected, Tol), true)

  // Test arg: For expected value PI/4 for a number in the first quadrant.
  let arg_val = z.arg()
  assert_eq!(approx_equal(arg_val, theta, Tol), true)

  // Test abs,abs_sqr,abs_log: For (3,4), the absolute value should be 5.
  let z2 = Complex::new(3.0, 4.0)
  let abs_val = z2.abs()
  let abs_sqr_val = z2.abs_sqr()
  let abs_log_val = z2.abs_log()
  assert_eq!(approx_equal(abs_val, 5.0, Tol), true)
  assert_eq!(approx_equal(abs_sqr_val, 25.0, Tol), true)
  assert_eq!(approx_equal(abs_log_val, @luna_math.log(5.0), Tol), true)
}

test "Complex/basic arithmetic" {
  let a = Complex::new(2.0, 3.0)
  let b = Complex::new(4.0, -1.0)

  // Addition (operator version)
  let c = a.op_add(b)
  let expected_add = Complex::new(6.0, 2.0)
  assert_eq!(complex_approx_equal(c, expected_add, Tol), true)

  // Subtraction (operator version)
  let d = a.op_sub(b)
  let expected_sub = Complex::new(-2.0, 4.0)
  assert_eq!(complex_approx_equal(d, expected_sub, Tol), true)

  // Multiplication (operator version)
  let e = a.op_mul(b)
  // (2+3i)*(4-i) = 2*4 + 2*(-i) + 3i*4 + 3i*(-i) = 8 -2i +12i -3(i^2) = 8 +10i +3 = 11+10i
  let expected_mul = Complex::new(11.0, 10.0)
  assert_eq!(complex_approx_equal(e, expected_mul, Tol), true)

  // Division (operator version)
  let f = a.op_div(b)
  // (2+3i)*(4+i)/(4*4+1*1) = (5+14i)/17
  let expected_div = Complex::new(5.0 / 17.0, 14.0 / 17.0)
  assert_eq!(complex_approx_equal(f, expected_div, Tol), true)
}

test "Complex/real operations" {
  let z = Complex::new(3.0, 4.0)

  // Test adding a real number.
  let z_add = z.add_real(2.0)
  let expected_add = Complex::new(5.0, 4.0)
  assert_eq!(complex_approx_equal(z_add, expected_add, Tol), true)

  // Test multiplying by a real number.
  let z_mul = z.mul_real(2.0)
  let expected_mul = Complex::new(6.0, 8.0)
  assert_eq!(complex_approx_equal(z_mul, expected_mul, Tol), true)

  // Test subtracting a real number.
  let z_sub = z.sub_real(1.0)
  let expected_sub = Complex::new(2.0, 4.0)
  assert_eq!(complex_approx_equal(z_sub, expected_sub, Tol), true)

  // Test dividing by a real number.
  let z_div = z.div_real(2.0)
  let expected_div = Complex::new(1.5, 2.0)
  assert_eq!(complex_approx_equal(z_div, expected_div, Tol), true)
}

test "Complex/exp and log functions" {
  // Test exp: exp(0+0i) should equal 1+0i.
  // exp(1+1i) should equal [e^1*cos(1) + e^1*sin(1)i]
  let z0 = Complex::new(0.0, 0.0)
  let exp0 = z0.exp()
  z0.set(1.0, 1.0)
  let exp1 = z0.exp()
  let expected_exp0 = Complex::new(1.0, 0.0)
  let expected_exp1 = Complex::new(
    @luna_math.exp(1.0) * @luna_math.cos(1),
    @luna_math.exp(1.0) * @luna_math.sin(1.0),
  )
  assert_eq!(complex_approx_equal(exp0, expected_exp0, Tol), true)
  assert_eq!(complex_approx_equal(exp1, expected_exp1, Tol), true)

  // Test log: For a positive real number, log(z) should be (ln(|z|),0)
  // ln(10+10i) = [(ln(10)+ln(2)/2) + (PI/4)i]
  let z1 = Complex::new(10.0, 10.0)
  let logz = z1.log()
  let expected_log = Complex::new(
    @luna_math.log(10.0) + @luna_math.log(2) / 2,
    @luna_math.PI / 4,
  )
  assert_eq!(complex_approx_equal(logz, expected_log, Tol), true)

  // Test log10: log10(10+10i) should be [ln(10+10i) / ln(10)].
  let log10z = z1.log10()
  let expected_log10 = expected_log.mul_real(1.0 / @luna_math.log(10))
  assert_eq!(complex_approx_equal(log10z, expected_log10, Tol), true)

  // Test log_b: log(1-i)[1+i] = ln(1+i) / ln(1-i)
  let z2_1 = Complex::new(1, 1)
  let z2_2 = Complex::new(1, -1)
  let logb = z2_1.log_b(z2_2)
  let expected_log_b = z2_1.log() / z2_2.log()
  assert_eq!(complex_approx_equal(logb, expected_log_b, Tol), true)
}

test "Complex/trigonometric functions" {
  // Test sin for a real angle
  // sin(a+bi) = sin(a)cosh(b) + icos(a)sinh(b)
  let z = Complex::new(1.0, 1.0)
  let sinz = z.sin()
  let expected_sin = Complex::new(
    @luna_math.sin(1) * @luna_math.cosh(1),
    @luna_math.cos(1) * @luna_math.sinh(1),
  )
  assert_eq!(complex_approx_equal(sinz, expected_sin, Tol), true)

  // Test cos for a real angle
  // cos(a+bi) = cos(a)cosh(b) − isin(a)sinh(b) 
  let cosz = z.cos()
  let expected_cos = Complex::new(
    @luna_math.cos(1) * @luna_math.cosh(1),
    -@luna_math.sin(1) * @luna_math.sinh(1),
  )
  assert_eq!(complex_approx_equal(cosz, expected_cos, Tol), true)

  // Test tan for a real angle
  let tanz = z.tan()
  let expected_tan = expected_sin / expected_cos
  assert_eq!(complex_approx_equal(tanz, expected_tan, Tol), true)
}

test "Complex/inverse trigonometric functions" {
  // For real numbers, asin and acos should return real values.
  let z = Complex::new(0.5, 0.0)
  let asin_z = z.asin()
  let acos_z = z.acos()
  // Check that the sum of asin and acos is close to π/2.
  assert_eq!(
    approx_equal(asin_z.re + acos_z.re, @luna_math.PI / 2.0, Tol),
    true,
  )
}

test "Complex/hyperbolic functions" {
  let z = Complex::new(1.0, 0.0)
  let sinhz = z.sinh()
  let coshz = z.cosh()
  // For real numbers: cosh^2 - sinh^2 = 1
  let diff = @luna_math.pow(coshz.re, 2.0) - @luna_math.pow(sinhz.re, 2.0)
  assert_eq!(approx_equal(diff, 1.0, Tol), true)
}

test "Complex/inverse hyperbolic functions" {
  // Test asinh: asinh(0) should be 0.
  let z0 = Complex::new(0.0, 0.0)
  let asinhz = z0.asinh()
  assert_eq!(complex_approx_equal(asinhz, Complex::new(0.0, 0.0), Tol), true)

  // Test atanh for a small real number.
  let z1 = Complex::new(0.5, 0.0)
  let atanhz = z1.atanh()
  let expected_atanh = Complex::new(@luna_math.atanh(0.5), 0.0)
  assert_eq!(complex_approx_equal(atanhz, expected_atanh, Tol), true)
}

test "Complex/equality" {
  let a = Complex::new(2.0, 3.0)
  let b = Complex::new(2.0, 3.0)
  let c = Complex::new(2.0, -3.0)
  assert_eq!(a == b, true)
  assert_eq!(a == c, false)
}
