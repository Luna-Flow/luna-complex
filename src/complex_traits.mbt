///|
pub impl Show for Complex with fn to_string(self) -> String {
  self.re.to_string() + " + " + self.im.to_string() + "i"
}

///|
pub impl Show for Complex with fn output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub impl Mul for Complex with fn mul(self : Complex, other : Complex) -> Complex {
  Complex::new(
    self.re * other.re - self.im * other.im,
    self.re * other.im + self.im * other.re,
  )
}

///|
pub impl Add for Complex with fn add(self : Complex, other : Complex) -> Complex {
  Complex::new(self.re + other.re, self.im + other.im)
}

///|
pub impl Neg for Complex with fn neg(self : Complex) -> Complex {
  Complex::new(-self.re, -self.im)
}

///|
pub impl Inverse for Complex with fn inv(self : Complex) -> Complex {
  guard self.re != 0.0 || self.im != 0.0 else { undefined_complex() }
  let scale = 1.0 / self.abs_sqr()
  Complex::new(self.re * scale, -self.im * scale)
}

///|
pub impl One for Complex with fn one() -> Complex {
  Complex::new(1.0, 0.0)
}

///|
pub impl Zero for Complex with fn zero() -> Complex {
  Complex::new(0.0, 0.0)
}

///|
pub impl Conjugate for Complex with fn conjugate(self : Complex) -> Complex {
  Complex::new(self.re, -self.im)
}

///|
pub impl Sub for Complex with fn sub(self : Complex, other : Complex) -> Complex {
  Complex::new(self.re - other.re, self.im - other.im)
}
