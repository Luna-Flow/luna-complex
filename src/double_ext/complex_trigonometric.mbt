///|
pub fn sin(z : Complex[Double]) -> Complex[Double] {
  if z.im == 0.0 {
    Complex::new(real_sin(z.re), 0.0)
  } else {
    Complex::new(
      real_sin(z.re) * real_cosh(z.im),
      real_cos(z.re) * real_sinh(z.im),
    )
  }
}

///|
pub fn cos(z : Complex[Double]) -> Complex[Double] {
  if z.im == 0.0 {
    Complex::new(real_cos(z.re), 0.0)
  } else {
    Complex::new(
      real_cos(z.re) * real_cosh(z.im),
      real_sin(z.re) * real_sinh(-z.im),
    )
  }
}

///|
pub fn tan(z : Complex[Double]) -> Complex[Double] {
  let re = z.re
  let im = z.im
  let cos_re = real_cos(re)
  let sinh_im = real_sinh(im)
  let denom = cos_re * cos_re + sinh_im * sinh_im
  if im > -1.0 && im < 1.0 {
    Complex::new(
      0.5 * real_sin(2.0 * re) / denom,
      0.5 * real_sinh(2.0 * im) / denom,
    )
  } else {
    scaled_tan_for_large_im(re, im)
  }
}

///|
pub fn sec(z : Complex[Double]) -> Complex[Double] {
  cos(z).inv()
}

///|
pub fn csc(z : Complex[Double]) -> Complex[Double] {
  sin(z).inv()
}

///|
pub fn cot(z : Complex[Double]) -> Complex[Double] {
  tan(z).inv()
}

///|
pub fn asin(z : Complex[Double]) -> Complex[Double] {
  let re = z.re
  let im = z.im
  if im == 0.0 {
    asin_real(re)
  } else if re == 0.0 {
    Complex::new(0.0, real_asinh(im))
  } else if re.abs() > 1.0e150 || im.abs() > 1.0e150 {
    asin_large_magnitude(re, im)
  } else {
    let x = re.abs()
    let y = im.abs()
    let r = @lm.hypot(x + 1.0, y)
    let s = @lm.hypot(x - 1.0, y)
    let a = 0.5 * (r + s)
    let b = x / a
    let y2 = y * y
    let real = if b <= asin_b_crossover {
      real_asin(b)
    } else if x <= 1.0 {
      let d = 0.5 * (a + x) * (y2 / (r + x + 1.0) + (s + (1.0 - x)))
      real_atan(x / real_sqrt(d))
    } else {
      let a_plus_x = a + x
      let d = 0.5 * (a_plus_x / (r + x + 1.0) + a_plus_x / (s + (x - 1.0)))
      real_atan(x / (y * real_sqrt(d)))
    }
    let im_res = if a <= asin_a_crossover {
      let am1 = if x < 1.0 {
        0.5 * (y2 / (r + x + 1.0) + y2 / (s + (1.0 - x)))
      } else {
        0.5 * (y2 / (r + x + 1.0) + (s + (x - 1.0)))
      }
      @lm.log1p(am1 + real_sqrt(a * a - 1.0))
    } else {
      real_ln(a + real_sqrt(a * a - 1.0))
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
pub fn asin_real(x : Double) -> Complex[Double] {
  if x.is_nan() {
    undefined_complex()
  } else if x >= -1.0 && x <= 1.0 {
    Complex::new(real_asin(x), 0.0)
  } else if x < 0.0 {
    Complex::new(-half_pi, real_acosh(-x))
  } else {
    Complex::new(half_pi, real_acosh(x))
  }
}

///|
pub fn acos(z : Complex[Double]) -> Complex[Double] {
  let re = z.re
  let im = z.im
  if im == 0.0 {
    acos_real(re)
  } else if re == 0.0 {
    Complex::new(half_pi, -real_asinh(im))
  } else if re.abs() > 1.0e150 || im.abs() > 1.0e150 {
    let asin_z = asin_large_magnitude(re, im)
    Complex::new(half_pi - asin_z.re, -asin_z.im)
  } else {
    let x = re.abs()
    let y = im.abs()
    let r = @lm.hypot(x + 1.0, y)
    let s = @lm.hypot(x - 1.0, y)
    let a = 0.5 * (r + s)
    let b = x / a
    let y2 = y * y
    let real = if b <= asin_b_crossover {
      real_acos(b)
    } else if x <= 1.0 {
      let d = 0.5 * (a + x) * (y2 / (r + x + 1.0) + (s + (1.0 - x)))
      real_atan(real_sqrt(d) / x)
    } else {
      let a_plus_x = a + x
      let d = 0.5 * (a_plus_x / (r + x + 1.0) + a_plus_x / (s + (x - 1.0)))
      real_atan(y * real_sqrt(d) / x)
    }
    let im_res = if a <= asin_a_crossover {
      let am1 = if x < 1.0 {
        0.5 * (y2 / (r + x + 1.0) + y2 / (s + (1.0 - x)))
      } else {
        0.5 * (y2 / (r + x + 1.0) + (s + (x - 1.0)))
      }
      @lm.log1p(am1 + real_sqrt(am1 * (a + 1.0)))
    } else {
      real_ln(a + real_sqrt(a * a - 1.0))
    }
    Complex::new(
      if re >= 0.0 {
        real
      } else {
        tau - real
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
pub fn acos_real(x : Double) -> Complex[Double] {
  if x.is_nan() {
    undefined_complex()
  } else if x >= -1.0 && x <= 1.0 {
    Complex::new(real_acos(x), 0.0)
  } else if x < 0.0 {
    Complex::new(tau, -real_acosh(-x))
  } else {
    Complex::new(0.0, -real_acosh(x))
  }
}

///|
pub fn atan(z : Complex[Double]) -> Complex[Double] {
  let re = z.re
  let im = z.im
  if !re.is_nan() && !im.is_nan() && (re.is_inf() || im.is_inf()) {
    atan_infinite(re, im)
  } else if im == 0.0 {
    Complex::new(real_atan(re), 0.0)
  } else {
    let radius = @lm.hypot(re, im)
    let u = 2.0 * im / (1.0 + radius * radius)
    let im_abs = if u.abs() < 0.1 {
      0.25 * (@lm.log1p(u) - @lm.log1p(-u))
    } else {
      let a = @lm.hypot(re, im + 1.0)
      let b = @lm.hypot(re, im - 1.0)
      0.5 * @lm.log(a / b)
    }
    if re == 0.0 {
      if im > 1.0 {
        Complex::new(half_pi, im_abs)
      } else if im < -1.0 {
        Complex::new(-half_pi, im_abs)
      } else {
        Complex::new(0.0, im_abs)
      }
    } else {
      Complex::new(atan_real_component(re, im), im_abs)
    }
  }
}

///|
pub fn asec(z : Complex[Double]) -> Complex[Double] {
  acos(z.inv())
}

///|
pub fn asec_real(x : Double) -> Complex[Double] {
  if x <= -1.0 || x >= 1.0 {
    Complex::new(real_acos(1.0 / x), 0.0)
  } else if x >= 0.0 {
    Complex::new(0.0, -real_acosh(1.0 / x))
  } else {
    Complex::new(tau, -real_acosh(-1.0 / x))
  }
}

///|
pub fn acsc(z : Complex[Double]) -> Complex[Double] {
  asin(z.inv())
}

///|
pub fn acsc_real(x : Double) -> Complex[Double] {
  if x <= -1.0 || x >= 1.0 {
    Complex::new(real_asin(1.0 / x), 0.0)
  } else if x >= 0.0 {
    Complex::new(half_pi, real_acosh(1.0 / x))
  } else {
    Complex::new(-half_pi, real_acosh(-1.0 / x))
  }
}

///|
pub fn acot(z : Complex[Double]) -> Complex[Double] {
  if z.re == 0.0 && z.im == 0.0 {
    Complex::new(half_pi, 0.0)
  } else {
    atan(z.inv())
  }
}
