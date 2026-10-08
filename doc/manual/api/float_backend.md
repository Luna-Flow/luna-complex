# float_backend API

The `float_backend` package provides the analytic functions of
`Complex[Double]`: modulus and argument, division, roots, exponentials and
logarithms, powers, and the trigonometric and hyperbolic functions with
their inverses. It also defines three capability traits for floating-point
scalars, implemented for `Float` and `Double`. The derivations of the
formulas and the branch cuts are in the [float_backend design](../design/float_backend.md).

Source: [`src/float_backend/`](../../../src/float_backend/float_backend_traits.mbt)
(`float_backend_traits.mbt`, `complex_elementary.mbt`,
`complex_trigonometric.mbt`, `complex_hyperbolic.mbt`).

## Importing

```moonbit nocheck
import {
  "Luna-Flow/luna-complex/float_backend" @fb,
}
```

The examples use `@fb` for this package and `@complex` for the root
package. All functions are free functions over `Complex[Double]` (MoonBit
does not let a package add methods to a type of another package).

## Conventions

- **Principal values.** Multi-valued functions return one value of a fixed
  branch, described per function. `arg` returns values in $(-\pi, \pi]$
  except on the negative real axis (see the warning below).
- **Special values.** NaN and infinities are handled where stated
  (`div`, `atan`, `atanh`, `acosh`, `abs_log`, `pow`); elsewhere they
  propagate through ordinary `Double` arithmetic and may produce NaN parts.
- **Reciprocal functions abort at poles.** `sec`, `csc`, `cot`, `sech`,
  `csch`, `coth`, `asec`, `acsc`, `asech`, `acsch`, `acoth` and the exponent
  $-1$ of `pow` use `Complex::inv`, which aborts with
  `Double::inv: division by zero` on a zero modulus.

> [!WARNING]
> Several functions return an angle exactly $\pi$ larger than the principal
> value, because the code uses $2\pi$ where the principal value has $\pi$:
> `arg` on the negative real axis ($2\pi$ instead of $\pi$, so `log(-1)` is
> $2\pi i$ and `pow` of a negative real base uses that angle), the real part
> of `acos` for $\operatorname{Re} z < 0$ and of `acos_real` and `asec_real`
> for negative arguments, and the imaginary part of `acosh_real` for
> $x < -1$. For those inputs `cos(acos(z))` returns $-z$ and
> `cosh(acosh_real(x))` returns $-x$. The values documented below are the
> values the code returns.

## Capability traits

### `FloatingAnalyticScalar`

The algebraic and analytic capabilities an analytic backend needs from its
real scalar.

```mbti
pub(open) trait FloatingAnalyticScalar : @luna-generic.Field + @luna-generic.Num + Compare + @arithmetic.Constants + @arithmetic.Sqrt + @arithmetic.Exponential + @arithmetic.Logarithmic + @arithmetic.Trigonometric + @arithmetic.InverseTrigonometric + @arithmetic.Hyperbolic + @arithmetic.InverseHyperbolic {
}
pub impl FloatingAnalyticScalar for Float
pub impl FloatingAnalyticScalar for Double
```

It has no methods of its own: it names the composition of `luna-generic`
and `arithmetic` traits.

### `FloatingSpecialValues`

IEEE 754 special values and their tests.

```mbti
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
pub impl FloatingSpecialValues for Float
pub impl FloatingSpecialValues for Double
```

`is_negative_zero(x)` is `is_neg_inf(1.0 / x)`, so it is true exactly for
$-0$.

### `FloatingBackendScalar`

The primitives the numerically stable algorithms use, on top of the two
traits above.

```mbti
pub(open) trait FloatingBackendScalar : FloatingAnalyticScalar + FloatingSpecialValues {
  fn from_double(Double) -> Self
  fn trunc(Self) -> Self
  fn to_int(Self) -> Int
  fn hypot(Self, Self) -> Self
  fn log1p(Self) -> Self
}
pub impl FloatingBackendScalar for Float
pub impl FloatingBackendScalar for Double
```

| Method | Meaning | `Double` | `Float` |
| --- | --- | --- | --- |
| `from_double` | convert a `Double` constant | identity | `Float::from_double` |
| `trunc` | round towards zero | `Double::trunc` | `Float::trunc` |
| `to_int` | convert to `Int` | `Double::to_int` | `Float::to_int` |
| `hypot` | $\sqrt{x^2 + y^2}$ without overflow | `@math.hypot` | `@math.hypotf` |
| `log1p` | $\ln(1 + x)$ | `@math.log1p` | `ln(1.0 + x)` |

The `Float` `log1p` is the direct formula, which loses relative accuracy for
$|x| \ll 1$. No public function of this package is generic over these
traits yet; the `Complex[Double]` functions below call the `Double`
primitives directly.

```moonbit
fn[T : @fb.FloatingSpecialValues] classify(x : T) -> String {
  if @fb.FloatingSpecialValues::is_nan(x) {
    "nan"
  } else if @fb.FloatingSpecialValues::is_inf(x) {
    "inf"
  } else if @fb.FloatingSpecialValues::is_negative_zero(x) {
    "-0"
  } else {
    "finite"
  }
}

test "special values" {
  assert_eq(classify(-0.0), "-0")
  assert_eq(classify(@double.infinity), "inf")
  let nan : Float = @fb.FloatingSpecialValues::nan()
  assert_eq(classify(nan), "nan")
  assert_eq(@fb.FloatingBackendScalar::hypot(3.0, 4.0), 5.0)
}
```

## Re-exported type

### `Complex`

`@fb.Complex` is `@complex.Complex`; see the [core API](core.md).

```mbti
pub using @luna-complex {type Complex}
```

## Construction and storage

### `polar`

Builds $r e^{i\theta} = r\cos\theta + i\,r\sin\theta$.

```mbti
pub fn polar(Double, Double) -> Complex[Double]
```

No normalization is applied: a negative $r$ or any real $\theta$ is
accepted.

### `pack`

Writes $z$ into an interleaved buffer `[re0, im0, re1, im1, …]` at complex
index `offset`.

```mbti
pub fn pack(Complex[Double], Array[Double], Int) -> Unit
```

### `native_pack`

Writes a real and an imaginary part into an interleaved buffer.

```mbti
pub fn native_pack(Double, Double, Array[Double], Int) -> Unit
```

The buffer length must be even. If `offset` equals the number of complex
entries (`arr.length() / 2`), the pair is appended; otherwise it overwrites
entry `offset`. An odd length aborts with `native_pack: buffer length must
be even`, an offset outside `0..=arr.length() / 2` with `native_pack: offset
out of bounds`.

```moonbit
test "polar and packing" {
  let z = @fb.polar(2.0, 0.0)
  assert_eq(z, @complex.Complex::new(2.0, 0.0))
  let buf : Array[Double] = []
  @fb.pack(z, buf, 0)
  @fb.native_pack(3.0, 4.0, buf, 1)
  @fb.native_pack(5.0, 6.0, buf, 0)
  assert_eq(buf, [5.0, 6.0, 3.0, 4.0])
}
```

## Modulus and argument

### `abs`

Returns $|z| = \sqrt{x^2 + y^2}$ with `hypot`, without intermediate overflow
or underflow.

```mbti
pub fn abs(Complex[Double]) -> Double
```

### `abs_sqr`

Returns $|z|^2$, computed as $m^2\big((x/m)^2 + (y/m)^2\big)$ with $m =
\max(|x|, |y|)$.

```mbti
pub fn abs_sqr(Complex[Double]) -> Double
```

The scaling avoids spurious underflow of the squares; the result itself
overflows to infinity when $|z|^2$ exceeds the `Double` range. $0$ maps to
$0$.

### `abs_log`

Returns $\ln|z|$ as $\ln m + \tfrac12\ln(1 + t^2)$ with $m = \max(|x|,|y|)$
and $t = \min/\max$.

```mbti
pub fn abs_log(Complex[Double]) -> Double
```

It is finite for every finite non-zero $z$, even when $|z|$ itself would
overflow. `abs_log(0)` is $-\infty$.

### `arg`

Returns the argument $\theta$ with $z = |z| e^{i\theta}$.

```mbti
pub fn arg(Complex[Double]) -> Double
```

| Input | Result |
| --- | --- |
| $z = 0$ (either zero sign) | $0$ |
| $y = \pm 0$, $x < 0$ | $2\pi$ (see the warning above) |
| otherwise | `atan2(y, x)` $\in (-\pi, \pi)$ |

```moonbit
test "modulus and argument" {
  let z = @complex.Complex::new(3.0, 4.0)
  assert_eq(@fb.abs(z), 5.0)
  assert_eq(@fb.abs_sqr(z), 25.0)
  assert_eq(@fb.arg(@complex.Complex::new(0.0, 1.0)), @math.PI / 2.0)
  let huge = @complex.Complex::new(1.0e300, 1.0e300)
  assert_true(@fb.abs_sqr(huge).is_inf())
  assert_true(@fb.abs_log(huge) < 692.0) // ln(sqrt 2 * 1e300) is about 691.1
}
```

## Division

### `div`

Divides $z / w$ with Smith's scaling and IEEE special-value handling.

```mbti
pub fn div(Complex[Double], Complex[Double]) -> Complex[Double]
```

For finite $w$ it divides by the larger of $|c|, |d|$ first (with $r =
d/c$ when $|c| \ge |d|$):

$$
\frac{a + bi}{c + di} = \frac{(a + b r) + (b - a r)\,i}{c\,(1 + r^2)} ,
$$

so no square of $c$ or $d$ is formed. When $z$ has no NaN part and $w$ has
an infinite part, the result is computed from the signs of the infinities:
a finite $z$ gives $\pm 0$ parts, an infinite $z$ gives the quotient of the
sign patterns. Division by $0 + 0i$ produces infinities or NaN (no abort).

```moonbit
test "robust division" {
  let one = @complex.Complex::new(1.0, 0.0)
  let tiny = @complex.Complex::new(1.0e-300, 1.0e-300)
  let q = @fb.div(one, tiny)
  assert_true(q.re > 4.9e299 && q.im < -4.9e299)
  let z = @fb.div(@complex.Complex::new(1.0, 2.0), @complex.Complex::new(@double.infinity, 0.0))
  assert_eq(z.re, 0.0)
}
```

## Roots

### `sqrt`

Returns the principal square root: $\operatorname{Re}\sqrt z \ge 0$, with
the branch cut along the negative real axis.

```mbti
pub fn sqrt(Complex[Double]) -> Complex[Double]
```

It computes $w = \sqrt{(|x| + |z|)/2}$ in a scaled form and returns $w +
\frac{y}{2w} i$ for $x \ge 0$, and $\frac{|y|}{2w} \pm w\,i$ for $x < 0$
with the sign of $y$. On the cut ($y = \pm 0$, $x < 0$) the result is
$+\sqrt{|x|}\,i$ for both zero signs. `sqrt(0)` is $0$.

### `sqrt_real`

Square root of a real number as a complex number: $\sqrt x$ for $x \ge 0$,
$i\sqrt{-x}$ for $x < 0$.

```mbti
pub fn sqrt_real(Double) -> Complex[Double]
```

```moonbit
test "square roots" {
  assert_eq(@fb.sqrt(@complex.Complex::new(-3.0, 4.0)), @complex.Complex::new(1.0, 2.0))
  assert_eq(@fb.sqrt(@complex.Complex::new(-4.0, 0.0)), @complex.Complex::new(0.0, 2.0))
  assert_eq(@fb.sqrt_real(-9.0), @complex.Complex::new(0.0, 3.0))
}
```

## Exponential and logarithms

### `exp`

Returns $e^z = e^x(\cos y + i\sin y)$.

```mbti
pub fn exp(Complex[Double]) -> Complex[Double]
```

$e^x$ is computed first, so it overflows for $x > 709.78$ even when a part
of the result would be finite, and `exp(710 + 0i)` has a NaN imaginary part
($\infty \cdot 0$).

### `log`

Returns $\ln|z| + i\arg z$ with `abs_log` and `arg`.

```mbti
pub fn log(Complex[Double]) -> Complex[Double]
```

The imaginary part follows `arg`, so it is $2\pi$ on the negative real
axis. `log(0)` is $-\infty + 0i$.

### `log_10`

Returns $\log_{10} z = \log z / \ln 10$.

```mbti
pub fn log_10(Complex[Double]) -> Complex[Double]
```

### `log_b`

Returns $\log_b z = \log z / \log b$, divided with `div`.

```mbti
pub fn log_b(Complex[Double], Complex[Double]) -> Complex[Double]
```

```moonbit
test "exponential and logarithm" {
  let z = @complex.Complex::new(1.0, 2.0)
  let back = @fb.exp(@fb.log(z))
  assert_true((back.re - 1.0).abs() < 1.0e-12 && (back.im - 2.0).abs() < 1.0e-12)
  let l = @fb.log_10(@complex.Complex::new(100.0, 0.0))
  assert_true((l.re - 2.0).abs() < 1.0e-15)
}
```

## Powers

### `pow`

Returns $z^w$.

```mbti
pub fn pow(Complex[Double], Complex[Double]) -> Complex[Double]
```

The cases are tried in order:

| Case | Result |
| --- | --- |
| $z = 0$, $w = 0$ | $1$ |
| $z = 0$, $w$ real and positive | $0$ |
| $z = 0$, otherwise | NaN + NaN$i$ |
| $w = 1$ | $z$ |
| $w = -1$ | `z.inv()` (aborts if $z = 0$, which the first rows exclude) |
| $w$ real integer, $|w| \le 2^{31} - 1$ | binary powering; negative exponents invert $z$ first |
| otherwise | $e^{w\log z}$ in polar form |

The polar form computes $\rho = e^{\operatorname{Re} w \ln|z| - \operatorname{Im} w \arg z}$
and $\beta = \operatorname{Re} w \arg z + \operatorname{Im} w \ln|z|$ and
returns $\rho(\cos\beta + i\sin\beta)$.

### `pow_real`

Returns $z^p$ for a real exponent $p$, with the same zero, integer and
polar cases as `pow`.

```mbti
pub fn pow_real(Complex[Double], Double) -> Complex[Double]
```

```moonbit
test "powers" {
  let z = @complex.Complex::new(1.0, 2.0)
  assert_eq(@fb.pow_real(z, 2.0), @complex.Complex::new(-3.0, 4.0))
  let r = @fb.pow(@complex.Complex::new(0.0, 1.0), @complex.Complex::new(0.5, 0.0))
  assert_true((r.re - 0.7071067811865476).abs() < 1.0e-15)
  assert_true(@fb.pow_real(@complex.Complex::new(0.0, 0.0), -1.0).re.is_nan())
}
```

## Scalar operands

### `op_bin_re`

Applies a binary complex function with a real second operand $x + 0i$.

```mbti
pub fn op_bin_re(Complex[Double], Double, (Complex[Double], Complex[Double]) -> Complex[Double]) -> Complex[Double]
```

### `op_bin_im`

Applies a binary complex function with an imaginary second operand $0 +
yi$.

```mbti
pub fn op_bin_im(Complex[Double], Double, (Complex[Double], Complex[Double]) -> Complex[Double]) -> Complex[Double]
```

```moonbit
test "scalar operands" {
  let z = @complex.Complex::new(1.0, 2.0)
  assert_eq(@fb.op_bin_re(z, 2.0, @fb.div), @complex.Complex::new(0.5, 1.0))
  assert_eq(@fb.op_bin_im(z, 1.0, (a, b) => a * b), @complex.Complex::new(-2.0, 1.0))
}
```

## Trigonometric functions

### `sin`

Returns $\sin z = \sin x\cosh y + i\cos x\sinh y$; for $y = 0$ exactly, the
real $\sin x$.

```mbti
pub fn sin(Complex[Double]) -> Complex[Double]
```

### `cos`

Returns $\cos z = \cos x\cosh y - i\sin x\sinh y$; for $y = 0$ exactly, the
real $\cos x$.

```mbti
pub fn cos(Complex[Double]) -> Complex[Double]
```

### `tan`

Returns $\tan z$.

```mbti
pub fn tan(Complex[Double]) -> Complex[Double]
```

For $|y| < 1$ it uses $\dfrac{\sin 2x + i\sinh 2y}{2(\cos^2 x +
\sinh^2 y)}$; for $|y| \ge 1$ a form scaled by $e^{-2|y|}$ that tends to
$\pm i$ without overflow (see the design).

### `sec`

Returns $1/\cos z$; aborts where $\cos z = 0$.

```mbti
pub fn sec(Complex[Double]) -> Complex[Double]
```

### `csc`

Returns $1/\sin z$; aborts at $z = k\pi$.

```mbti
pub fn csc(Complex[Double]) -> Complex[Double]
```

### `cot`

Returns $1/\tan z$; aborts at $z = k\pi$.

```mbti
pub fn cot(Complex[Double]) -> Complex[Double]
```

```moonbit
test "trigonometric functions" {
  let z = @complex.Complex::new(1.0, 1.0)
  let s = @fb.sin(z)
  let c = @fb.cos(z)
  let one = s * s + c * c
  assert_true((one.re - 1.0).abs() < 1.0e-15 && one.im.abs() < 1.0e-15)
  let t = @fb.tan(@complex.Complex::new(1.0, 100.0))
  assert_eq(t.im, 1.0)
}
```

## Inverse trigonometric functions

### `asin`

Returns the principal arcsine, with branch cuts on the real axis outside
$[-1, 1]$; $\operatorname{Re}$ lies in $[-\pi/2, \pi/2]$.

```mbti
pub fn asin(Complex[Double]) -> Complex[Double]
```

Real inputs go to `asin_real`, purely imaginary inputs to $i\operatorname{asinh}
y$, inputs with a part above $10^{150}$ to the asymptotic form
$\operatorname{atan2}(|x|, |y|) + i(\ln 2 + \ln|z|)$, and all others to the Hull–Fairgrieve–Tang algorithm (see the
design). The result is odd in each part: the signs of $x$ and $y$ are
copied to the real and imaginary parts.

### `asin_real`

Arcsine of a real number: $\arcsin x$ for $|x| \le 1$, $\pm\pi/2 +
i\operatorname{acosh}|x|$ for $|x| > 1$ (sign of $x$), NaN for NaN.

```mbti
pub fn asin_real(Double) -> Complex[Double]
```

### `acos`

Returns the arccosine, with branch cuts on the real axis outside $[-1, 1]$.

```mbti
pub fn acos(Complex[Double]) -> Complex[Double]
```

For $x \ge 0$ the real part is the principal value in $[0, \pi/2]$ and the
imaginary part has the sign opposite to $y$. For $x < 0$ the imaginary part
is the principal one, but the real part is $2\pi - \rho$ instead of the
principal $\pi - \rho$, where $\rho \in [0, \pi/2]$ is the real part of
$\arccos(-z)$ (see the warning above). Purely imaginary inputs give $\pi/2 -
i\operatorname{asinh} y$, and real inputs go to `acos_real`.

### `acos_real`

Arccosine of a real number: $\arccos x$ for $|x| \le 1$, $-i\operatorname{acosh}
x$ for $x > 1$, and $2\pi - i\operatorname{acosh}(-x)$ for $x < -1$.

```mbti
pub fn acos_real(Double) -> Complex[Double]
```

### `atan`

Returns the principal arctangent, with branch cuts on the imaginary axis
outside $[-i, i]$.

```mbti
pub fn atan(Complex[Double]) -> Complex[Double]
```

The imaginary part is $\tfrac14\ln\frac{x^2 + (1+y)^2}{x^2 + (1-y)^2}$,
computed with `log1p` when the ratio is close to $1$; the real part is
$\tfrac12\operatorname{atan2}(2x, 1 - x^2 - y^2)$, rescaled for large
inputs. On the cut ($x = 0$, $|y| > 1$) the real part is $\pm\pi/2$ with
the sign of $y$. Infinite inputs return $\pm\pi/2 + 0i$.

### `asec`

Returns $\operatorname{acos}(1/z)$; aborts at $z = 0$.

```mbti
pub fn asec(Complex[Double]) -> Complex[Double]
```

### `asec_real`

Arcsecant of a real number: $\arccos(1/x)$ for $|x| \ge 1$,
$-i\operatorname{acosh}(1/x)$ for $0 \le x < 1$, $2\pi -
i\operatorname{acosh}(-1/x)$ for $-1 < x < 0$.

```mbti
pub fn asec_real(Double) -> Complex[Double]
```

### `acsc`

Returns $\operatorname{asin}(1/z)$; aborts at $z = 0$.

```mbti
pub fn acsc(Complex[Double]) -> Complex[Double]
```

### `acsc_real`

Arccosecant of a real number: $\arcsin(1/x)$ for $|x| \ge 1$, $\pm\pi/2 +
i\operatorname{acosh}|1/x|$ for $|x| < 1$.

```mbti
pub fn acsc_real(Double) -> Complex[Double]
```

### `acot`

Returns $\operatorname{atan}(1/z)$, and $\pi/2$ at $z = 0$.

```mbti
pub fn acot(Complex[Double]) -> Complex[Double]
```

```moonbit
test "inverse trigonometric functions" {
  let z = @complex.Complex::new(1.0, 1.0)
  let back = @fb.sin(@fb.asin(z))
  assert_true((back.re - 1.0).abs() < 1.0e-10 && (back.im - 1.0).abs() < 1.0e-10)
  assert_eq(@fb.asin_real(2.0).re, @math.PI / 2.0)
  assert_eq(@fb.acot(@complex.Complex::new(0.0, 0.0)).re, @math.PI / 2.0)
}
```

## Hyperbolic functions

### `sinh`

Returns $\sinh z = \sinh x\cos y + i\cosh x\sin y$.

```mbti
pub fn sinh(Complex[Double]) -> Complex[Double]
```

### `cosh`

Returns $\cosh z = \cosh x\cos y + i\sinh x\sin y$.

```mbti
pub fn cosh(Complex[Double]) -> Complex[Double]
```

### `tanh`

Returns $\tanh z$; for $|x| \ge 1$ a form scaled by $e^{-2|x|}$ that tends
to $\pm 1$ without overflow.

```mbti
pub fn tanh(Complex[Double]) -> Complex[Double]
```

### `sech`

Returns $1/\cosh z$; aborts where $\cosh z = 0$.

```mbti
pub fn sech(Complex[Double]) -> Complex[Double]
```

### `csch`

Returns $1/\sinh z$; aborts at $z = k\pi i$.

```mbti
pub fn csch(Complex[Double]) -> Complex[Double]
```

### `coth`

Returns $1/\tanh z$; aborts at $z = k\pi i$.

```mbti
pub fn coth(Complex[Double]) -> Complex[Double]
```

## Inverse hyperbolic functions

### `asinh`

Returns $\operatorname{asinh} z = -i\operatorname{asin}(iz)$, with branch
cuts on the imaginary axis outside $[-i, i]$.

```mbti
pub fn asinh(Complex[Double]) -> Complex[Double]
```

Real inputs use the real `asinh`; purely imaginary inputs $iy$ give $i\arcsin
y$ for $|y| \le 1$ and $\pm(\operatorname{acosh}|y| + i\pi/2)$ otherwise.

### `acosh`

Returns $\operatorname{acosh} z = 2\ln\Big(\sqrt{\tfrac{z+1}{2}} +
\sqrt{\tfrac{z-1}{2}}\Big)$, with the branch cut on the real axis below $1$.

```mbti
pub fn acosh(Complex[Double]) -> Complex[Double]
```

Real inputs go to `acosh_real`; an infinite part gives $\infty + i\arg z$.

### `acosh_real`

Inverse hyperbolic cosine of a real number: $\operatorname{acosh} x$ for $x
\ge 1$, $i\arccos x$ for $-1 \le x < 1$, $\operatorname{acosh}(-x) + 2\pi i$
for $x < -1$.

```mbti
pub fn acosh_real(Double) -> Complex[Double]
```

### `atanh`

Returns $\operatorname{atanh} z$, with branch cuts on the real axis outside
$[-1, 1]$.

```mbti
pub fn atanh(Complex[Double]) -> Complex[Double]
```

The real part is $\tfrac14\ln\frac{(1+x)^2 + y^2}{(1-x)^2 + y^2}$ (with
`log1p` near zero), the imaginary part $\tfrac12\operatorname{atan2}(2y, 1
- x^2 - y^2)$, rescaled for large inputs. Infinite inputs return $0 \pm
i\pi/2$.

### `atanh_real`

Inverse hyperbolic tangent of a real number: $\operatorname{atanh} x$ for
$|x| < 1$, $\pm\infty$ at $\pm 1$, and $\operatorname{atanh}(1/x) +
i\pi/2$ for $|x| > 1$.

```mbti
pub fn atanh_real(Double) -> Complex[Double]
```

### `asech`

Returns $\operatorname{acosh}(1/z)$; aborts at $z = 0$.

```mbti
pub fn asech(Complex[Double]) -> Complex[Double]
```

### `acsch`

Returns $\operatorname{asinh}(1/z)$; aborts at $z = 0$.

```mbti
pub fn acsch(Complex[Double]) -> Complex[Double]
```

### `acoth`

Returns $\operatorname{atanh}(1/z)$; aborts at $z = 0$.

```mbti
pub fn acoth(Complex[Double]) -> Complex[Double]
```

```moonbit
test "hyperbolic functions" {
  let z = @complex.Complex::new(0.5, 0.25)
  let back = @fb.tanh(@fb.atanh(z))
  assert_true((back.re - 0.5).abs() < 1.0e-12 && (back.im - 0.25).abs() < 1.0e-12)
  let w = @fb.sinh(@fb.asinh(@complex.Complex::new(0.0, 2.0)))
  assert_true((w.im - 2.0).abs() < 1.0e-12)
  assert_eq(@fb.atanh_real(2.0).im, @math.PI / 2.0)
}
```
