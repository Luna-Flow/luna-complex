///|
let asin_a_crossover = 1.5

///|
let asin_b_crossover = 0.6417

///|
fn scaled_tan_for_large_im(re : Double, im : Double) -> Complex {
  let sign = if im >= 0.0 { 1.0 } else { -1.0 }
  let decay = exp(-2.0 * im.abs())
  let decay_sq = decay * decay
  let sin_2re = sin(2.0 * re)
  let cos_2re = cos(2.0 * re)
  let denom = 1.0 + decay_sq + 2.0 * decay * cos_2re
  Complex::new(2.0 * decay * sin_2re / denom, sign * (1.0 - decay_sq) / denom)
}

///|
fn atan_real_component(re : Double, im : Double) -> Double {
  let re_abs = re.abs()
  let im_abs = im.abs()
  let max_val = maximum(re_abs, im_abs)
  if max_val == 0.0 {
    return 0.0
  }
  if max_val <= 1.0 {
    return 0.5 * atan2(2.0 * re, 1.0 - re * re - im * im)
  }
  let re_scaled = re / max_val
  let im_scaled = im / max_val
  let inv_scale_sq = 1.0 / (max_val * max_val)
  0.5 * atan2(
    2.0 * re_scaled / max_val,
    inv_scale_sq - re_scaled * re_scaled - im_scaled * im_scaled,
  )
}

///|
pub fn Complex::sin(self : Complex) -> Complex {
  if self.im == 0.0 {
    Complex::new(sin(self.re), 0.0)
  } else {
    Complex::new(sin(self.re) * cosh(self.im), cos(self.re) * sinh(self.im))
  }
}

///|
pub fn Complex::cos(self : Complex) -> Complex {
  if self.im == 0.0 {
    Complex::new(cos(self.re), 0.0)
  } else {
    Complex::new(cos(self.re) * cosh(self.im), sin(self.re) * sinh(-self.im))
  }
}

///|
pub fn Complex::tan(self : Complex) -> Complex {
  let re = self.re
  let im = self.im
  let denom = pow(cos(re), 2.0) + pow(sinh(im), 2.0)
  if im > -1.0 && im < 1.0 {
    Complex::new(0.5 * sin(2.0 * re) / denom, 0.5 * sinh(2.0 * im) / denom)
  } else {
    scaled_tan_for_large_im(re, im)
  }
}

///|
pub fn Complex::sec(self : Complex) -> Complex {
  self.cos().inv()
}

///|
pub fn Complex::csc(self : Complex) -> Complex {
  self.sin().inv()
}

///|
pub fn Complex::cot(self : Complex) -> Complex {
  self.tan().inv()
}

///|
pub fn Complex::asin(self : Complex) -> Complex {
  let re = self.re
  let im = self.im
  if im == 0.0 {
    Complex::asin_real(re)
  } else {
    let x = re.abs()
    let y = im.abs()
    let r = hypot(x + 1.0, y)
    let s = hypot(x - 1.0, y)
    let a = 0.5 * (r + s)
    let b = x / a
    let y2 = y * y
    let real = if b <= asin_b_crossover {
      asin(b)
    } else if x <= 1.0 {
      let d = 0.5 * (a + x) * (y2 / (r + x + 1.0) + (s + (1.0 - x)))
      atan(x / sqrt(d))
    } else {
      let a_plus_x = a + x
      let d = 0.5 * (a_plus_x / (r + x + 1.0) + a_plus_x / (s + (x - 1.0)))
      atan(x / (y * sqrt(d)))
    }
    let im_res = if a <= asin_a_crossover {
      let am1 = if x < 1.0 {
        0.5 * (y2 / (r + x + 1.0) + y2 / (s + (1.0 - x)))
      } else {
        0.5 * (y2 / (r + x + 1.0) + (s + (x - 1.0)))
      }
      log1p(am1 + sqrt(a * a - 1.0))
    } else {
      log(a + sqrt(a * a - 1.0))
    }
    Complex::new(
      if re >= 0.0 {
        real
      } else {
        -real
      },
      if im >= 0.0 {
        im_res
      } else {
        -im_res
      },
    )
  }
}

///|
pub fn Complex::asin_real(x : Double) -> Complex {
  if x >= -1.0 && x <= 1.0 {
    Complex::new(asin(x), 0.0)
  } else if x < 0.0 {
    Complex::new(-@lm.DOUBLE_PI / 2.0, acosh(-x))
  } else {
    Complex::new(@lm.DOUBLE_PI / 2.0, acosh(x))
  }
}

///|
pub fn Complex::acos(self : Complex) -> Complex {
  let re = self.re
  let im = self.im
  if im == 0.0 {
    Complex::acos_real(re)
  } else {
    let x = re.abs()
    let y = im.abs()
    let r = hypot(x + 1.0, y)
    let s = hypot(x - 1.0, y)
    let a = 0.5 * (r + s)
    let b = x / a
    let y2 = y * y
    let real = if b <= asin_b_crossover {
      acos(b)
    } else if x <= 1.0 {
      let d = 0.5 * (a + x) * (y2 / (r + x + 1.0) + (s + (1.0 - x)))
      atan(sqrt(d) / x)
    } else {
      let a_plus_x = a + x
      let d = 0.5 * (a_plus_x / (r + x + 1.0) + a_plus_x / (s + (x - 1.0)))
      atan(y * sqrt(d) / x)
    }
    let im_res = if a <= asin_a_crossover {
      let am1 = if x < 1.0 {
        0.5 * (y2 / (r + x + 1.0) + y2 / (s + (1.0 - x)))
      } else {
        0.5 * (y2 / (r + x + 1.0) + (s + (x - 1.0)))
      }
      log1p(am1 + sqrt(am1 * (a + 1.0)))
    } else {
      log(a + sqrt(a * a - 1.0))
    }
    Complex::new(
      if re >= 0.0 {
        real
      } else {
        @lm.DOUBLE_PI - real
      },
      if im >= 0.0 {
        -im_res
      } else {
        im_res
      },
    )
  }
}

///|
pub fn Complex::acos_real(x : Double) -> Complex {
  if x >= -1.0 && x <= 1.0 {
    Complex::new(acos(x), 0.0)
  } else if x < 0.0 {
    Complex::new(@lm.DOUBLE_PI, -acosh(-x))
  } else {
    Complex::new(0.0, -acosh(x))
  }
}

///|
pub fn Complex::atan(self : Complex) -> Complex {
  let re = self.re
  let im = self.im
  if im == 0.0 {
    Complex::new(atan(re), 0.0)
  } else {
    let radius = hypot(re, im)
    let u = 2.0 * im / (1.0 + radius * radius)
    // The log1p branch keeps small-|u| inputs numerically stable.
    let im_abs = if u.abs() < 0.1 {
      0.25 * (log1p(u) - log1p(-u))
    } else {
      let a = hypot(re, im + 1.0)
      let b = hypot(re, im - 1.0)
      0.5 * log(a / b)
    }
    if re == 0.0 {
      if im > 1.0 {
        Complex::new(@lm.DOUBLE_PI / 2.0, im_abs)
      } else if im < -1.0 {
        Complex::new(-@lm.DOUBLE_PI / 2.0, im_abs)
      } else {
        Complex::new(0.0, im_abs)
      }
    } else {
      Complex::new(atan_real_component(re, im), im_abs)
    }
  }
}

///|
pub fn Complex::asec(self : Complex) -> Complex {
  self.inv().acos()
}

///|
pub fn Complex::asec_real(x : Double) -> Complex {
  if x <= -1.0 || x >= 1.0 {
    Complex::new(acos(1.0 / x), 0.0)
  } else if x >= 0.0 {
    Complex::new(0.0, -acosh(1.0 / x))
  } else {
    Complex::new(@lm.DOUBLE_PI, -acosh(-1.0 / x))
  }
}

///|
pub fn Complex::acsc(self : Complex) -> Complex {
  self.inv().asin()
}

///|
pub fn Complex::acsc_real(x : Double) -> Complex {
  if x <= -1.0 || x >= 1.0 {
    Complex::new(asin(1.0 / x), 0.0)
  } else if x >= 0.0 {
    Complex::new(@lm.DOUBLE_PI / 2.0, acosh(1.0 / x))
  } else {
    Complex::new(-@lm.DOUBLE_PI / 2.0, acosh(-1.0 / x))
  }
}

///|
pub fn Complex::acot(self : Complex) -> Complex {
  if self.re == 0.0 && self.im == 0.0 {
    Complex::new(@lm.DOUBLE_PI / 2.0, 0.0)
  } else {
    self.inv().atan()
  }
}
