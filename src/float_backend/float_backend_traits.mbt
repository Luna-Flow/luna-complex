///|
pub(open) trait FloatingAnalyticScalar: @luna-generic.Field + @luna-generic.Num + Compare + Constants + Sqrt + Exponential + Logarithmic + Trigonometric + InverseTrigonometric + Hyperbolic + InverseHyperbolic {
}

///|
pub(open) trait FloatingSpecialValues {
  fn nan() -> Self
  fn infinity() -> Self
  fn neg_infinity() -> Self
  fn is_nan(Self) -> Bool
  fn is_inf(Self) -> Bool
  fn is_pos_inf(Self) -> Bool
  fn is_neg_inf(Self) -> Bool
  fn is_negative_zero(Self) -> Bool
}

///|
pub(open) trait FloatingBackendScalar: FloatingAnalyticScalar + FloatingSpecialValues {
  fn from_double(Double) -> Self
  fn trunc(Self) -> Self
  fn to_int(Self) -> Int
  fn hypot(Self, Self) -> Self
  fn log1p(Self) -> Self
}

///|
pub impl FloatingAnalyticScalar for Float

///|
pub impl FloatingSpecialValues for Float with fn nan() {
  @float.not_a_number
}

///|
pub impl FloatingSpecialValues for Float with fn infinity() {
  @float.infinity
}

///|
pub impl FloatingSpecialValues for Float with fn neg_infinity() {
  @float.neg_infinity
}

///|
pub impl FloatingSpecialValues for Float with fn is_nan(x) {
  Float::is_nan(x)
}

///|
pub impl FloatingSpecialValues for Float with fn is_inf(x) {
  Float::is_inf(x)
}

///|
pub impl FloatingSpecialValues for Float with fn is_pos_inf(x) {
  Float::is_pos_inf(x)
}

///|
pub impl FloatingSpecialValues for Float with fn is_neg_inf(x) {
  Float::is_neg_inf(x)
}

///|
pub impl FloatingSpecialValues for Float with fn is_negative_zero(x) {
  Float::is_neg_inf(1.0 / x)
}

///|
pub impl FloatingBackendScalar for Float with fn from_double(x) {
  Float::from_double(x)
}

///|
pub impl FloatingBackendScalar for Float with fn trunc(x) {
  Float::trunc(x)
}

///|
pub impl FloatingBackendScalar for Float with fn to_int(x) {
  Float::to_int(x)
}

///|
pub impl FloatingBackendScalar for Float with fn hypot(x, y) {
  @lm.hypotf(x, y)
}

///|
pub impl FloatingBackendScalar for Float with fn log1p(x) {
  Logarithmic::ln(1.0 + x)
}

///|
pub impl FloatingAnalyticScalar for Double

///|
pub impl FloatingSpecialValues for Double with fn nan() {
  @double.not_a_number
}

///|
pub impl FloatingSpecialValues for Double with fn infinity() {
  @double.infinity
}

///|
pub impl FloatingSpecialValues for Double with fn neg_infinity() {
  @double.neg_infinity
}

///|
pub impl FloatingSpecialValues for Double with fn is_nan(x) {
  Double::is_nan(x)
}

///|
pub impl FloatingSpecialValues for Double with fn is_inf(x) {
  Double::is_inf(x)
}

///|
pub impl FloatingSpecialValues for Double with fn is_pos_inf(x) {
  Double::is_pos_inf(x)
}

///|
pub impl FloatingSpecialValues for Double with fn is_neg_inf(x) {
  Double::is_neg_inf(x)
}

///|
pub impl FloatingSpecialValues for Double with fn is_negative_zero(x) {
  Double::is_neg_inf(1.0 / x)
}

///|
pub impl FloatingBackendScalar for Double with fn from_double(x) {
  x
}

///|
pub impl FloatingBackendScalar for Double with fn trunc(x) {
  Double::trunc(x)
}

///|
pub impl FloatingBackendScalar for Double with fn to_int(x) {
  Double::to_int(x)
}

///|
pub impl FloatingBackendScalar for Double with fn hypot(x, y) {
  @lm.hypot(x, y)
}

///|
pub impl FloatingBackendScalar for Double with fn log1p(x) {
  @lm.log1p(x)
}
