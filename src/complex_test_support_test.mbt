///|
let tol = 1.0e-15

///|
fn approx_equal(a : Double, b : Double, tol : Double) -> Bool {
  Double::abs(a - b) < tol
}

///|
fn complex_approx_equal(a : Complex, b : Complex, tol : Double) -> Bool {
  approx_equal(a.re, b.re, tol) && approx_equal(a.im, b.im, tol)
}

///|
fn approx_equal_relaxed(a : Double, b : Double) -> Bool {
  approx_equal(a, b, 1.0e-10)
}

///|
fn complex_approx_equal_relaxed(a : Complex, b : Complex) -> Bool {
  approx_equal_relaxed(a.re, b.re) && approx_equal_relaxed(a.im, b.im)
}

///|
fn assert_complex_special(
  z : Complex,
  re_is_nan : Bool,
  re_is_pos_inf : Bool,
  re_is_neg_inf : Bool,
  im_is_nan : Bool,
  im_is_pos_inf : Bool,
  im_is_neg_inf : Bool,
) -> Bool {
  z.re.is_nan() == re_is_nan &&
  z.re.is_pos_inf() == re_is_pos_inf &&
  z.re.is_neg_inf() == re_is_neg_inf &&
  z.im.is_nan() == im_is_nan &&
  z.im.is_pos_inf() == im_is_pos_inf &&
  z.im.is_neg_inf() == im_is_neg_inf
}

///|
fn sample_complex_from_pair(pair : (Int, Int)) -> Complex {
  let (re, im) = pair
  Complex::new(re.to_double() / 4.0, im.to_double() / 4.0)
}
