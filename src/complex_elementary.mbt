///|
let inv_log_e_10 : Double = 1.0 / log(10)

///|
fn stable_quotient(
  a : Double,
  b : Double,
  c : Double,
  d : Double,
) -> Complex {
  let c_abs = c.abs()
  let d_abs = d.abs()
  if c_abs >= d_abs {
    let ratio = d / c
    let denom = 1.0 + ratio * ratio
    let scale = 1.0 / c
    Complex::new(
      (a * scale + b * scale * ratio) / denom,
      (b * scale - a * scale * ratio) / denom,
    )
  } else {
    let ratio = c / d
    let denom = 1.0 + ratio * ratio
    let scale = 1.0 / d
    Complex::new(
      (a * scale * ratio + b * scale) / denom,
      (b * scale * ratio - a * scale) / denom,
    )
  }
}

///|
fn complex_pow_integer(base : Complex, exponent : Int) -> Complex {
  if exponent == 0 {
    return Complex::one()
  }
  if exponent < 0 {
    return complex_pow_integer(base.inv(), -exponent)
  }
  let mut result = Complex::one()
  let mut factor = base
  let mut power = exponent
  while power > 0 {
    if power % 2 == 1 {
      result = result * factor
    }
    power = power / 2
    if power > 0 {
      factor = factor * factor
    }
  }
  result
}

///|
pub fn Complex::polar(r : Double, theta : Double) -> Complex {
  Complex::new(r * cos(theta), r * sin(theta))
}

///|
pub fn Complex::arg(self : Complex) -> Double {
  guard self.re != 0.0 || self.im != 0.0 else { 0.0 }
  atan2(self.im, self.re)
}

///|
pub fn Complex::abs(self : Complex) -> Double {
  hypot(self.re, self.im)
}

///|
pub fn Complex::abs_sqr(self : Complex) -> Double {
  let re_abs = self.re.abs()
  let im_abs = self.im.abs()
  let max_val = maximum(re_abs, im_abs)
  if max_val == 0.0 {
    return 0.0
  }
  let re_scaled = self.re / max_val
  let im_scaled = self.im / max_val
  max_val * max_val * (re_scaled * re_scaled + im_scaled * im_scaled)
}

///|
pub fn Complex::abs_log(self : Complex) -> Double {
  let re_abs = self.re.abs()
  let im_abs = self.im.abs()
  if re_abs == 0.0 && im_abs == 0.0 {
    return @double.neg_infinity
  }
  let t = if re_abs >= im_abs { im_abs / re_abs } else { re_abs / im_abs }
  log(maximum(re_abs, im_abs)) + 0.5 * log(1.0 + t * t)
}

///|
pub impl Div for Complex with fn div(self, other) -> Complex {
  guard other.re != 0.0 || other.im != 0.0 else { undefined_complex() }
  stable_quotient(self.re, self.im, other.re, other.im)
}

///|
pub fn Complex::sqrt(self : Complex) -> Complex {
  guard self.re != 0.0 || self.im != 0.0 else { Complex::new(0.0, 0.0) }
  let re_abs = self.re.abs()
  let im_abs = self.im.abs()
  let w = if re_abs >= im_abs {
    let t = im_abs / re_abs
    sqrt(re_abs) * sqrt(0.5 * (1.0 + hypot(1.0, t)))
  } else {
    let t = re_abs / im_abs
    sqrt(im_abs) * sqrt(0.5 * (t + hypot(1.0, t)))
  }
  if self.re >= 0.0 {
    Complex::new(w, self.im / (2.0 * w))
  } else {
    let im = if self.im >= 0.0 { w } else { -w }
    Complex::new(self.im / (2.0 * im), im)
  }
}

///|
pub fn Complex::sqrt_real(self : Double) -> Complex {
  if self >= 0.0 {
    Complex::new(sqrt(self), 0.0)
  } else {
    Complex::new(0.0, sqrt(-self))
  }
}

///|
pub fn Complex::exp(self : Complex) -> Complex {
  let rho = exp(self.re)
  let theta = self.im
  Complex::new(rho * cos(theta), rho * sin(theta))
}

///|
pub fn Complex::pow(self : Complex, other : Complex) -> Complex {
  if self.re == 0.0 && self.im == 0.0 {
    if other.re == 0.0 && other.im == 0.0 {
      Complex::new(1.0, 0.0)
    } else if other.im == 0.0 && other.re > 0.0 {
      Complex::new(0.0, 0.0)
    } else {
      undefined_complex()
    }
  } else if other.re == 1.0 && other.im == 0.0 {
    self
  } else if other.re == -1.0 && other.im == 0.0 {
    self.inv()
  } else if other.im == 0.0 && other.re == other.re.trunc() &&
    other.re.abs() <= 2147483647.0 {
    complex_pow_integer(self, other.re.to_int())
  } else {
    let log_re = self.abs_log()
    let theta = self.arg()
    let rho = exp(log_re * other.re - other.im * theta)
    let beta = theta * other.re + other.im * log_re
    Complex::new(rho * cos(beta), rho * sin(beta))
  }
}

///|
pub fn Complex::pow_real(self : Complex, other : Double) -> Complex {
  if self.re == 0.0 && self.im == 0.0 {
    if other == 0.0 {
      Complex::new(1.0, 0.0)
    } else if other > 0.0 {
      Complex::new(0.0, 0.0)
    } else {
      undefined_complex()
    }
  } else if other == other.trunc() && other.abs() <= 2147483647.0 {
    complex_pow_integer(self, other.to_int())
  } else {
    let log_re = self.abs_log()
    let theta = self.arg()
    let rho = exp(log_re * other)
    let beta = theta * other
    Complex::new(rho * cos(beta), rho * sin(beta))
  }
}

///|
pub fn Complex::log(self : Complex) -> Complex {
  Complex::new(self.abs_log(), self.arg())
}

///|
pub fn Complex::log_10(self : Complex) -> Complex {
  let z_log = self.log()
  Complex::new(z_log.re * inv_log_e_10, z_log.im * inv_log_e_10)
}

///|
pub fn Complex::log_b(self : Complex, b : Complex) -> Complex {
  self.log() / b.log()
}

///|
pub fn Complex::op_bin_re(
  self : Complex,
  other : Double,
  f : (Complex, Complex) -> Complex,
) -> Complex {
  f(self, Complex::new(other, 0.0))
}

///|
pub fn Complex::op_bin_im(
  self : Complex,
  other : Double,
  f : (Complex, Complex) -> Complex,
) -> Complex {
  f(self, Complex::new(0.0, other))
}
