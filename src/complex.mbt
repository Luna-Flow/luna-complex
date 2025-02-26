///|
/// Represents a complex number with real and imaginary parts.
///
/// A complex number is a combination of a real number and an imaginary number in
/// the form `a + bi`, where `a` is the real part, `b` is the imaginary part, and
/// `i` is the imaginary unit defined by `i² = -1`. Both parts are stored as
/// double-precision floating-point numbers.
///
/// Parameters:
///
/// * `re` : The real part of the complex number.
/// * `im` : The imaginary part of the complex number.
///
/// Example:
///
/// ```moonbit
/// test "Complex/construction" {
///   let z = Complex::new(3.0, 4.0)
///   inspect!(z.re, content="3")
///   inspect!(z.im, content="4")
/// }
/// ```

///|
pub(all) struct Complex {
  mut re : Double
  mut im : Double
}

//init

///|
pub fn Complex::new(re : Double, im : Double) -> Complex {
  Complex::{ re, im }
}

//oper

///|
pub fn Complex::set(self : Complex, re : Double, im : Double) -> Unit {
  self.re = re
  self.im = im
}

///|
pub fn Complex::set_re(self : Complex, re : Double) -> Unit {
  self.re = re
}

///|
pub fn Complex::set_im(self : Complex, im : Double) -> Unit {
  self.im = im
}

///|
pub fn Complex::native_pack(
  re : Double,
  im : Double,
  arr : Array[Double],
  offset : Int
) -> Unit {
  guard offset >= 0 && offset < arr.length() / 2
  arr[2 * offset] = re
  arr[2 * offset + 1] = im
}

///|
pub fn Complex::pack(self : Complex, arr : Array[Double], offset : Int) -> Unit {
  Complex::native_pack(self.re, self.im, arr, offset)
}

//math

///|
pub fn Complex::polar(r : Double, theta : Double) -> Complex {
  Complex::new(r * @lm.cos(theta), r * @lm.sin(theta))
}

///|
pub fn Complex::arg(self : Complex) -> Double {
  guard self.re != 0.0 || self.im != 0.0 else { 0.0 }
  @lm.atan2(self.im, self.re)
}

///|
pub fn Complex::abs(self : Complex) -> Double {
  @lm.hypot(self.re, self.im)
}

///|
pub fn Complex::abs_sqr(self : Complex) -> Double {
  //self.re * self.re + self.im * self.im

  // to avoid re*re + im*im too large,so use the following code
  let re_abs = self.re.abs()
  let im_abs = self.im.abs()
  let max_val = @math.maximum(re_abs, im_abs)
  // avoid 0.0
  if max_val == 0.0 {
    return 0.0
  }
  let re_scaled = self.re / max_val
  let im_scaled = self.im / max_val
  return max_val * max_val * (re_scaled * re_scaled + im_scaled * im_scaled)
}

///|
pub fn Complex::abs_log(self : Complex) -> Double {
  let re_abs = self.re.abs()
  let im_abs = self.im.abs()
  let t = if re_abs >= im_abs { im_abs / re_abs } else { re_abs / im_abs }
  @lm.log(@math.maximum(re_abs, im_abs)) + 0.5 * @lm.log(1.0 + t * t)
}

///|
pub fn Complex::op_div(self : Complex, other : Complex) -> Complex {
  let s = 1.0 / other.abs()
  let sbr = s * other.re
  let sbi = s * other.im
  let re = (self.re * sbr + self.im * sbi) * s
  let im = (self.im * sbr - self.re * sbi) * s
  Complex::new(re, im)
}

///|
pub fn Complex::sqrt(self : Complex) -> Complex {
  guard self.re != 0 || self.im != 0 else { Complex::new(0.0, 0.0) }
  let re_abs = self.re.abs()
  let im_abs = self.im.abs()
  let w = if re_abs >= im_abs {
    let t = im_abs / re_abs
    @lm.sqrt(re_abs) * @lm.sqrt(0.5 * (1.0 + @lm.hypot(1.0, t)))
  } else {
    let t = re_abs / im_abs
    @lm.sqrt(im_abs) * @lm.sqrt(0.5 * (t + @lm.hypot(1.0, t)))
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
  if self >= 0 {
    Complex::new(@lm.sqrt(self), 0)
  } else {
    Complex::new(0, @lm.sqrt(-self))
  }
}

///|
pub fn Complex::exp(self : Complex) -> Complex {
  let rho = @lm.exp(self.re)
  let thete = self.im
  Complex::new(rho * @lm.cos(thete), rho * @lm.sin(thete))
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
    let logr = self.abs_log()
    let theta = self.arg()
    let oreal = other.re
    let oimag = other.im
    let rho = @lm.exp(logr * oreal - oimag * theta)
    let beta = theta * oreal + oimag * logr
    Complex::new(rho * @lm.cos(beta), rho * @lm.sin(beta))
  }
}

///|
pub fn Complex::pow_real(self : Complex, other : Double) -> Complex {
  if self.re == 0 && self.im == 0 {
    if other == 0 {
      Complex::new(1.0, 0.0)
    } else {
      Complex::new(0.0, 0.0)
    }
  } else {
    let logr = self.abs_log()
    let theta = self.arg()
    let rho = @lm.exp(logr * other)
    let beta = theta * other
    Complex::new(rho * @lm.cos(beta), rho * @lm.sin(beta))
  }
}

///|
pub fn Complex::log(self : Complex) -> Complex {
  let logr = self.abs_log()
  let theta = self.arg()
  Complex::new(logr, theta)
}

///|
let inv_log_e_10 : Double = 1.0 / @lm.log(10)

///|
pub fn Complex::log_10(self : Complex) -> Complex {
  Complex::new(self.log().re / inv_log_e_10, self.log().im * inv_log_e_10)
}

///|
pub fn Complex::log_b(self : Complex, b : Complex) -> Complex {
  self.log() / b.log()
}

// Complex trigonometric functions

///|
pub fn Complex::sin(self : Complex) -> Complex {
  if self.im == 0.0 {
    // avoid returing negative zero (-0.0) for the imaginary part
    Complex::new(@lm.sin(self.re), 0.0)
  } else {
    Complex::new(
      @lm.sin(self.re) * @lm.cosh(self.im),
      @lm.cos(self.re) * @lm.sinh(self.im),
    )
  }
}

///|
pub fn Complex::cos(self : Complex) -> Complex {
  if self.im == 0.0 {
    // avoid returing negative zero (-0.0) for the imaginary part
    Complex::new(@lm.cos(self.re), 0.0)
  } else {
    Complex::new(
      @lm.cos(self.re) * @lm.cosh(self.im),
      @lm.sin(self.re) * @lm.sinh(-self.im),
    )
  }
}

///|
pub fn Complex::tan(self : Complex) -> Complex {
  let r = self.re
  let i = self.im
  if i < 1.0 && i > -1.0 {
    let d = @lm.pow(@lm.cos(r), 2.0) + @lm.pow(@lm.sinh(i), 2.0)
    Complex::new(0.5 * @lm.sin(2.0 * r) / d, 0.5 * @lm.sinh(2.0 * i) / d)
  } else {
    let d = @lm.pow(@lm.cos(r), 2.0) + @lm.pow(@lm.sinh(i), 2.0)
    let f = 1.0 + @lm.pow(@lm.cos(r) / @lm.sinh(i), 2.0)
    Complex::new(0.5 * @lm.sin(2.0 * r) / d, 1.0 / (@lm.tanh(i) * f))
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

// Inverse Complex Trigonometric Functions

///|
const A_CROSSOVER = 1.5

///|
const B_CROSSOVER = 0.6417

///|
pub fn Complex::asin(self : Complex) -> Complex {
  let re = self.re
  let im = self.im
  if im == 0 {
    Complex::asin_real(re)
  } else {
    let x = Double::abs(re)
    let y = Double::abs(im)
    let r = @lm.hypot(x + 1, y)
    let s = @lm.hypot(x - 1, y)
    let a = 0.5 * (r + s)
    let b = x / a
    let y2 = y * y
    let real = if b <= B_CROSSOVER {
      @lm.asin(b)
    } else if x <= 1 {
      let d = 0.5 * (a + x) * (y2 / (r + x + 1.0)) + (s + (1.0 - x))
      @lm.atan(x / @lm.sqrt(d))
    } else {
      let apx = a + x
      let d = 0.5 * (apx / (r + x + 1.0) + apx / (s + (x - 1.0)))
      @lm.atan(x / (y * @lm.sqrt(d)))
    }
    let imag = if a <= A_CROSSOVER {
      let am1 = if x < 1 {
        0.5 * (y2 / (r + (x + 1.0)) + y2 / (s + (1.0 - x)))
      } else {
        0.5 * (y2 / (r + (x + 1.0)) + (s + (x - 1.0)))
      }
      @lm.log1p(am1 + @lm.sqrt(a * a - 1.0))
    } else {
      @lm.log(a + @lm.sqrt(a * a - 1.0))
    }
    Complex::new(
      if re >= 0 {
        real
      } else {
        -real
      },
      if im >= 0 {
        imag
      } else {
        -imag
      },
    )
  }
}

///|
pub fn Complex::asin_real(x : Double) -> Complex {
  if x >= -1.0 && x <= 1.0 {
    Complex::new(@lm.asin(x), 0.0)
  } else if x < 0.0 {
    Complex::new(-@lm.PI / 2.0, @lm.acosh(-x))
  } else {
    Complex::new(@lm.PI / 2.0, -@lm.acosh(x))
  }
}

///|
pub fn Complex::acos(self : Complex) -> Complex {
  let re = self.re
  let im = self.im
  if im == 0 {
    Complex::acos_real(re)
  } else {
    let x = Double::abs(re)
    let y = Double::abs(im)
    let r = @lm.hypot(x + 1, y)
    let s = @lm.hypot(x - 1, y)
    let a = 0.5 * (r + s)
    let b = x / a
    let y2 = y * y
    let real = if b <= B_CROSSOVER {
      @lm.acos(b)
    } else if x <= 1 {
      let d = 0.5 * (a + x) * (y2 / (r + x + 1.0) + (s + (1.0 - x)))
      @lm.atan(@lm.sqrt(d) / x)
    } else {
      let apx = a + x
      let d = 0.5 * (apx / (r + x + 1.0) + apx / (s + (x - 1.0)))
      @lm.atan(y * @lm.sqrt(d) / x)
    }
    let imag = if a <= A_CROSSOVER {
      let am1 = if x < 1 {
        0.5 * (y2 / (r + (x + 1)) + y2 / (s + (1.0 - x)))
      } else {
        0.5 * (y2 / (r + (x + 1)) + (s + (x - 1)))
      }
      @lm.log1p(am1 + @lm.sqrt(am1 * (a + 1)))
    } else {
      @lm.log(a + @lm.sqrt(a * a - 1.0))
    }
    Complex::new(
      if re >= 0 {
        real
      } else {
        @lm.PI - real
      },
      if im >= 0 {
        -imag
      } else {
        imag
      },
    )
  }
}

///|
pub fn Complex::acos_real(x : Double) -> Complex {
  if x >= -1.0 && x <= 1.0 {
    Complex::new(@lm.acos(x), 0.0)
  } else if x < 0.0 {
    Complex::new(@lm.PI, -@lm.acosh(-x))
  } else {
    Complex::new(0, @lm.acosh(x))
  }
}

///|
pub fn atan(self : Complex) -> Complex {
  let re = self.re
  let im = self.im
  if im == 0 {
    Complex::new(@lm.atan(re), 0.0)
  } else {
    // FIXME: This is a naive implementation which does not fully
    // take into account cancellation errors, overflow, underflow
    // etc.  It would benefit from the Hull et al treatment.
    let r = @lm.hypot(re, im)
    let u = 2.0 * im / (1.0 + r * r)
    // FIXME: the following cross-over should be optimized but 0.1
    // seems to work ok 
    let imag = if Double::abs(u) < 0.1 {
      0.25 * (@lm.log1p(u) - @lm.log1p(-u))
    } else {
      let a = @lm.hypot(re, im + 1.0)
      let b = @lm.hypot(re, im - 1.0)
      0.5 * @lm.log(a / b)
    }
    if re == 0 {
      if im > 1.0 {
        Complex::new(@lm.PI / 2.0, imag)
      } else if im < -1.0 {
        Complex::new(-@lm.PI / 2.0, imag)
      } else {
        Complex::new(0.0, imag)
      }
    } else {
      Complex::new(0.5 * @lm.atan2(2.0 * re, (1.0 + r) * (1.0 - r)), imag)
    }
  }
}

///|
pub fn Complex::asec(self : Complex) -> Complex {
  self.inv().acos()
}

///|
pub fn Complex::aecsec_real(x : Double) -> Complex {
  if x < 1.0 || x >= 1.0 {
    Complex::new(@lm.acos(1.0 / x), 0.0)
  } else if x >= 0.0 {
    Complex::new(0.0, @lm.acosh(1.0 / x))
  } else {
    Complex::new(@lm.PI, -@lm.acosh(-1.0 / x))
  }
}

///|
pub fn Complex::acsc(self : Complex) -> Complex {
  self.inv().asin()
}

///|
pub fn Complex::acsc_real(x : Double) -> Complex {
  if x <= -1.0 || x >= 1.0 {
    Complex::new(@lm.asin(1.0 / x), 0.0)
  } else if x >= 0.0 {
    Complex::new(@lm.PI / 2.0, -@lm.acosh(1.0 / x))
  } else {
    Complex::new(-@lm.PI / 2.0, @lm.acosh(-1.0 / x))
  }
}

///|
pub fn Complex::acot(self : Complex) -> Complex {
  if self.re == 0.0 && self.im == 0.0 {
    Complex::new(@lm.PI / 2.0, 0.0)
  } else {
    self.inv().atan()
  }
}

// Complex Hyperbolic Functions

///|
pub fn Complex::sinh(self : Complex) -> Complex {
  let re = self.re
  let im = self.im
  Complex::new(@lm.sinh(re) * @lm.cos(im), @lm.cosh(re) * @lm.sin(im))
}

///|
pub fn Complex::cosh(self : Complex) -> Complex {
  let re = self.re
  let im = self.im
  Complex::new(@lm.cosh(re) * @lm.cos(im), @lm.sinh(re) * @lm.sin(im))
}

///|
pub fn Complex::tanh(self : Complex) -> Complex {
  let re = self.re
  let im = self.im
  if re > -1.0 && re < 1.0 {
    let d = @lm.pow(@lm.cos(im), 2.0) + @lm.pow(@lm.sinh(re), 2.0)
    Complex::new(@lm.sinh(re) * @lm.cosh(re) / d, 0.5 * @lm.sin(2.0 * im) / d)
  } else {
    let d = @lm.pow(@lm.cos(im), 2.0) + @lm.pow(@lm.sinh(re), 2.0)
    let f = 1.0 + @lm.pow(@lm.cos(im) / @lm.sinh(re), 2.0)
    Complex::new(1.0 / (@lm.tanh(re) * f), 0.5 * @lm.sin(2.0 * im) / d)
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

// Inverse Complex Hyperbolic Functions

///|
pub fn Complex::asinh(self : Complex) -> Complex {
  let z = Complex::new(-self.im, self.re).asin()
  Complex::new(z.im, -z.re)
}

///|
pub fn Complex::acosh(self : Complex) -> Complex {
  let z = self.acos()
  if z.im < 0 {
    Complex::new(-z.im, z.re)
  } else {
    Complex::new(z.im, -z.re)
  }
}

///|
pub fn Complex::acosh_real(x : Double) -> Complex {
  if x >= 1 {
    Complex::new(@lm.acosh(x), 0.0)
  } else if x >= -1.0 {
    Complex::new(0, @lm.acos(x))
  } else {
    Complex::new(@lm.acosh(-x), @lm.PI)
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
    Complex::new(@lm.atanh(x), 0.0)
  } else {
    Complex::new(
      @lm.atanh(1.0 / x),
      if x < 0 {
        -@lm.PI / 2
      } else {
        @lm.PI / 2
      },
    )
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
