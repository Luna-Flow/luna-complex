# float_backend tutorial

This tutorial computes with the analytic functions of `Complex[Double]`.
You will convert between Cartesian and polar form, take roots and
logarithms, solve a quadratic equation, evaluate trigonometric functions
and their inverses, and learn where the branch cuts are. The formulas and
their numerical treatment are in the [float_backend design](../design/float_backend.md).
Every example is a test that you can paste into a `_test.mbt` file and run
with `moon test`; the expected output is written in the `inspect` calls.

| I want to | Use |
| --- | --- |
| get the modulus or the angle | `@fb.abs(z)`, `@fb.arg(z)`, `@fb.polar(r, theta)` |
| divide safely, also with huge or tiny values | `@fb.div(z, w)` |
| take a square root or a logarithm | `@fb.sqrt(z)`, `@fb.log(z)`, `@fb.log_10(z)` |
| raise to a power | `@fb.pow(z, w)`, `@fb.pow_real(z, p)` |
| evaluate sine, cosine, tangent and their inverses | `@fb.sin(z)`, `@fb.asin(z)`, ... |
| start from a real number outside the real domain | `@fb.sqrt_real(x)`, `@fb.asin_real(x)`, ... |
| write helpers generic over `Float` and `Double` | `FloatingSpecialValues`, `FloatingBackendScalar` |

## Quick start

```bash
moon add Luna-Flow/luna-complex@0.3.0
```

Import both packages in the `moon.pkg` of the package that uses them:

```moonbit nocheck
import {
  "Luna-Flow/luna-complex" @complex,
  "Luna-Flow/luna-complex/float_backend" @fb,
}
```

The smallest useful program applies three functions to one number:

```moonbit
test "quick start" {
  let z = @complex.Complex::new(-3.0, 4.0)
  inspect(@fb.abs(z), content="5")
  inspect(@fb.sqrt(z), content="1 + 2i")
  inspect(@fb.exp(z), content="-0.032542999640154786 + -0.03767897757486585i")
}
```

## Everyday tasks

### Polar form

```moonbit
test "polar form" {
  let z = @complex.Complex::new(1.0, 1.0)
  let r = @fb.abs(z)
  let theta = @fb.arg(z)
  inspect(r, content="1.4142135623730951")
  inspect(theta, content="0.7853981633974483")
  inspect(@fb.polar(r, theta), content="1.0000000000000002 + 1i")
}
```

### Solve a quadratic equation

The roots of $az^2 + bz + c$ are $(-b \pm \sqrt{b^2 - 4ac})/(2a)$. With
`sqrt` and `div` the formula works for complex coefficients and negative
discriminants:

```moonbit
test "quadratic equation" {
  // z^2 + 2z + 5 = 0
  let a = @complex.Complex::new(1.0, 0.0)
  let b = @complex.Complex::new(2.0, 0.0)
  let c = @complex.Complex::new(5.0, 0.0)
  let four = @complex.Complex::new(4.0, 0.0)
  let two_a = a + a
  let root = @fb.sqrt(b * b - four * a * c)
  inspect(@fb.div(-b + root, two_a), content="-1 + 2i")
  inspect(@fb.div(-b - root, two_a), content="-1 + -2i")
}
```

### Logarithms and powers

```moonbit
test "logarithms and powers" {
  let z = @complex.Complex::new(0.0, 1.0)
  inspect(@fb.log(z), content="0 + 1.5707963267948966i")
  inspect(@fb.pow(z, z), content="0.20787957635076193 + 0i")
  inspect(@fb.pow_real(z, 2.0), content="-1 + 0i")
  inspect(@fb.log_10(@complex.Complex::new(1000.0, 0.0)), content="2.9999999999999996 + 0i")
}
```

$i^i = e^{i \cdot i\pi/2} = e^{-\pi/2}$ is real. Integer exponents use
exact binary powering, so $i^2$ is exactly $-1$.

Do not take non-integer powers of negative real numbers yet. `arg` returns
$2\pi$ instead of $\pi$ on the negative real axis, so the angle of the result
is wrong:

```moonbit
test "negative real base" {
  let minus_four = @complex.Complex::new(-4.0, 0.0)
  // the principal square root of -4 is 2i
  inspect(@fb.sqrt(minus_four), content="0 + 2i")
  // pow_real uses arg(-4) = 2 pi and gives -2 instead
  inspect(@fb.pow_real(minus_four, 0.5), content="-2 + 2.4492935982947064e-16i")
}
```

Use `sqrt` for square roots, and for other exponents compute
$|z|^p e^{i\pi p}$ yourself until the defect is fixed.

### Trigonometric functions and their inverses

```moonbit
test "trigonometric functions" {
  let z = @complex.Complex::new(0.5, 0.5)
  let s = @fb.sin(z)
  inspect(s, content="0.5406126857131534 + 0.4573041531842493i")
  inspect(@fb.asin(s), content="0.5 + 0.4999999999999999i")
  inspect(@fb.asin_real(2.0), content="1.5707963267948966 + 1.3169578969248166i")
}
```

`asin_real` takes a `Double` and returns a complex result outside $[-1,
1]$.

### Large arguments

The formulas are scaled, so huge or tiny inputs do not overflow:

```moonbit
test "large arguments" {
  let huge = @complex.Complex::new(1.0e300, 1.0e300)
  inspect(@fb.abs(huge), content="1.4142135623730952e+300")
  inspect(@fb.abs_log(huge), content="691.1221014884936")
  inspect(@fb.tan(@complex.Complex::new(1.0, 50.0)), content="6.765311025183565e-44 + 1i")
  let q = @fb.div(@complex.Complex::new(1.0, 0.0), @complex.Complex::new(1.0e-300, 1.0e-300))
  inspect(q, content="4.9999999999999995e+299 + -4.9999999999999995e+299i")
}
```

## Going further

### Branch cuts

Multi-valued functions jump across their branch cuts. `sqrt` has its cut on
the negative real axis; approaching it from above and below gives roots of
opposite sign:

```moonbit
test "branch cut of sqrt" {
  inspect(@fb.sqrt(@complex.Complex::new(-4.0, 1.0e-12)), content="2.5e-13 + 2i")
  inspect(@fb.sqrt(@complex.Complex::new(-4.0, -1.0e-12)), content="2.5e-13 + -2i")
  inspect(@fb.sqrt(@complex.Complex::new(-4.0, 0.0)), content="0 + 2i")
  inspect(@fb.sqrt(@complex.Complex::new(-4.0, -0.0)), content="0 + 2i")
}
```

On the cut itself the root is $+2i$, also for a negative zero imaginary
part: the functions do not look at the sign of a zero. The [design](../design/float_backend.md#principal-values-of-the-other-functions)
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

test "scalar-generic helper" {
  let z = @fb.exp(@complex.Complex::new(800.0, 1.0))
  inspect(finite_parts(z.re, z.im), content="false")
  inspect(finite_parts((1.0 : Float), (2.0 : Float)), content="true")
}
```

`is_negative_zero` is also true for tiny negative subnormal numbers such as
`-1.0e-310`; test `x == 0.0` first when you need exactly $-0$.

## Common pitfalls

- **The negative real axis.** `arg` and `log` currently return $2\pi$
  instead of $\pi$ there (`log(-1)` is $2\pi i$, and `exp(log(-1))` is
  $1$), and powers of negative real numbers with non-integer exponents
  inherit that angle; `acos`, `acos_real`, `asec`, `asec_real`, `acosh`,
  `acosh_real` and `asech` are affected for some negative inputs. See the
  warning in the [float_backend API](../api/float_backend.md#conventions).
- **Reciprocal functions abort near zero.** `cot(0)`, `csc(0)`,
  `asec(0)`, `pow_real(z, -2.0)` for a tiny $z$ and the like stop the
  program instead of returning infinity, because they go through the core
  `inv`.
- **Use `@fb.div`, not `/`, for extreme values.** The core operator forms
  $c^2 + d^2$ and aborts if it underflows to zero. `@fb.div` itself returns
  NaN when the divisor is a subnormal number below about
  $5.6 \times 10^{-309}$.
- **`exp` overflows early.** `exp(z)` for $\operatorname{Re} z > 709.78$
  has infinite or NaN parts; `sin`, `cos`, `sinh` and `cosh` produce NaN
  parts in the same way for arguments beyond about $710$.
- **Only `Complex[Double]`.** The analytic functions do not accept
  `Complex[Float]`.

## Next steps

- The [float_backend API](../api/float_backend.md) documents every function
  and its special cases.
- The [float_backend design](../design/float_backend.md) derives the stable
  formulas and lists the known deviations.
- The [core tutorial](core.md) covers the generic arithmetic.
