///|
pub impl[T : Show] Show for Complex[T] with fn to_string(self) -> String {
  self.re.to_string() + " + " + self.im.to_string() + "i"
}

///|
pub impl[T : Show] Show for Complex[T] with fn output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub impl[T : Add] Add for Complex[T] with fn add(
  self : Complex[T],
  other : Complex[T],
) -> Complex[T] {
  Complex::new(self.re + other.re, self.im + other.im)
}

///|
pub impl[T : Sub] Sub for Complex[T] with fn sub(
  self : Complex[T],
  other : Complex[T],
) -> Complex[T] {
  Complex::new(self.re - other.re, self.im - other.im)
}

///|
pub impl[T : Neg] Neg for Complex[T] with fn neg(self : Complex[T]) -> Complex[
  T,
] {
  Complex::new(-self.re, -self.im)
}

///|
pub impl[T : Mul + Add + Sub] Mul for Complex[T] with fn mul(
  self : Complex[T],
  other : Complex[T],
) -> Complex[T] {
  Complex::new(
    self.re * other.re - self.im * other.im,
    self.re * other.im + self.im * other.re,
  )
}

///|
pub impl[T : Zero] Zero for Complex[T] with fn zero() -> Complex[T] {
  Complex::new(T::zero(), T::zero())
}

///|
pub impl[T : One + Zero] One for Complex[T] with fn one() -> Complex[T] {
  Complex::new(T::one(), T::zero())
}

///|
pub impl[T : Neg] Conjugate for Complex[T] with fn conjugate(self : Complex[T]) -> Complex[
  T,
] {
  Complex::new(self.re, -self.im)
}

///|
pub impl[T : Field] Div for Complex[T] with fn div(
  self : Complex[T],
  other : Complex[T],
) -> Complex[T] {
  let denom_inv = (other.re * other.re + other.im * other.im).inv()
  Complex::new(
    (self.re * other.re + self.im * other.im) * denom_inv,
    (self.im * other.re - self.re * other.im) * denom_inv,
  )
}

///|
pub impl[T : Field] Inverse for Complex[T] with fn inv(self : Complex[T]) -> Complex[
  T,
] {
  let denom_inv = (self.re * self.re + self.im * self.im).inv()
  Complex::new(self.re * denom_inv, -self.im * denom_inv)
}

///|
pub impl[T : Add + Zero] AddMonoid for Complex[T]

///|
pub impl[T : Add + Zero + Neg + Sub] AddGroup for Complex[T]

///|
pub impl[T : Ring] MulMonoid for Complex[T]

///|
pub impl[T : Ring] Semiring for Complex[T]

///|
pub impl[T : Ring] Ring for Complex[T]

///|
pub impl[T : Field] MulGroup for Complex[T]

///|
pub impl[T : Field] Field for Complex[T]
