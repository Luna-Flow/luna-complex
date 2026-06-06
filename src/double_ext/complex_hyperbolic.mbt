///|
pub fn sinh(z : Complex[Double]) -> Complex[Double] {
  Complex::new(
    real_sinh(z.re) * real_cos(z.im),
    real_cosh(z.re) * real_sin(z.im),
  )
}

///|
pub fn cosh(z : Complex[Double]) -> Complex[Double] {
  Complex::new(
    real_cosh(z.re) * real_cos(z.im),
    real_sinh(z.re) * real_sin(z.im),
  )
}

///|
pub fn tanh(z : Complex[Double]) -> Complex[Double] {
  let re = z.re
  let im = z.im
  let cos_im = real_cos(im)
  let sinh_re = real_sinh(re)
  let denom = cos_im * cos_im + sinh_re * sinh_re
  if re > -1.0 && re < 1.0 {
    Complex::new(
      real_sinh(re) * real_cosh(re) / denom,
      0.5 * real_sin(2.0 * im) / denom,
    )
  } else {
    scaled_tanh_for_large_re(re, im)
  }
}

///|
pub fn sech(z : Complex[Double]) -> Complex[Double] {
  cosh(z).inv()
}

///|
pub fn csch(z : Complex[Double]) -> Complex[Double] {
  sinh(z).inv()
}

///|
pub fn coth(z : Complex[Double]) -> Complex[Double] {
  tanh(z).inv()
}

///|
pub fn asinh(z : Complex[Double]) -> Complex[Double] {
  if z.im == 0.0 {
    Complex::new(real_asinh(z.re), 0.0)
  } else if z.re == 0.0 {
    if z.im >= -1.0 && z.im <= 1.0 {
      Complex::new(0.0, real_asin(z.im))
    } else if z.im > 0.0 {
      Complex::new(real_acosh(z.im), half_pi)
    } else {
      Complex::new(-real_acosh(-z.im), -half_pi)
    }
  } else {
    let w = asin(Complex::new(-z.im, z.re))
    Complex::new(w.im, -w.re)
  }
}

///|
pub fn acosh(z : Complex[Double]) -> Complex[Double] {
  if z.im == 0.0 {
    return acosh_real(z.re)
  }
  if !z.re.is_nan() && !z.im.is_nan() && (z.re.is_inf() || z.im.is_inf()) {
    return Complex::new(@double.infinity, arg(z))
  }
  let left = sqrt(Complex::new(0.5 * (z.re + 1.0), 0.5 * z.im))
  let right = sqrt(Complex::new(0.5 * (z.re - 1.0), 0.5 * z.im))
  let w = log(left + right)
  Complex::new(2.0 * w.re, 2.0 * w.im)
}

///|
pub fn acosh_real(x : Double) -> Complex[Double] {
  if x.is_nan() {
    undefined_complex()
  } else if x >= 1.0 {
    Complex::new(real_acosh(x), 0.0)
  } else if x >= -1.0 {
    Complex::new(0.0, real_acos(x))
  } else {
    Complex::new(real_acosh(-x), tau)
  }
}

///|
pub fn atanh(z : Complex[Double]) -> Complex[Double] {
  if !z.re.is_nan() && !z.im.is_nan() && (z.re.is_inf() || z.im.is_inf()) {
    atanh_infinite(z.re, z.im)
  } else if z.im == 0.0 {
    atanh_real(z.re)
  } else {
    Complex::new(
      atanh_real_component(z.re, z.im),
      atanh_imag_component(z.re, z.im),
    )
  }
}

///|
pub fn atanh_real(x : Double) -> Complex[Double] {
  if x.is_nan() {
    undefined_complex()
  } else if x > -1.0 && x < 1.0 {
    Complex::new(real_atanh(x), 0.0)
  } else if x == 1.0 {
    Complex::new(1.0 / 0.0, 0.0)
  } else if x == -1.0 {
    Complex::new(-1.0 / 0.0, 0.0)
  } else {
    Complex::new(real_atanh(1.0 / x), half_pi)
  }
}

///|
pub fn asech(z : Complex[Double]) -> Complex[Double] {
  acosh(z.inv())
}

///|
pub fn acsch(z : Complex[Double]) -> Complex[Double] {
  asinh(z.inv())
}

///|
pub fn acoth(z : Complex[Double]) -> Complex[Double] {
  atanh(z.inv())
}
