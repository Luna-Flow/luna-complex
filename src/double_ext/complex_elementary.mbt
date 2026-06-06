///|
let inv_log_e_10 : Double = 1.0 / real_ln(10.0)

///|
pub fn native_pack(
  re : Double,
  im : Double,
  arr : Array[Double],
  offset : Int,
) -> Unit {
  guard arr.length() % 2 == 0
  if offset == arr.length() / 2 {
    arr.push(re)
    arr.push(im)
  } else {
    guard offset >= 0 && offset < arr.length() / 2
    arr[2 * offset] = re
    arr[2 * offset + 1] = im
  }
}

///|
pub fn pack(z : Complex[Double], arr : Array[Double], offset : Int) -> Unit {
  native_pack(z.re, z.im, arr, offset)
}

///|
pub fn polar(r : Double, theta : Double) -> Complex[Double] {
  Complex::new(r * real_cos(theta), r * real_sin(theta))
}

///|
pub fn arg(z : Complex[Double]) -> Double {
  guard z.re != 0.0 || z.im != 0.0 else { 0.0 }
  if z.im == 0.0 && z.re < 0.0 {
    tau
  } else {
    let theta = real_atan2(z.im, z.re)
    if theta < -tau || theta == -tau || (is_negative_zero(z.im) && z.re < 0.0) {
      tau
    } else {
      theta
    }
  }
}

///|
pub fn abs(z : Complex[Double]) -> Double {
  @lm.hypot(z.re, z.im)
}

///|
pub fn abs_sqr(z : Complex[Double]) -> Double {
  let re_abs = z.re.abs()
  let im_abs = z.im.abs()
  let max_val = maximum(re_abs, im_abs)
  if max_val == 0.0 {
    return 0.0
  }
  let re_scaled = z.re / max_val
  let im_scaled = z.im / max_val
  max_val * max_val * (re_scaled * re_scaled + im_scaled * im_scaled)
}

///|
pub fn abs_log(z : Complex[Double]) -> Double {
  let re_abs = z.re.abs()
  let im_abs = z.im.abs()
  if re_abs == 0.0 && im_abs == 0.0 {
    return @double.neg_infinity
  }
  let t = if re_abs >= im_abs { im_abs / re_abs } else { re_abs / im_abs }
  real_ln(maximum(re_abs, im_abs)) + 0.5 * real_ln(1.0 + t * t)
}

///|
pub fn sqrt(z : Complex[Double]) -> Complex[Double] {
  guard z.re != 0.0 || z.im != 0.0 else { Complex::new(0.0, 0.0) }
  let re_abs = z.re.abs()
  let im_abs = z.im.abs()
  let w = if re_abs >= im_abs {
    let t = im_abs / re_abs
    real_sqrt(re_abs) * real_sqrt(0.5 * (1.0 + @lm.hypot(1.0, t)))
  } else {
    let t = re_abs / im_abs
    real_sqrt(im_abs) * real_sqrt(0.5 * (t + @lm.hypot(1.0, t)))
  }
  if z.re >= 0.0 {
    Complex::new(w, z.im / (2.0 * w))
  } else {
    let im = if z.im >= 0.0 { w } else { -w }
    Complex::new(z.im / (2.0 * im), im)
  }
}

///|
pub fn sqrt_real(x : Double) -> Complex[Double] {
  if x >= 0.0 {
    Complex::new(real_sqrt(x), 0.0)
  } else {
    Complex::new(0.0, real_sqrt(-x))
  }
}

///|
pub fn exp(z : Complex[Double]) -> Complex[Double] {
  let rho = real_exp(z.re)
  let theta = z.im
  Complex::new(rho * real_cos(theta), rho * real_sin(theta))
}

///|
pub fn pow(z : Complex[Double], other : Complex[Double]) -> Complex[Double] {
  if z.re == 0.0 && z.im == 0.0 {
    if other.re == 0.0 && other.im == 0.0 {
      Complex::new(1.0, 0.0)
    } else if other.im == 0.0 && other.re > 0.0 {
      Complex::new(0.0, 0.0)
    } else {
      undefined_complex()
    }
  } else if other.re == 1.0 && other.im == 0.0 {
    z
  } else if other.re == -1.0 && other.im == 0.0 {
    z.inv()
  } else if other.im == 0.0 &&
    other.re == other.re.trunc() &&
    other.re.abs() <= 2147483647.0 {
    complex_pow_integer(z, other.re.to_int())
  } else {
    let log_re = abs_log(z)
    let theta = arg(z)
    let rho = real_exp(log_re * other.re - other.im * theta)
    let beta = theta * other.re + other.im * log_re
    Complex::new(rho * real_cos(beta), rho * real_sin(beta))
  }
}

///|
pub fn pow_real(z : Complex[Double], other : Double) -> Complex[Double] {
  if z.re == 0.0 && z.im == 0.0 {
    if other == 0.0 {
      Complex::new(1.0, 0.0)
    } else if other > 0.0 {
      Complex::new(0.0, 0.0)
    } else {
      undefined_complex()
    }
  } else if other == other.trunc() && other.abs() <= 2147483647.0 {
    complex_pow_integer(z, other.to_int())
  } else {
    let log_re = abs_log(z)
    let theta = arg(z)
    let rho = real_exp(log_re * other)
    let beta = theta * other
    Complex::new(rho * real_cos(beta), rho * real_sin(beta))
  }
}

///|
pub fn log(z : Complex[Double]) -> Complex[Double] {
  Complex::new(abs_log(z), arg(z))
}

///|
pub fn log_10(z : Complex[Double]) -> Complex[Double] {
  let z_log = log(z)
  Complex::new(z_log.re * inv_log_e_10, z_log.im * inv_log_e_10)
}

///|
pub fn log_b(z : Complex[Double], b : Complex[Double]) -> Complex[Double] {
  div(log(z), log(b))
}

///|
pub fn op_bin_re(
  z : Complex[Double],
  other : Double,
  f : (Complex[Double], Complex[Double]) -> Complex[Double],
) -> Complex[Double] {
  f(z, Complex::new(other, 0.0))
}

///|
pub fn op_bin_im(
  z : Complex[Double],
  other : Double,
  f : (Complex[Double], Complex[Double]) -> Complex[Double],
) -> Complex[Double] {
  f(z, Complex::new(0.0, other))
}

///|
pub fn div(z : Complex[Double], other : Complex[Double]) -> Complex[Double] {
  if !z.re.is_nan() &&
    !z.im.is_nan() &&
    (other.re.is_inf() || other.im.is_inf()) {
    quotient_with_infinite_denominator(z.re, z.im, other.re, other.im)
  } else {
    stable_quotient(z.re, z.im, other.re, other.im)
  }
}
