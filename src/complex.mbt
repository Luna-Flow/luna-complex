///|
/// Represents a complex number with mutable real and imaginary parts.
pub(all) struct Complex[T] {
  mut re : T
  mut im : T
} derive(Eq)

///|
pub fn[T] Complex::new(re : T, im : T) -> Complex[T] {
  Complex::{ re, im }
}

///|
pub fn[T] Complex::set(self : Complex[T], re : T, im : T) -> Unit {
  self.re = re
  self.im = im
}

///|
pub fn[T] Complex::set_re(self : Complex[T], re : T) -> Unit {
  self.re = re
}

///|
pub fn[T] Complex::set_im(self : Complex[T], im : T) -> Unit {
  self.im = im
}
