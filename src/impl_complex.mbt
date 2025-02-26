///|
pub impl Eq for Complex with op_equal(self : Complex, other : Complex) -> Bool {
  self.re == other.re && self.im == other.im
}

///|
pub impl Show for Complex with to_string(s) -> String {
  s.re.to_string() + " + " + s.im.to_string() + "i"
}

///|
pub impl Show for Complex with output(s, l) {
  l.write_string(s.to_string())
}

///|
pub impl @lg.Mul for Complex with op_mul(self : Complex, other : Complex) -> Complex {
  Complex::new(
    self.re * other.re - self.im * other.im,
    self.re * other.im + self.im * other.re,
  )
}

///|
pub impl @lg.Add for Complex with op_add(self : Complex, other : Complex) -> Complex {
  Complex::new(self.re + other.re, self.im + other.im)
}

///|
pub impl @lg.Neg for Complex with op_neg(self : Complex) -> Complex {
  Complex::new(-self.re, -self.im)
}

///|
pub impl @lg.Inverse for Complex with inv(self : Complex) -> Complex {
  let s = 1.0 / self.abs_sqr()
  Complex::new(self.re * s, -self.im * s)
}

///|
pub impl @lg.One for Complex with one() -> Complex {
  Complex::new(1.0, 0.0)
}

///|
pub impl @lg.Zero for Complex with zero() -> Complex {
  Complex::new(0.0, 0.0)
}

///|
pub impl @lg.Conjugate for Complex with conjugate(self : Complex) -> Complex {
  Complex::new(self.re, -self.im)
}

///|
pub impl @lg.Sub for Complex with op_sub(self : Complex, other : Complex) -> Complex {
  Complex::new(self.re - other.re, self.im - other.im)
}
