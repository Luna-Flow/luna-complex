///|
pub type Complex[T] = @core.Complex[T]

///|
using @cmp {maximum}

///|
using @arith {
  trait Constants,
  trait Exponential,
  trait Hyperbolic,
  trait InverseHyperbolic,
  trait InverseTrigonometric,
  trait Logarithmic,
  trait Sqrt,
  trait Trigonometric,
}

///|
let half_pi : Double = Constants::pi() / 2.0

///|
let tau : Double = Constants::tau()

///|
fn real_sqrt(x : Double) -> Double {
  Sqrt::sqrt(x)
}

///|
fn real_exp(x : Double) -> Double {
  Exponential::exp(x)
}

///|
fn real_ln(x : Double) -> Double {
  Logarithmic::ln(x)
}

///|
fn real_sin(x : Double) -> Double {
  Trigonometric::sin(x)
}

///|
fn real_cos(x : Double) -> Double {
  Trigonometric::cos(x)
}

///|
fn real_asin(x : Double) -> Double {
  InverseTrigonometric::asin(x)
}

///|
fn real_acos(x : Double) -> Double {
  InverseTrigonometric::acos(x)
}

///|
fn real_atan(x : Double) -> Double {
  InverseTrigonometric::atan(x)
}

///|
fn real_atan2(y : Double, x : Double) -> Double {
  InverseTrigonometric::atan2(y, x)
}

///|
fn real_sinh(x : Double) -> Double {
  Hyperbolic::sinh(x)
}

///|
fn real_cosh(x : Double) -> Double {
  Hyperbolic::cosh(x)
}

///|
fn real_asinh(x : Double) -> Double {
  InverseHyperbolic::asinh(x)
}

///|
fn real_acosh(x : Double) -> Double {
  InverseHyperbolic::acosh(x)
}

///|
fn real_atanh(x : Double) -> Double {
  InverseHyperbolic::atanh(x)
}
