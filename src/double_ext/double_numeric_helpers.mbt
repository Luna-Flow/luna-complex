///|
let asin_a_crossover = 1.5

///|
let asin_b_crossover = 0.6417

///|
fn undefined_complex() -> Complex[Double] {
  Complex::new(@double.not_a_number, @double.not_a_number)
}

///|
fn is_negative_zero(x : Double) -> Bool {
  x == 0.0 && (1.0 / x).is_neg_inf()
}

///|
fn infinity_sign(x : Double) -> Double {
  if x.is_pos_inf() {
    1.0
  } else if x.is_neg_inf() {
    -1.0
  } else {
    0.0
  }
}

///|
fn quotient_with_infinite_denominator(
  a : Double,
  b : Double,
  c : Double,
  d : Double,
) -> Complex[Double] {
  let c_norm = infinity_sign(c)
  let d_norm = infinity_sign(d)
  let denom = c_norm * c_norm + d_norm * d_norm
  if a.is_inf() || b.is_inf() {
    stable_quotient(infinity_sign(a), infinity_sign(b), c_norm, d_norm)
  } else {
    let denom_inf = @double.infinity * denom
    Complex::new(
      (a * c_norm + b * d_norm) / denom_inf,
      (b * c_norm - a * d_norm) / denom_inf,
    )
  }
}

///|
fn stable_quotient(
  a : Double,
  b : Double,
  c : Double,
  d : Double,
) -> Complex[Double] {
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
fn complex_pow_integer(
  base : Complex[Double],
  exponent : Int,
) -> Complex[Double] {
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
fn scaled_tan_for_large_im(re : Double, im : Double) -> Complex[Double] {
  let sign = if im >= 0.0 { 1.0 } else { -1.0 }
  let decay = real_exp(-2.0 * im.abs())
  let decay_sq = decay * decay
  let sin_2re = real_sin(2.0 * re)
  let cos_2re = real_cos(2.0 * re)
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
    return 0.5 * real_atan2(2.0 * re, 1.0 - re * re - im * im)
  }
  let re_scaled = re / max_val
  let im_scaled = im / max_val
  let inv_scale_sq = 1.0 / (max_val * max_val)
  0.5 *
  real_atan2(
    2.0 * re_scaled / max_val,
    inv_scale_sq - re_scaled * re_scaled - im_scaled * im_scaled,
  )
}

///|
fn atan_infinite(re : Double, im : Double) -> Complex[Double] {
  let real = if re > 0.0 {
    half_pi
  } else if re < 0.0 {
    -half_pi
  } else if im > 0.0 {
    half_pi
  } else {
    -half_pi
  }
  Complex::new(real, 0.0)
}

///|
fn asin_large_magnitude(re : Double, im : Double) -> Complex[Double] {
  let x = re.abs()
  let y = im.abs()
  let real = real_atan2(x, y)
  let imag = real_ln(2.0) + abs_log(Complex::new(x, y))
  Complex::new(
    if re >= 0.0 {
      real
    } else {
      -real
    },
    if im >= 0.0 {
      imag
    } else {
      -imag
    },
  )
}

///|
fn scaled_tanh_for_large_re(re : Double, im : Double) -> Complex[Double] {
  let sign = if re >= 0.0 { 1.0 } else { -1.0 }
  let decay = real_exp(-2.0 * re.abs())
  let decay_sq = decay * decay
  let sin_2im = real_sin(2.0 * im)
  let cos_2im = real_cos(2.0 * im)
  let denom = 1.0 + decay_sq + 2.0 * decay * cos_2im
  Complex::new(sign * (1.0 - decay_sq) / denom, 2.0 * decay * sin_2im / denom)
}

///|
fn atanh_real_component(re : Double, im : Double) -> Double {
  let u = 4.0 * re / ((1.0 - re) * (1.0 - re) + im * im)
  if u.abs() < 0.25 {
    0.25 * @lm.log1p(u)
  } else {
    let a = @lm.hypot(1.0 + re, im)
    let b = @lm.hypot(1.0 - re, im)
    0.5 * @lm.log(a / b)
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
    return 0.5 * real_atan2(2.0 * im, 1.0 - re * re - im * im)
  }
  let re_scaled = re / max_val
  let im_scaled = im / max_val
  let inv_scale_sq = 1.0 / (max_val * max_val)
  0.5 *
  real_atan2(
    2.0 * im_scaled / max_val,
    inv_scale_sq - re_scaled * re_scaled - im_scaled * im_scaled,
  )
}

///|
fn atanh_infinite(_re : Double, im : Double) -> Complex[Double] {
  if im.is_pos_inf() {
    Complex::new(0.0, half_pi)
  } else if im.is_neg_inf() {
    Complex::new(0.0, -half_pi)
  } else if im < 0.0 {
    Complex::new(0.0, -half_pi)
  } else {
    Complex::new(0.0, half_pi)
  }
}
