///|
let inv_log_e_10 : Double = 1.0 / log(10)

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
  let t = if re_abs >= im_abs { im_abs / re_abs } else { re_abs / im_abs }
  log(maximum(re_abs, im_abs)) + 0.5 * log(1.0 + t * t)
}

///|
pub impl Div for Complex with fn div(self, other) -> Complex {
  let scale = 1.0 / other.abs()
  let scaled_re = scale * other.re
  let scaled_im = scale * other.im
  let re = (self.re * scaled_re + self.im * scaled_im) * scale
  let im = (self.im * scaled_re - self.re * scaled_im) * scale
  Complex::new(re, im)
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
    } else {
      Complex::new(0.0, 0.0)
    }
  } else if other.re == 1.0 && other.im == 0.0 {
    self
  } else if other.re == -1.0 && other.im == 0.0 {
    self.conjugate()
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
    } else {
      Complex::new(0.0, 0.0)
    }
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
