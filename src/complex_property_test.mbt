///|
using @qc {quick_check_fn}

///|
test "pow -1 matches inverse on non-zero complex numbers" {
  fn prop(pair : (Int, Int)) {
    let z = sample_complex_from_pair(pair)
    guard z != Complex::zero() else { true }
    complex_approx_equal_relaxed(z.pow(Complex::new(-1.0, 0.0)), z.inv())
  }

  quick_check_fn(prop)
}

///|
test "exp log roundtrip holds away from zero" {
  fn prop(pair : (Int, Int)) {
    let z = sample_complex_from_pair(pair)
    guard z != Complex::zero() else { true }
    complex_approx_equal_relaxed(z.log().exp(), z)
  }

  quick_check_fn(prop)
}

///|
test "sin asin roundtrip holds on real interval" {
  fn prop(x : Int) {
    let re = x.to_double() / 4.0
    guard re >= -1.0 && re <= 1.0 else { true }
    let z = Complex::new(re, 0.0)
    complex_approx_equal_relaxed(z.asin().sin(), z)
  }

  quick_check_fn(prop)
}

///|
test "cos acos roundtrip holds on bounded inputs" {
  fn prop(pair : (Int, Int)) {
    let z = sample_complex_from_pair(pair)
    guard z.re.abs() <= 1.0 && z.im.abs() <= 1.0 else { true }
    complex_approx_equal_relaxed(z.acos().cos(), z)
  }

  quick_check_fn(prop)
}

///|
test "tan atan roundtrip avoids singular imaginary axis" {
  fn prop(pair : (Int, Int)) {
    let z = sample_complex_from_pair(pair)
    guard z.im.abs() < 0.75 else { true }
    complex_approx_equal_relaxed(z.atan().tan(), z)
  }

  quick_check_fn(prop)
}

///|
test "sinh asinh roundtrip holds on bounded inputs" {
  fn prop(pair : (Int, Int)) {
    let z = sample_complex_from_pair(pair)
    guard z.re.abs() <= 1.0 && z.im.abs() <= 1.0 else { true }
    complex_approx_equal_relaxed(z.asinh().sinh(), z)
  }

  quick_check_fn(prop)
}

///|
test "tanh atanh roundtrip stays inside open unit strip" {
  fn prop(pair : (Int, Int)) {
    let z = sample_complex_from_pair(pair)
    guard z.re.abs() < 0.75 && z.im.abs() < 0.75 else { true }
    complex_approx_equal_relaxed(z.atanh().tanh(), z)
  }

  quick_check_fn(prop)
}

///|
test "reciprocal trig helpers match direct inversion" {
  fn prop(pair : (Int, Int)) {
    let z = sample_complex_from_pair(pair)
    guard z.sin() != Complex::zero() &&
      z.cos() != Complex::zero() &&
      z.tan() != Complex::zero() else {
      true
    }
    complex_approx_equal_relaxed(z.sec(), z.cos().inv()) &&
    complex_approx_equal_relaxed(z.csc(), z.sin().inv()) &&
    complex_approx_equal_relaxed(z.cot(), z.tan().inv())
  }

  quick_check_fn(prop)
}

///|
test "hyperbolic reciprocal helpers match direct inversion" {
  fn prop(pair : (Int, Int)) {
    let z = sample_complex_from_pair(pair)
    guard z.sinh() != Complex::zero() &&
      z.cosh() != Complex::zero() &&
      z.tanh() != Complex::zero() else {
      true
    }
    complex_approx_equal_relaxed(z.sech(), z.cosh().inv()) &&
    complex_approx_equal_relaxed(z.csch(), z.sinh().inv()) &&
    complex_approx_equal_relaxed(z.coth(), z.tanh().inv())
  }

  quick_check_fn(prop)
}
