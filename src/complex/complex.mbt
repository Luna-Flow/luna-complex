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
  Complex::new(r * @math.cos(theta), r * @math.sin(theta))
}

///|
/// 计算复数的辐角
pub fn Complex::arg(self : Complex) -> Double {
  guard self.re != 0.0 || self.im != 0.0 else { 0.0 }
  @math.atan2(self.im, self.re)
}

///|
/// 求 虚数的模
pub fn Complex::abs(self : Complex) -> Double {
  @basic.hypot(self.re, self.im)
}

///|
/// 求 虚数模的平方
pub fn Complex::abs_sqr(self : Complex) -> Double {
  self.re * self.re + self.im * self.im
}

///|
/// 计算虚数模长的对数 即ln(|self|)
pub fn Complex::abs_log(self : Complex) -> Double {
  let re_abs = self.re.abs()
  let im_abs = self.im.abs()
  let mut t = 0.0
  if re_abs >= im_abs {
    t = im_abs / re_abs
  } else {
    t = re_abs / im_abs
  }
  @math.ln(@basic.max(re_abs, im_abs)) + 0.5 * @math.ln(1.0 + t * t)
}

///|
/// 重载‘+’，计算虚数相加
pub fn Complex::op_add(self : Complex, other : Complex) -> Complex {
  Complex::new(self.re + other.re, self.im + other.im)
}

///|
/// 实现加法函数，计算虚数相加
pub fn Complex::add(self : Complex, other : Complex) -> Unit {
  self.re = self.re + other.re
  self.im = self.im + other.im
}

///|
/// 计算 虚数+Double 类型的式子 生成一个新的复数
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
/// 重载‘-’，计算虚数相减
pub fn Complex::op_sub(self : Complex, other : Complex) -> Complex {
  Complex::new(self.re - other.re, self.im - other.im)
}

///|
/// 实现减法函数，计算虚数相减
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
/// 计算 虚数/Double 类型的式子 生成一个新的复数
pub fn Complex::div_real(self : Complex, other : Double) -> Complex {
  Complex::new(self.re / other, self.im / other)
}

///|
/// 计算 虚数/Double 类型的式子 改变原始复数
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
/// 求共轭虚数 由a+bi求a-bi 生成一个新的复数
pub fn Complex::conjugate(self : Complex) -> Complex {
  Complex::new(self.re, -self.im)
}

///|
/// 求共轭虚数 由a+bi求a-bi 直接修改原始复数
pub fn Complex::conjugate_inplace(self : Complex) -> Unit {
  self.im = -self.im
}

///|
/// 重载的 虚数取反符
pub fn Complex::op_neg(self : Complex) -> Complex {
  Complex::new(-self.re, -self.im)
}

///|
/// 求虚数的相反数
pub fn Complex::neg(self : Complex) -> Unit {
  self.re = -self.re
  self.im = -self.im
}
///|
/// 求虚数的倒数 1/x
pub fn Complex::inverse(self : Complex) -> Complex {
  let s = 1.0 / self.abs()
  Complex::new(self.re * s * s, -self.im * s * s)
}
///|
/// 求虚数类型的平方根
pub fn Complex::sqrt(self : Complex) -> Complex {
  guard self.re != 0 || self.im != 0 else { Complex::new(0.0, 0.0) }
  let re_abs = self.re.abs()
  let im_abs = self.im.abs()
  let mut w = 0.0
  if re_abs >= im_abs {
    let t = im_abs / re_abs
    w = @basic.sqrt(re_abs) *
      @basic.sqrt(0.5 * (1.0 + @basic.hypot(1.0, t)))
  } else {
    let t = re_abs / im_abs
    w = @basic.sqrt(im_abs) *
      @basic.sqrt(0.5 * (t + @basic.hypot(1.0, t)))
  }
  if self.re >= 0.0 {
    Complex::new(w, self.im / (2.0 * w))
  } else {
    let im = if self.im >= 0.0 { w } else { -w }
    Complex::new(self.im / (2.0 * im), im)
  }
}
///|
/// 求Double类型的平方根 如果为负数返回复数
pub fn Complex::sqrt_real(self :Double) -> Complex{
  if self >= 0{
    Complex::new(@basic.sqrt(self),0)
  }else{
    Complex::new(0,@basic.sqrt(-self))
  }
}
///|
/// 这个函数的实现基于欧拉公式 e^(a+bi) = (e^a)*(cosb+i*sinb)
pub fn Complex::exp(self : Complex) -> Complex {
  let rho = @math.exp(self.re) //计算e^re
  let thete = self.im
  Complex::new(rho * @math.cos(thete), rho * @math.sin(thete) )
}
///|
/// 计算 self^other 其中self是调用者，other是传递的参数。二者都是虚数
pub fn Complex::pow(self : Complex, other : Complex) -> Complex{
  if self.re==0.0 && self.im==0.0{
    if other.re==0.0 && other.im==0.0 {
      return Complex::new(1.0,0.0)
    }else{
      return Complex::new(0.0,0.0)
    }
  }else if other.re==1.0 && other.im==0.0{
    return self
  }else if other.re==-1.0 && other.im==0.0{
    return self.conjugate()
  }else{
    let logr = self.abs_log()
    let theta = self.arg()
    let oreal = other.re
    let oimag = other.im
    let rho = @math.ln(logr * oreal - oimag * theta)
    let beta = theta * oreal + oimag * logr
    return Complex::new(rho * @math.cos(beta), rho * @math.sin(beta))
  }
}
///|
/// 计算 self^other类型的式子 其中self(复数)是调用者，other(Double)是传递的参数
pub fn Complex::pow_real(self : Complex, other : Double) -> Complex{
  if self.re==0 && self.im==0 {
    if other==0 {
      return Complex::new(1.0,0.0)
    }else{
      return Complex::new(0.0,0.0)
    }
  }else{
    let logr = self.abs_log()
    let theta = self.arg()
    let rho = @math.exp(logr * other)
    let beta = theta * other
    Complex::new(rho * @math.cos(beta), rho * @math.sin(beta))
  }
}
///|
/// 计算复数的自然对数 即ln(x) x是复数
pub fn Complex::log(self : Complex) -> Complex {
  let logr = self.abs_log()
  let theta = self.arg()
  Complex::new(logr,theta)
}
///|
/// 计算复数的对数（以10为底）
/// log[10](a) = ln(a) / ln(10)
pub fn Complex::log10(self : Complex) -> Complex {
  mul_real(self.log(),1.0/@math.ln(10))
}
///|
/// 计算复数的对数 （以复数为底）
pub fn Complex::log_b(self : Complex, other : Complex) -> Complex {
  self.log() / other.log()
}


//***********************************************************************
//* Complex trigonometric functions
//***********************************************************************
///|
/// 计算复数的正弦
pub fn Complex::sin(self : Complex) -> Complex {
  if self.im==0.0 {
    //* avoid returing negative zero (-0.0) for the imaginary part
    return Complex::new(@math.sin(self.re),0.0)
  }else{
    return Complex::new(@math.sin(self.re) * @basic.cosh(self.im),
                        @math.cos(self.re) * @basic.sinh(self.im))
  }
}
///|
/// 计算复数的余弦
pub fn Complex::cos(self : Complex) -> Complex {
  if self.im==0.0 {  
    //* avoid returing negative zero (-0.0) for the imaginary part
    Complex::new(@math.cos(self.re),0.0)
  }else{
    return Complex::new(@math.cos(self.re) * @basic.cosh(self.im),
                        @math.sin(self.re) * @basic.sinh(self.im))
  }
}
///|
/// 计算复数的正切
pub fn Complex::tan(self : Complex) -> Complex {
  let r = self.re
  let i = self.im
  if i<1.0 && i>-1.0 {
     let d = @double.pow(@math.cos(r), 2.0) + @double.pow(@basic.sinh(i), 2.0) 
     Complex::new(0.5 * @math.sin(2.0 * r) / d, 0.5 * @basic.sinh(2.0 * i) / d)
  }else{
     let d = @double.pow(@math.cos(r), 2.0) + @double.pow(@basic.sinh(i), 2.0) 
     let f = 1.0 + @double.pow(@math.cos(r) / @basic.sinh(i), 2.0)
     Complex::new(0.5 * @math.sin(2.0 * r) / d, 1.0 / (@basic.tanh(i) * f))
  } 
}
///|
/// 计算复数的sec  sec(x) = 1/cos(x)
pub fn Complex::sec(self : Complex) -> Complex {
  self.cos().inverse()
}
///|
/// 计算复数的csc  csc(x) = 1/sin(x)
pub fn Complex::csc(self : Complex) -> Complex {
  self.sin().inverse()
}
///|
/// 计算复数的cot  cot(x) = 1/tan(x)
pub fn Complex::cot(self : Complex) -> Complex {
  self.tan().inverse()
}

// /**********************************************************************
//  * Inverse Complex Trigonometric Functions
//  **********************************************************************/
const A_crossover = 1.5
const B_crossover = 0.6417
///|
/// 计算复数的复数反正弦（arcsine）
pub fn Complex::arcsin(self : Complex) -> Complex {
  let re = self.re
  let im = self.im

  if im==0 {
    arcsin_real(re)
  }else{

    let x = Double::abs(re)
    let y = Double::abs(im)
    let r = @basic.hypot(x + 1, y)
    let s = @basic.hypot(x - 1, y)
    let a = 0.5 * (r + s)
    let b = x / a
    let y2 = y * y

    let mut real = 0.0
    let mut imag = 0.0

    if b <= B_crossover {
      real = @math.asin(b)
    }else{
      if x <= 1 {
        let d = 0.5 * (a + x) * (y2 / (r + x + 1.0)) + (s + (1.0 - x))
        real = @math.atan (x / Double::sqrt(d))
      }else{
        let apx = a + x
        let d = 0.5 * (apx / (r + x + 1.0) + apx / (s + (x - 1.0)))
        real = @math.atan(x / (y * Double::sqrt(d)))
      }
    }

    if a <= A_crossover {
      let mut am1 = 0.0
      if x < 1 {
        am1 = 0.5 * (y2 / (r + (x + 1.0)) + y2 / (s + (1.0 - x)))
      }else{
        am1 = 0.5 * (y2 / (r + (x + 1.0)) + (s + (x - 1.0)))
      }
      imag = @basic.log1p(am1 + Double::sqrt(a * a - 1.0))
    }else{
      imag = @math.ln(a + Double::sqrt(a * a - 1.0))
    }
    Complex::new(
      if re >= 0 {real} else {-real},
      if im >= 0 {imag} else {-imag})
  }
}
///|
/// 计算实数的复数反正弦（arcsine）
pub fn Complex::arcsin_real(x : Double) -> Complex{
  if x >= -1.0 && x <= 1.0 {
    Complex::new(@math.asin(x), 0.0)
  }else{
    if x < 0.0 {
      Complex::new(-@math.PI / 2.0, @basic.acosh(-x))
    }else{
      Complex::new(@math.PI / 2.0, -@basic.acosh(x))
    }
  }
}
///|
/// 计算复数的反余弦
pub fn Complex::arccos(self : Complex) -> Complex {
  let re = self.re
  let im = self.im
  if im == 0 {
    arccos_real(re)
  }else{
    let x = Double::abs(re)
    let y = Double::abs(im)
    let r = @basic.hypot(x + 1, y)
    let s = @basic.hypot(x - 1, y)
    let a = 0.5 * (r + s)
    let b = x / a
    let y2 = y * y

    let mut real = 0.0
    let mut imag = 0.0

    if b <= B_crossover {
      real = @math.acos(b)
    }else{
      if x <= 1 {
        let d = 0.5 * (a + x) * (y2 / (r + x + 1.0) + (s + (1.0 - x)))
        real = @math.atan(Double::sqrt(d) / x)
      }else{
        let apx = a + x
        let d = 0.5 * (apx / (r + x + 1.0) + apx / (s + (x - 1.0)))
        real = @math.atan((y * Double::sqrt(d)) / x)
      }
    }
    if a <= A_crossover {
      let mut am1 = 0.0

      if x < 1{
        am1 = 0.5 * (y2 / (r + (x + 1)) + y2 / (s + (1.0 - x)))
      }else {
        am1 = 0.5 * (y2 / (r + (x + 1)) + (s + (x - 1)))
      }
      imag = @basic.log1p(am1 + Double::sqrt(am1 * (a + 1)))
    }else{
      imag = @math.ln(a + Double::sqrt(a * a - 1.0))
    }
    Complex::new(
      if re >= 0 {real} else {@math.PI - real},
      if im >= 0 {-imag} else {imag})
  }
}

///|
/// 计算实数的复数反余弦
pub fn Complex::arccos_real (x : Double) -> Complex {
  if x >= -1.0 && x <= 1.0 {
    Complex::new(@math.acos(x), 0.0)
  }else{
    if x < 0.0{
      Complex::new(@math.PI, -@basic.acosh(-x))
    }else{
      Complex::new(0, @basic.acosh(x))
    }
  }
}
///|
///计算虚数的反正切 
pub fn arctan (self : Complex) -> Complex {
  let re = self.re
  let im = self.im
  if im == 0 {
    Complex::new(@math.atan(re),0.0)
  }else{
    // FIXME: This is a naive implementation which does not fully
    // take into account cancellation errors, overflow, underflow
    // etc.  It would benefit from the Hull et al treatment.
    let r = @basic.hypot(re,im)
    let mut imag = 0.0
    let u = 2.0 * im / (1.0 + r * r)
    //* FIXME: the following cross-over should be optimized but 0.1
    //  seems to work ok */
    if Double::abs(u) < 0.1{
      imag = 0.25 * (@basic.log1p(u) - @basic.log1p(-u))
    }else{
      let a = @basic.hypot(re, im + 1.0)
      let b = @basic.hypot(re, im - 1.0)
      imag = 0.5 * @math.ln(a / b)
    }

    if re == 0 {
      if im > 1.0{
        Complex::new(@math.PI / 2.0, imag)
      }else if im < -1.0{
        Complex::new(-@math.PI / 2.0, imag)
      }else{
        Complex::new(0.0, imag)
      }
    }else{
      Complex::new(0.5 * @math.atan2(2.0 * re, ((1.0 + r) * (1.0 - r))), imag)
    }
  }
}
///|
/// 计算虚数的反正割
pub fn Complex::arcsec(self : Complex) -> Complex {
  self.inverse().arccos()
}
///|
/// 计算实数的反正割
pub fn Complex::aecsec_real(x : Double) -> Complex {
  if x <- -1.0 || x >= 1.0 {
    Complex::new(@math.acos(1.0 / x), 0.0)
  }else{
    if x >= 0.0 {
      Complex::new(0.0, @basic.acosh(1.0 / x))
    }else{
      Complex::new(@math.PI, -@basic.acosh(-1.0 / x))
    }
  }
}
///|
///  计算复数的反余割
pub fn Complex::arccsc(self : Complex) -> Complex {
  self.inverse().arcsin()
}
///|
/// 计算实数的反余割
pub fn Complex::arccsc_real(x : Double) -> Complex {
  if x <= -1.0 || x >= 1.0 {
    Complex::new(@math.asin(1.0 / x), 0.0)
  }else{
    if x >= 0.0{
      Complex::new(@math.PI / 2.0, -@basic.acosh(1.0 / x))
    }else{
      Complex::new(-@math.PI / 2.0, @basic.acosh(-1.0 / x))
    }
  }
}
///|
/// 计算复数的反余切
pub fn Complex::arccot(self : Complex) -> Complex {
  if self.re == 0.0 && self.im == 0.0 {
    Complex::new(@math.PI / 2.0, 0.0)
  }else{
    self.inverse().arctan()
  }
}

// /**********************************************************************
//  * Complex Hyperbolic Functions
//  **********************************************************************/
///|
pub fn Complex::sinh(self : Complex) -> Complex {
  let re = self.re
  let im = self.im
  Complex::new(@basic.sinh(re) * @math.cos(im),
                @basic.cosh(re) * @math.sin(im) )
 }
 ///|
pub fn Complex::cosh(self : Complex) -> Complex {
  let re = self.re
  let im = self.im
  Complex::new(@basic.cosh(re) * @math.cos(im),
                  @basic.sinh(re) * @math.sin(im))
}
pub fn Complex::tanh(self : Complex) -> Complex {
  let re = self.re
  let im = self.im
  if re > -1.0 && re < 1.0 {
    let d = Double::pow(@math.cos(im), 2.0) + Double::pow(@basic.sinh(re), 2.0)
    Complex::new(@basic.sinh(re) * @basic.cosh(re) / d, 0.5 * @math.sin(2.0 * im) / d)
  }else{
    let d = Double::pow(@math.cos(im), 2.0) + Double::pow(@basic.sinh(re), 2.0)
    let f = 1.0 + Double::pow(@math.cos(im) / @basic.sinh(re), 2.0)
    Complex::new(1.0 / (@basic.tanh(re) * f), 0.5 * @math.sin(2.0 * im) / d)
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

//  **********************************************************************
//  * Inverse Complex Hyperbolic Functions
//  **********************************************************************/

///|
pub fn Complex::arcsinh(self : Complex) -> Complex {
  let mut z = mul_imag(self, 1.0)
  z = z.arcsin()
  z.mul_imag(-1.0)
} 
///|
pub fn Complex::arccosh(self : Complex) -> Complex {
  let z = self.arccos()
  z.mul_imag(  if z.im > 0 {-1.0} 
               else {1.0}   )
}
pub fn Complex::arccosh_real(x : Double) -> Complex {
  if x >= 1 {
    Complex::new(@basic.acosh(x), 0.0)
  }else{
    if x >= -1.0 {
      Complex::new(0, @math.acos(x))
    }else{
      Complex::new(@basic.acosh(-x), @math.PI)
    }
  }
}
pub fn Complex::arctanh(self : Complex) -> Complex {
  if self.im == 0.0 {
    arctanh_real(self.re)
  }else{
    let mut z = mul_imag(self , 1.0)
    z = z.arctan()
    z.mul_imag(-1.0)
  }
}
pub fn Complex::arctanh_real(x : Double) -> Complex {
  if x > -1.0 && x < 1.0 {
    Complex::new(@basic.atanh(x), 0.0)
  }else{
    Complex::new(@basic.atanh(1.0 / x) ,
                  if x < 0 {@math.PI / 2}
                  else     {-@math.PI / 2})
  }
}
pub fn Complex::arcsech(self : Complex) -> Complex {
  self.inverse().arccosh()
}
pub fn Complex::arccsch(self : Complex) -> Complex {
  self.inverse().arcsinh()
}
pub fn Complex::arccoth(self : Complex) -> Complex {
  self.inverse().arctanh()
}




///|
/// 阶乘函数 
pub fn factorial(n: Int) -> Double {
    if n == 0 {
        return 1.0
    } else {
        let mut result = 1.0
        for i in 1..<n {
            result = result * i.to_double()
        }
        return result
    }
}

//prop

///|
pub impl Eq for Complex with op_equal(self : Complex, other : Complex) -> Bool {
  self.re == other.re && self.im == other.im
}
