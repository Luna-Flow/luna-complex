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
  let z = Complex::new(-self.im, self.re).asin()
  Complex::new(z.im, -z.re)
}

///|
pub fn Complex::acosh(self : Complex) -> Complex {
  let z = self.acos()
  if z.im <= 0.0 {
    Complex::new(-z.im, z.re)
  } else {
    Complex::new(z.im, -z.re)
  }
}

///|
pub fn Complex::acosh_real(x : Double) -> Complex {
  if x >= 1.0 {
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
  } else {
    let z = Complex::new(-self.im, self.re).atan()
    Complex::new(z.im, -z.re)
  }
}

///|
pub fn Complex::atanh_real(x : Double) -> Complex {
  if x > -1.0 && x < 1.0 {
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
