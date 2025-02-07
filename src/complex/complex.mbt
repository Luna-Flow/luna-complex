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
  Complex::new(r * @luna_math.cos(theta), r * @luna_math.sin(theta))
}

///|
pub fn Complex::arg(self : Complex) -> Double {
  guard self.re != 0.0 || self.im != 0.0 else { 0.0 }
  @luna_math.atan2(self.im, self.re)
}

///|
pub fn Complex::abs(self : Complex) -> Double {
  @luna_math.hypot(self.re, self.im)
}

///|
pub fn Complex::abs_sqr(self : Complex) -> Double {
  //self.re * self.re + self.im * self.im

  // to avoid re*re + im*im too large,so use the following code
  let re_abs = self.re.abs()
  let im_abs = self.im.abs()
  let max_val = @luna_utils.max(re_abs, im_abs)
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
  let mut t = 0.0
  if re_abs >= im_abs {
    t = im_abs / re_abs
  } else {
    t = re_abs / im_abs
  }
  @luna_math.log(@luna_utils.max(re_abs, im_abs)) +
  0.5 * @luna_math.log(1.0 + t * t)
}

///|
pub fn Complex::op_add(self : Complex, other : Complex) -> Complex {
  Complex::new(self.re + other.re, self.im + other.im)
}

///|
pub fn Complex::add(self : Complex, other : Complex) -> Unit {
  self.re = self.re + other.re
  self.im = self.im + other.im
}

///|
pub fn Complex::add_real(self : Complex, other : Double) -> Complex {
  Complex::new(self.re + other, self.im)
}

///|
pub fn Complex::add_real_inplace(self : Complex, other : Double) -> Unit {
  self.re = self.re + other
}

///|
pub fn Complex::add_imag(self : Complex, other : Double) -> Complex {
  Complex::new(self.re, self.im + other)
}

///|
pub fn Complex::add_imag_inplace(self : Complex, other : Double) -> Unit {
  self.im = self.im + other
}

///|
pub fn Complex::op_sub(self : Complex, other : Complex) -> Complex {
  Complex::new(self.re - other.re, self.im - other.im)
}

///|
pub fn Complex::sub(self : Complex, other : Complex) -> Unit {
  self.re = self.re - other.re
  self.im = self.im - other.im
}

///|
pub fn Complex::sub_real(self : Complex, other : Double) -> Complex {
  Complex::new(self.re - other, self.im)
}

///|
pub fn Complex::sub_real_inplace(self : Complex, other : Double) -> Unit {
  self.re = self.re - other
}

///|
pub fn Complex::sub_imag(self : Complex, other : Double) -> Complex {
  Complex::new(self.re, self.im - other)
}

///|
pub fn Complex::sub_imag_inplace(self : Complex, other : Double) -> Unit {
  self.im = self.im - other
}

///|
pub fn Complex::op_mul(self : Complex, other : Complex) -> Complex {
  Complex::new(
    self.re * other.re - self.im * other.im,
    self.re * other.im + self.im * other.re,
  )
}

///|
pub fn Complex::mul(self : Complex, other : Complex) -> Unit {
  let re = self.re * other.re - self.im * other.im
  let im = self.re * other.im + self.im * other.re
  self.re = re
  self.im = im
}

///|
pub fn Complex::mul_real(self : Complex, other : Double) -> Complex {
  Complex::new(self.re * other, self.im * other)
}

///|
pub fn Complex::mul_real_inplace(self : Complex, other : Double) -> Unit {
  self.re = self.re * other
  self.im = self.im * other
}

///|
pub fn Complex::mul_imag(self : Complex, other : Double) -> Complex {
  Complex::new(-self.im * other, self.re * other)
}

///|
pub fn Complex::mul_imag_inplace(self : Complex, other : Double) -> Unit {
  let re = -self.im * other
  let im = self.re * other
  self.re = re
  self.im = im
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
pub fn Complex::div(self : Complex, other : Complex) -> Unit {
  let s = 1.0 / other.abs()
  let sbr = s * other.re
  let sbi = s * other.im
  let re = (self.re * sbr + self.im * sbi) * s
  let im = (self.im * sbr - self.re * sbi) * s
  self.re = re
  self.im = im
}

///|
pub fn Complex::div_real(self : Complex, other : Double) -> Complex {
  Complex::new(self.re / other, self.im / other)
}

///|
pub fn Complex::div_real_inplace(self : Complex, other : Double) -> Unit {
  self.re = self.re / other
  self.im = self.im / other
}

///| 
pub fn Complex::div_imag(self : Complex, other : Double) -> Complex {
  Complex::new(self.im / other, -self.re / other)
}

///|
pub fn Complex::div_imag_inplace(self : Complex, other : Double) -> Unit {
  let re = self.im / other
  let im = -self.re / other
  self.re = re
  self.im = im
}

///|
pub fn Complex::conjugate(self : Complex) -> Complex {
  Complex::new(self.re, -self.im)
}

///|
pub fn Complex::conjugate_inplace(self : Complex) -> Unit {
  self.im = -self.im
}

///|
pub fn Complex::op_neg(self : Complex) -> Complex {
  Complex::new(-self.re, -self.im)
}

///|
pub fn Complex::neg(self : Complex) -> Unit {
  self.re = -self.re
  self.im = -self.im
}

///|
pub fn Complex::inverse(self : Complex) -> Complex {
  let s = 1.0 / self.abs()
  Complex::new(self.re * s * s, -self.im * s * s)
}

///|
pub fn Complex::sqrt(self : Complex) -> Complex {
  guard self.re != 0 || self.im != 0 else { Complex::new(0.0, 0.0) }
  let re_abs = self.re.abs()
  let im_abs = self.im.abs()
  let mut w = 0.0
  if re_abs >= im_abs {
    let t = im_abs / re_abs
    w = @luna_math.sqrt(re_abs) *
      @luna_math.sqrt(0.5 * (1.0 + @luna_math.hypot(1.0, t)))
  } else {
    let t = re_abs / im_abs
    w = @luna_math.sqrt(im_abs) *
      @luna_math.sqrt(0.5 * (t + @luna_math.hypot(1.0, t)))
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
    Complex::new(@luna_math.sqrt(self), 0)
  } else {
    Complex::new(0, @luna_math.sqrt(-self))
  }
}

///|
pub fn Complex::exp(self : Complex) -> Complex {
  let rho = @luna_math.exp(self.re) //计算e^re
  let thete = self.im
  Complex::new(rho * @luna_math.cos(thete), rho * @luna_math.sin(thete))
}

///|
pub fn Complex::pow(self : Complex, other : Complex) -> Complex {
  if self.re == 0.0 && self.im == 0.0 {
    if other.re == 0.0 && other.im == 0.0 {
      return Complex::new(1.0, 0.0)
    } else {
      return Complex::new(0.0, 0.0)
    }
  } else if other.re == 1.0 && other.im == 0.0 {
    return self
  } else if other.re == -1.0 && other.im == 0.0 {
    return self.conjugate()
  } else {
    let logr = self.abs_log()
    let theta = self.arg()
    let oreal = other.re
    let oimag = other.im
    let rho = @luna_math.log(logr * oreal - oimag * theta)
    let beta = theta * oreal + oimag * logr
    return Complex::new(rho * @luna_math.cos(beta), rho * @luna_math.sin(beta))
  }
}

///|
pub fn Complex::pow_real(self : Complex, other : Double) -> Complex {
  if self.re == 0 && self.im == 0 {
    if other == 0 {
      return Complex::new(1.0, 0.0)
    } else {
      return Complex::new(0.0, 0.0)
    }
  } else {
    let logr = self.abs_log()
    let theta = self.arg()
    let rho = @luna_math.exp(logr * other)
    let beta = theta * other
    Complex::new(rho * @luna_math.cos(beta), rho * @luna_math.sin(beta))
  }
}

///|
pub fn Complex::log(self : Complex) -> Complex {
  let logr = self.abs_log()
  let theta = self.arg()
  Complex::new(logr, theta)
}

///|
pub fn Complex::log10(self : Complex) -> Complex {
  self.log().mul_real(1.0 / @luna_math.log(10))
}

///|
pub fn Complex::log_b(self : Complex, other : Complex) -> Complex {
  self.log() / other.log()
}

// Complex trigonometric functions

///|
pub fn Complex::sin(self : Complex) -> Complex {
  if self.im == 0.0 {
    // avoid returing negative zero (-0.0) for the imaginary part
    return Complex::new(@luna_math.sin(self.re), 0.0)
  } else {
    return Complex::new(
      @luna_math.sin(self.re) * @luna_math.cosh(self.im),
      @luna_math.cos(self.re) * @luna_math.sinh(self.im),
    )
  }
}

///|
pub fn Complex::cos(self : Complex) -> Complex {
  if self.im == 0.0 {
    // avoid returing negative zero (-0.0) for the imaginary part
    Complex::new(@luna_math.cos(self.re), 0.0)
  } else {
    return Complex::new(
      @luna_math.cos(self.re) * @luna_math.cosh(self.im),
      @luna_math.sin(self.re) * @luna_math.sinh(-self.im),
    )
  }
}

///|
pub fn Complex::tan(self : Complex) -> Complex {
  let r = self.re
  let i = self.im
  if i < 1.0 && i > -1.0 {
    let d = @luna_math.pow(@luna_math.cos(r), 2.0) +
      @luna_math.pow(@luna_math.sinh(i), 2.0)
    Complex::new(
      0.5 * @luna_math.sin(2.0 * r) / d,
      0.5 * @luna_math.sinh(2.0 * i) / d,
    )
  } else {
    let d = @luna_math.pow(@luna_math.cos(r), 2.0) +
      @luna_math.pow(@luna_math.sinh(i), 2.0)
    let f = 1.0 + @luna_math.pow(@luna_math.cos(r) / @luna_math.sinh(i), 2.0)
    Complex::new(
      0.5 * @luna_math.sin(2.0 * r) / d,
      1.0 / (@luna_math.tanh(i) * f),
    )
  }
}

///|
pub fn Complex::sec(self : Complex) -> Complex {
  self.cos().inverse()
}

///|
pub fn Complex::csc(self : Complex) -> Complex {
  self.sin().inverse()
}

///|
pub fn Complex::cot(self : Complex) -> Complex {
  self.tan().inverse()
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
    let r = @luna_math.hypot(x + 1, y)
    let s = @luna_math.hypot(x - 1, y)
    let a = 0.5 * (r + s)
    let b = x / a
    let y2 = y * y
    let mut real = 0.0
    let mut imag = 0.0
    if b <= B_CROSSOVER {
      real = @luna_math.asin(b)
    } else if x <= 1 {
      let d = 0.5 * (a + x) * (y2 / (r + x + 1.0)) + (s + (1.0 - x))
      real = @luna_math.atan(x / @luna_math.sqrt(d))
    } else {
      let apx = a + x
      let d = 0.5 * (apx / (r + x + 1.0) + apx / (s + (x - 1.0)))
      real = @luna_math.atan(x / (y * @luna_math.sqrt(d)))
    }
    if a <= A_CROSSOVER {
      let mut am1 = 0.0
      if x < 1 {
        am1 = 0.5 * (y2 / (r + (x + 1.0)) + y2 / (s + (1.0 - x)))
      } else {
        am1 = 0.5 * (y2 / (r + (x + 1.0)) + (s + (x - 1.0)))
      }
      imag = @luna_math.log1p(am1 + @luna_math.sqrt(a * a - 1.0))
    } else {
      imag = @luna_math.log(a + @luna_math.sqrt(a * a - 1.0))
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
    Complex::new(@luna_math.asin(x), 0.0)
  } else if x < 0.0 {
    Complex::new(-@luna_math.PI / 2.0, @luna_math.acosh(-x))
  } else {
    Complex::new(@luna_math.PI / 2.0, -@luna_math.acosh(x))
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
    let r = @luna_math.hypot(x + 1, y)
    let s = @luna_math.hypot(x - 1, y)
    let a = 0.5 * (r + s)
    let b = x / a
    let y2 = y * y
    let mut real = 0.0
    let mut imag = 0.0
    if b <= B_CROSSOVER {
      real = @luna_math.acos(b)
    } else if x <= 1 {
      let d = 0.5 * (a + x) * (y2 / (r + x + 1.0) + (s + (1.0 - x)))
      real = @luna_math.atan(@luna_math.sqrt(d) / x)
    } else {
      let apx = a + x
      let d = 0.5 * (apx / (r + x + 1.0) + apx / (s + (x - 1.0)))
      real = @luna_math.atan(y * @luna_math.sqrt(d) / x)
    }
    if a <= A_CROSSOVER {
      let mut am1 = 0.0
      if x < 1 {
        am1 = 0.5 * (y2 / (r + (x + 1)) + y2 / (s + (1.0 - x)))
      } else {
        am1 = 0.5 * (y2 / (r + (x + 1)) + (s + (x - 1)))
      }
      imag = @luna_math.log1p(am1 + @luna_math.sqrt(am1 * (a + 1)))
    } else {
      imag = @luna_math.log(a + @luna_math.sqrt(a * a - 1.0))
    }
    Complex::new(
      if re >= 0 {
        real
      } else {
        @luna_math.PI - real
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
    Complex::new(@luna_math.acos(x), 0.0)
  } else if x < 0.0 {
    Complex::new(@luna_math.PI, -@luna_math.acosh(-x))
  } else {
    Complex::new(0, @luna_math.acosh(x))
  }
}

///|
pub fn atan(self : Complex) -> Complex {
  let re = self.re
  let im = self.im
  if im == 0 {
    Complex::new(@luna_math.atan(re), 0.0)
  } else {
    // FIXME: This is a naive implementation which does not fully
    // take into account cancellation errors, overflow, underflow
    // etc.  It would benefit from the Hull et al treatment.
    let r = @luna_math.hypot(re, im)
    let mut imag = 0.0
    let u = 2.0 * im / (1.0 + r * r)
    // FIXME: the following cross-over should be optimized but 0.1
    // seems to work ok 
    if Double::abs(u) < 0.1 {
      imag = 0.25 * (@luna_math.log1p(u) - @luna_math.log1p(-u))
    } else {
      let a = @luna_math.hypot(re, im + 1.0)
      let b = @luna_math.hypot(re, im - 1.0)
      imag = 0.5 * @luna_math.log(a / b)
    }
    if re == 0 {
      if im > 1.0 {
        Complex::new(@luna_math.PI / 2.0, imag)
      } else if im < -1.0 {
        Complex::new(-@luna_math.PI / 2.0, imag)
      } else {
        Complex::new(0.0, imag)
      }
    } else {
      Complex::new(
        0.5 * @luna_math.atan2(2.0 * re, (1.0 + r) * (1.0 - r)),
        imag,
      )
    }
  }
}

///|
pub fn Complex::asec(self : Complex) -> Complex {
  self.inverse().acos()
}

///|
pub fn Complex::aecsec_real(x : Double) -> Complex {
  if x < 1.0 || x >= 1.0 {
    Complex::new(@luna_math.acos(1.0 / x), 0.0)
  } else if x >= 0.0 {
    Complex::new(0.0, @luna_math.acosh(1.0 / x))
  } else {
    Complex::new(@luna_math.PI, -@luna_math.acosh(-1.0 / x))
  }
}

///|
pub fn Complex::acsc(self : Complex) -> Complex {
  self.inverse().asin()
}

///|
pub fn Complex::acsc_real(x : Double) -> Complex {
  if x <= -1.0 || x >= 1.0 {
    Complex::new(@luna_math.asin(1.0 / x), 0.0)
  } else if x >= 0.0 {
    Complex::new(@luna_math.PI / 2.0, -@luna_math.acosh(1.0 / x))
  } else {
    Complex::new(-@luna_math.PI / 2.0, @luna_math.acosh(-1.0 / x))
  }
}

///|
pub fn Complex::acot(self : Complex) -> Complex {
  if self.re == 0.0 && self.im == 0.0 {
    Complex::new(@luna_math.PI / 2.0, 0.0)
  } else {
    self.inverse().atan()
  }
}

// Complex Hyperbolic Functions

///|
pub fn Complex::sinh(self : Complex) -> Complex {
  let re = self.re
  let im = self.im
  Complex::new(
    @luna_math.sinh(re) * @luna_math.cos(im),
    @luna_math.cosh(re) * @luna_math.sin(im),
  )
}

///|
pub fn Complex::cosh(self : Complex) -> Complex {
  let re = self.re
  let im = self.im
  Complex::new(
    @luna_math.cosh(re) * @luna_math.cos(im),
    @luna_math.sinh(re) * @luna_math.sin(im),
  )
}

///|
pub fn Complex::tanh(self : Complex) -> Complex {
  let re = self.re
  let im = self.im
  if re > -1.0 && re < 1.0 {
    let d = @luna_math.pow(@luna_math.cos(im), 2.0) +
      @luna_math.pow(@luna_math.sinh(re), 2.0)
    Complex::new(
      @luna_math.sinh(re) * @luna_math.cosh(re) / d,
      0.5 * @luna_math.sin(2.0 * im) / d,
    )
  } else {
    let d = @luna_math.pow(@luna_math.cos(im), 2.0) +
      @luna_math.pow(@luna_math.sinh(re), 2.0)
    let f = 1.0 + @luna_math.pow(@luna_math.cos(im) / @luna_math.sinh(re), 2.0)
    Complex::new(
      1.0 / (@luna_math.tanh(re) * f),
      0.5 * @luna_math.sin(2.0 * im) / d,
    )
  }
}

///|
pub fn Complex::sech(self : Complex) -> Complex {
  self.cosh().inverse()
}

///|
pub fn Complex::csch(self : Complex) -> Complex {
  self.sinh().inverse()
}

///|
pub fn Complex::coth(self : Complex) -> Complex {
  self.tanh().inverse()
}

// Inverse Complex Hyperbolic Functions

///|
pub fn Complex::asinh(self : Complex) -> Complex {
  let mut z = Complex::mul_imag(self, 1.0)
  z = z.asin()
  z.mul_imag(-1.0)
}

///|
pub fn Complex::acosh(self : Complex) -> Complex {
  let z = self.acos()
  z.mul_imag(if z.im > 0 { -1.0 } else { 1.0 })
}

///|
pub fn Complex::acosh_real(x : Double) -> Complex {
  if x >= 1 {
    Complex::new(@luna_math.acosh(x), 0.0)
  } else if x >= -1.0 {
    Complex::new(0, @luna_math.acos(x))
  } else {
    Complex::new(@luna_math.acosh(-x), @luna_math.PI)
  }
}

///|
pub fn Complex::atanh(self : Complex) -> Complex {
  if self.im == 0.0 {
    Complex::atanh_real(self.re)
  } else {
    let mut z = Complex::mul_imag(self, 1.0)
    z = z.atan()
    z.mul_imag(-1.0)
  }
}

///|
pub fn Complex::atanh_real(x : Double) -> Complex {
  if x > -1.0 && x < 1.0 {
    Complex::new(@luna_math.atanh(x), 0.0)
  } else {
    Complex::new(
      @luna_math.atanh(1.0 / x),
      if x < 0 {
        @luna_math.PI / 2
      } else {
        -@luna_math.PI / 2
      },
    )
  }
}

///|
pub fn Complex::asech(self : Complex) -> Complex {
  self.inverse().acosh()
}

///|
pub fn Complex::acsch(self : Complex) -> Complex {
  self.inverse().asinh()
}

///|
pub fn Complex::acoth(self : Complex) -> Complex {
  self.inverse().atanh()
}

//prop

///|
pub impl Eq for Complex with op_equal(self : Complex, other : Complex) -> Bool {
  self.re == other.re && self.im == other.im
}
