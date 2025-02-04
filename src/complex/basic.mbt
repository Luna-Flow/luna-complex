///|
pub fn hypot(x : Double, y : Double) -> Double {
  @luna_math.sqrt(x * x + y * y)
}
///|
/// 双曲正弦函数
pub fn sinh(x: Double) -> Double {
    (@math.exp(x) - @math.exp(-x)) / 2.0
}
///|
/// 双曲余弦函数
pub fn cosh(x: Double) -> Double {
    (@math.exp(x) + @math.exp(-x)) / 2.0
}
///|
/// 双曲正切函数
pub fn tanh(x: Double) -> Double {
    sinh(x) / cosh(x)
}
///|
/// 反双曲正弦函数
pub fn asinh(x : Double) -> Double {
  if x == 0.0 {
    return 0.0
  }else{
    return @math.ln(x + Double::sqrt(x * x + 1.0))
  }
}
///|
/// 反双曲余弦函数 请确保输入数据满足 x>=1.0
pub fn acosh(x : Double) -> Double {
  if x >= 1.0 {
    return @math.ln(x + Double::sqrt(x * x - 1.0))
  }else{
    return 0.0
  }
}
///|
/// 反双曲正切函数 请确保输入数据位于区间(-1,1)
pub fn atanh(x : Double) -> Double {
  if x == 0.0 {
    return 0.0
  }else if x>-1 && x<1 {
    return 0.5 * @math.ln((1.0 + x) / (1.0 - x))
  }else{
    return 0.0
  }
}

///|
/// 计算ln(1+x) 注意x输入定义域是x > -1
pub fn log1p(x : Double) -> Double{
   if x == 0.0 {
    return 0.0  // ln(1 + 0) = 0
  } else if x > -1.0 {
    let one_plus_x = 1.0 + x
    if one_plus_x == 1.0 {
      // 如果 x 非常接近 0，直接返回 x（避免精度问题）
      return x
    } else {
      // 正常计算 ln(1 + x)
      return @math.ln(one_plus_x)
    }
  } else {
    // x <= -1 的情况下，1 + x ≤ 0，不合法
    return 0.0  // 返回 NaN（Not a Number）
  }
}