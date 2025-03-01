///|
test "basic operations" {
  let a = Complex::new(1, 2)
  let b = Complex::new(3, 4)
  let b_ = Complex::new(0.5, 1)
  let c = a + b
  assert_true!(c == Complex::new(4, 6))
  let c = a - b
  assert_true!(c == Complex::new(-2, -2))
  let c = a * b
  assert_true!(c == Complex::new(-5, 10))
  let c = a / b_
  assert_true!(c == Complex::new(2, 0))
  let c = -a
  assert_true!(c == Complex::new(-1, -2))
  let c = a.conjugate()
  assert_true!(c == Complex::new(1, -2))
  let c = a.abs_sqr()
  assert_true!(c == 5)
  let c = a.abs()
  assert_true!(c == 2.23606797749979)
  let c = a.inv()
  assert_true!(c == Complex::new(0.2, -0.4))
}

///|
test "struct related" {
  let a = Complex::new(1, 2)
  let arr : Array[Double] = [1, 2, 3, 4]
  a.pack(arr, 1)
  assert_eq!(arr, [1, 2, 1, 2])
  a.pack(arr, 2)
  assert_eq!(arr, [1, 2, 1, 2, 1, 2])
}
