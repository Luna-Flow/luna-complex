# float_backend tutorial

This tutorial computes with the analytic functions of `Complex[Double]`.
You will convert between Cartesian and polar form, take roots and
logarithms, solve a quadratic equation, evaluate trigonometric functions
and their inverses, and learn where the branch cuts are. The formulas and
their numerical treatment are in the [float_backend design](../design/float_backend.md).

## Quick start

```bash
moon add Luna-Flow/luna-complex@0.2.0
```

```moonbit nocheck
import {
  "Luna-Flow/luna-complex" @complex,
  "Luna-Flow/luna-complex/float_backend" @fb,
}
```

```moonbit
fn main {
  let z = @complex.Complex::new(-3.0, 4.0)
  println("|z|     = \{@fb.abs(z)}")
  println("sqrt(z) = \{@fb.sqrt(z)}")
  println("exp(z)  = \{@fb.exp(z)}")
}
```

```text
|z|     = 5
sqrt(z) = 1 + 2i
exp(z)  = -0.032542999640154786 + -0.03767897757486585i
```

## Everyday tasks

### Polar form

```moonbit
fn main {
  let z = @complex.Complex::new(1.0, 1.0)
  let r = @fb.abs(z)
  let theta = @fb.arg(z)
  println("r = \{r}, theta = \{theta}")
  println("back: \{@fb.polar(r, theta)}")
}
```

```text
r = 1.4142135623730951, theta = 0.7853981633974483
back: 1.0000000000000002 + 1i
```

### Solve a quadratic equation

The roots of $az^2 + bz + c$ are $(-b \pm \sqrt{b^2 - 4ac})/(2a)$. With
`sqrt` and `div` the formula works for complex coefficients and negative
discriminants:

```moonbit
fn main {
  // z^2 + 2z + 5 = 0
  let a = @complex.Complex::new(1.0, 0.0)
  let b = @complex.Complex::new(2.0, 0.0)
  let c = @complex.Complex::new(5.0, 0.0)
  let four = @complex.Complex::new(4.0, 0.0)
  let two_a = a + a
  let root = @fb.sqrt(b * b - four * a * c)
  println("z1 = \{@fb.div(-b + root, two_a)}")
  println("z2 = \{@fb.div(-b - root, two_a)}")
}
```

```text
z1 = -1 + 2i
z2 = -1 + -2i
```

### Logarithms and powers

```moonbit
fn main {
  let z = @complex.Complex::new(0.0, 1.0)
  println("log(i)   = \{@fb.log(z)}")
  println("i^i      = \{@fb.pow(z, z)}")
  println("i^2      = \{@fb.pow_real(z, 2.0)}")
  println("log10(1000) = \{@fb.log_10(@complex.Complex::new(1000.0, 0.0))}")
}
```

```text
log(i)   = 0 + 1.5707963267948966i
i^i      = 0.20787957635076193 + 0i
i^2      = -1 + 0i
log10(1000) = 2.9999999999999996 + 0i
```

$i^i = e^{i \cdot i\pi/2} = e^{-\pi/2}$ is real. Integer exponents use
exact binary powering, so $i^2$ is exactly $-1$.

### Trigonometric functions and their inverses

```moonbit
fn main {
  let z = @complex.Complex::new(0.5, 0.5)
  let s = @fb.sin(z)
  println("sin(z)       = \{s}")
  println("asin(sin(z)) = \{@fb.asin(s)}")
  println("asin(2)      = \{@fb.asin_real(2.0)}")
}
```

```text
sin(z)       = 0.5406126857131534 + 0.4573041531842493i
asin(sin(z)) = 0.5 + 0.4999999999999999i
asin(2)      = 1.5707963267948966 + 1.3169578969248166i
```

`asin_real` takes a `Double` and returns a complex result outside $[-1,
1]$.

### Large arguments

The formulas are scaled, so huge or tiny inputs do not overflow:

```moonbit
fn main {
  let huge = @complex.Complex::new(1.0e300, 1.0e300)
  println("|huge|     = \{@fb.abs(huge)}")
  println("log|huge|  = \{@fb.abs_log(huge)}")
  println("tan(1+50i) = \{@fb.tan(@complex.Complex::new(1.0, 50.0))}")
  let q = @fb.div(@complex.Complex::new(1.0, 0.0), @complex.Complex::new(1.0e-300, 1.0e-300))
  println("1/(tiny)   = \{q}")
}
```

```text
|huge|     = 1.4142135623730952e+300
log|huge|  = 691.1221014884936
tan(1+50i) = 6.765311025183565e-44 + 1i
1/(tiny)   = 4.9999999999999995e+299 + -4.9999999999999995e+299i
```

## Going further

### Branch cuts

Multi-valued functions jump across their branch cuts. `sqrt` has its cut on
the negative real axis; approaching it from above and below gives roots of
opposite sign:

```moonbit
fn main {
  println(@fb.sqrt(@complex.Complex::new(-4.0, 1.0e-12)))
  println(@fb.sqrt(@complex.Complex::new(-4.0, -1.0e-12)))
  println(@fb.sqrt(@complex.Complex::new(-4.0, 0.0)))
}
```

```text
2.5e-13 + 2i
2.5e-13 + -2i
0 + 2i
```

On the cut itself the root is $+2i$. The [design](../design/float_backend.md#principal-values-of-the-other-functions)
lists the cuts of every function.

### Writing scalar-generic helpers

The capability traits let helpers state what they need from a real scalar.
For example, a function that only inspects special values asks for
`FloatingSpecialValues` and works for `Float` and `Double`:

```moonbit
fn[T : @fb.FloatingSpecialValues] finite_parts(re : T, im : T) -> Bool {
  !(@fb.FloatingSpecialValues::is_nan(re) || @fb.FloatingSpecialValues::is_inf(re) ||
  @fb.FloatingSpecialValues::is_nan(im) || @fb.FloatingSpecialValues::is_inf(im))
}

fn main {
  let z = @fb.exp(@complex.Complex::new(800.0, 1.0))
  println(finite_parts(z.re, z.im))
  println(finite_parts((1.0 : Float), (2.0 : Float)))
}
```

```text
false
true
```

## Common pitfalls

- **The negative real axis.** `arg` and `log` currently return $2\pi$
  instead of $\pi$ there (`log(-1)` is $2\pi i$), and powers of negative
  real numbers with non-integer exponents inherit that angle; `acos`,
  `acos_real`, `asec_real` and `acosh_real` are affected for negative
  inputs. See the warning in the [float_backend API](../api/float_backend.md#conventions).
- **Reciprocal functions abort at poles.** `cot(0)`, `csc(0)`,
  `asec(0)` and the like stop the program instead of returning infinity.
- **Use `@fb.div`, not `/`, for extreme values.** The core operator forms
  $c^2 + d^2$ and aborts if it underflows to zero.
- **`exp` overflows early.** `exp(z)` for $\operatorname{Re} z > 709.78$
  has infinite or NaN parts.
- **Only `Complex[Double]`.** The analytic functions do not accept
  `Complex[Float]`.

## Next steps

- The [float_backend API](../api/float_backend.md) documents every function
  and its special cases.
- The [float_backend design](../design/float_backend.md) derives the stable
  formulas and lists the known deviations.
- The [core tutorial](core.md) covers the generic arithmetic.
