///|
fn scaled_tanh_for_large_re(re : Double, im : Double) -> Complex {
  let sign = if re >= 0.0 { 1.0 } else { -1.0 }
  let decay = exp(-2.0 * re.abs())
  let decay_sq = decay * decay
  let sin_2im = sin(2.0 * im)
  let cos_2im = cos(2.0 * im)
  let denom = 1.0 + decay_sq + 2.0 * decay * cos_2im
  Complex::new(sign * (1.0 - decay_sq) / denom, 2.0 * decay * sin_2im / denom)
}

///|
fn atanh_real_component(re : Double, im : Double) -> Double {
  let u = 4.0 * re / ((1.0 - re) * (1.0 - re) + im * im)
  if u.abs() < 0.25 {
    0.25 * log1p(u)
  } else {
    let a = hypot(1.0 + re, im)
    let b = hypot(1.0 - re, im)
    0.5 * log(a / b)
  }
}

///|
fn atanh_imag_component(re : Double, im : Double) -> Double {
  let re_abs = re.abs()
  let im_abs = im.abs()
  let max_val = maximum(re_abs, im_abs)
  if max_val == 0.0 {
    return 0.0
  }
  if max_val <= 1.0 {
    return 0.5 * atan2(2.0 * im, 1.0 - re * re - im * im)
  }
  let re_scaled = re / max_val
  let im_scaled = im / max_val
  let inv_scale_sq = 1.0 / (max_val * max_val)
  0.5 * atan2(
    2.0 * im_scaled / max_val,
    inv_scale_sq - re_scaled * re_scaled - im_scaled * im_scaled,
  )
}

///|
pub fn Complex::sinh(self : Complex) -> Complex {
  Complex::new(sinh(self.re) * cos(self.im), cosh(self.re) * sin(self.im))
}

///|
pub fn Complex::cosh(self : Complex) -> Complex {
  Complex::new(cosh(self.re) * cos(self.im), sinh(self.re) * sin(self.im))
}

///|
pub fn Complex::tanh(self : Complex) -> Complex {
  let re = self.re
  let im = self.im
  let denom = pow(cos(im), 2.0) + pow(sinh(re), 2.0)
  if re > -1.0 && re < 1.0 {
    Complex::new(sinh(re) * cosh(re) / denom, 0.5 * sin(2.0 * im) / denom)
  } else {
    scaled_tanh_for_large_re(re, im)
  }
}

///|
pub fn Complex::sech(self : Complex) -> Complex {
  self.cosh().inv()
}

///|
pub fn Complex::csch(self : Complex) -> Complex {
  self.sinh().inv()
}

///|
pub fn Complex::coth(self : Complex) -> Complex {
  self.tanh().inv()
}

///|
pub fn Complex::asinh(self : Complex) -> Complex {
  if self.im == 0.0 {
    Complex::new(asinh(self.re), 0.0)
  } else if self.re == 0.0 {
    if self.im >= -1.0 && self.im <= 1.0 {
      Complex::new(0.0, asin(self.im))
    } else if self.im > 0.0 {
      Complex::new(acosh(self.im), @lm.DOUBLE_PI / 2.0)
    } else {
      Complex::new(-acosh(-self.im), -@lm.DOUBLE_PI / 2.0)
    }
  } else {
    let z = Complex::new(-self.im, self.re).asin()
    Complex::new(z.im, -z.re)
  }
}

///|
pub fn Complex::acosh(self : Complex) -> Complex {
  if self.im == 0.0 {
    return Complex::acosh_real(self.re)
  }
  let left = Complex::new(0.5 * (self.re + 1.0), 0.5 * self.im).sqrt()
  let right = Complex::new(0.5 * (self.re - 1.0), 0.5 * self.im).sqrt()
  let z = (left + right).log()
  Complex::new(2.0 * z.re, 2.0 * z.im)
}

///|
pub fn Complex::acosh_real(x : Double) -> Complex {
  if x.is_nan() {
    undefined_complex()
  } else if x >= 1.0 {
    Complex::new(acosh(x), 0.0)
  } else if x >= -1.0 {
    Complex::new(0.0, acos(x))
  } else {
    Complex::new(acosh(-x), @lm.DOUBLE_PI)
  }
}

///|
pub fn Complex::atanh(self : Complex) -> Complex {
  if self.im == 0.0 {
    Complex::atanh_real(self.re)
  } else if self.im.is_pos_inf() {
    Complex::new(0.0, @lm.DOUBLE_PI / 2.0)
  } else if self.im.is_neg_inf() {
    Complex::new(0.0, -@lm.DOUBLE_PI / 2.0)
  } else {
    Complex::new(
      atanh_real_component(self.re, self.im),
      atanh_imag_component(self.re, self.im),
    )
  }
}

///|
pub fn Complex::atanh_real(x : Double) -> Complex {
  if x.is_nan() {
    undefined_complex()
  } else if x > -1.0 && x < 1.0 {
    Complex::new(atanh(x), 0.0)
  } else if x == 1.0 {
    Complex::new(1.0 / 0.0, 0.0)
  } else if x == -1.0 {
    Complex::new(-1.0 / 0.0, 0.0)
  } else {
    Complex::new(atanh(1.0 / x), @lm.DOUBLE_PI / 2.0)
  }
}

///|
pub fn Complex::asech(self : Complex) -> Complex {
  self.inv().acosh()
}

///|
pub fn Complex::acsch(self : Complex) -> Complex {
  self.inv().asinh()
}

///|
pub fn Complex::acoth(self : Complex) -> Complex {
  self.inv().atanh()
}
