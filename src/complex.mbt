///|
/// Represents a complex number with mutable real and imaginary parts.
pub(all) struct Complex {
  mut re : Double
  mut im : Double
} derive(Eq)

///|
pub fn Complex::new(re : Double, im : Double) -> Complex {
  Complex::{ re, im }
}

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
  offset : Int,
) -> Unit {
  if offset == arr.length() / 2 {
    arr.push(re)
    arr.push(im)
  } else {
    guard offset >= 0 && offset < arr.length() / 2
    arr[2 * offset] = re
    arr[2 * offset + 1] = im
  }
}

///|
pub fn Complex::pack(self : Complex, arr : Array[Double], offset : Int) -> Unit {
  Complex::native_pack(self.re, self.im, arr, offset)
}
