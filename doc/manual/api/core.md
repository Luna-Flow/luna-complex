# core API

## Purpose

The root package `Luna-Flow/luna-complex` defines `Complex[T]`, the complex
numbers $a + bi$ over any scalar type `T`, with construction, in-place
mutation, conjugation, the arithmetic operators and the `luna-generic`
structure traits. It contains no analytic functions; those are in
[`float_backend`](float_backend.md). The algebra behind the instances is in
the [core design](../design/core.md).

Source: [`src/complex.mbt`](../../../src/complex.mbt),
[`src/complex_traits.mbt`](../../../src/complex_traits.mbt) and
[`src/extends.mbt`](../../../src/extends.mbt).

## Importing

```moonbit nocheck
import {
  "Luna-Flow/luna-complex" @complex,
}
```

The examples use the alias `@complex`.

## The type

### `Complex`

A complex number with a real part `re` and an imaginary part `im`.

```mbti
pub(all) struct Complex[T] {
  mut re : T
  mut im : T
} derive(Eq, @debug.Debug)
```

The value is $\texttt{re} + \texttt{im}\,i$ with $i^2 = -1$. Both fields
are public and mutable, and the struct is `pub(all)`, so code outside the
package can read, write and construct it with a record literal.
`Complex[T]` is a reference type: two bindings to the same value see each
other's updates.

`derive(Eq)` compares both parts with `T`'s equality (for `Double`,
`0.0 == -0.0` and NaN is unequal to itself). `derive(Debug)` prints the
record form `{ re: …, im: … }`.

## Construction and mutation

### `Complex::new`

Builds $re + im\,i$.

```mbti
pub fn[T] Complex::new(T, T) -> Complex[T]
```

### `Complex::set`

Overwrites both parts in place.

```mbti
pub fn[T] Complex::set(Complex[T], T, T) -> Unit
```

### `Complex::set_re`

Overwrites the real part in place.

```mbti
pub fn[T] Complex::set_re(Complex[T], T) -> Unit
```

### `Complex::set_im`

Overwrites the imaginary part in place.

```mbti
pub fn[T] Complex::set_im(Complex[T], T) -> Unit
```

```moonbit
test "construct and mutate" {
  let z = @complex.Complex::new(1.0, 2.0)
  assert_eq(z.re, 1.0)
  z.set(3.0, 4.0)
  z.set_im(-1.0)
  assert_eq(z, @complex.Complex::new(3.0, -1.0))
}
```

## Identities

### `Complex::zero`

Returns $0 + 0i$.

```mbti
pub fn[T : @luna-generic.Zero] Complex::zero() -> Complex[T]
```

### `Complex::one`

Returns $1 + 0i$.

```mbti
pub fn[T : @luna-generic.One + @luna-generic.Zero] Complex::one() -> Complex[T]
```

Both are the promoted methods of the `Zero` and `One` instances.

## Arithmetic

Each operator is available as an operator and as a promoted method.

| Item | Operator | Result | Bound on `T` |
| --- | --- | --- | --- |
| `Complex::add` | `z + w` | $(a + c) + (b + d)i$ | `Add` |
| `Complex::sub` | `z - w` | $(a - c) + (b - d)i$ | `Sub` |
| `Complex::neg` | `-z` | $-a - bi$ | `Neg` |
| `Complex::mul` | `z * w` | $(ac - bd) + (ad + bc)i$ | `Mul + Add + Sub` |
| `Complex::div` | `z / w` | $\dfrac{(ac + bd) + (bc - ad)i}{c^2 + d^2}$ | `Field` |

Here $z = a + bi$ and $w = c + di$.

### `Complex::add`

Adds componentwise.

```mbti
pub fn[T : Add] Complex::add(Complex[T], Complex[T]) -> Complex[T]
pub impl[T : Add] Add for Complex[T]
```

### `Complex::sub`

Subtracts componentwise.

```mbti
pub fn[T : Sub] Complex::sub(Complex[T], Complex[T]) -> Complex[T]
pub impl[T : Sub] Sub for Complex[T]
```

### `Complex::neg`

Negates both parts.

```mbti
pub fn[T : Neg] Complex::neg(Complex[T]) -> Complex[T]
pub impl[T : Neg] Neg for Complex[T]
```

### `Complex::mul`

Multiplies with $i^2 = -1$, using four multiplications.

```mbti
pub fn[T : Mul + Add + Sub] Complex::mul(Complex[T], Complex[T]) -> Complex[T]
pub impl[T : Mul + Add + Sub] Mul for Complex[T]
```

### `Complex::div`

Divides by multiplying with the inverse of the squared modulus.

```mbti
pub fn[T : @luna-generic.Field] Complex::div(Complex[T], Complex[T]) -> Complex[T]
pub impl[T : @luna-generic.Field] Div for Complex[T]
```

It computes $n = c^2 + d^2$, then `Inverse::inv(n)`, and multiplies both
parts of $z\bar w$ by it. The formula is not scaled, so for `Double` the
result depends on the size of $|w|$:

| $\lvert w\rvert$ (about) | $n$ | Result |
| --- | --- | --- |
| above $1.3 \times 10^{154}$ | overflows to $\infty$ | $n^{-1} = 0$: zero parts, or NaN where a part of $z\bar w$ is also infinite |
| $10^{-154}$ to $10^{154}$ | in range | the quotient, up to rounding |
| $1.5 \times 10^{-162}$ to $10^{-154}$ | subnormal | inaccurate; below about $7.5 \times 10^{-155}$, $n^{-1}$ overflows and the parts become $\pm\infty$ or NaN |
| below $1.5 \times 10^{-162}$, or $w = 0$ | $0$ | **aborts** |

The abort comes from `Inverse::inv` of `Double` in `luna-generic`, which
rejects zero. For example `Complex::new(1e200, 0.0) / Complex::new(1e200,
0.0)` is NaN $+ 0i$, and dividing by $10^{-170}$ aborts. Use
[`@fb.div`](float_backend.md#div) for robust floating-point division.

```moonbit
test "complex arithmetic" {
  let z = @complex.Complex::new(1.0, 2.0)
  let w = @complex.Complex::new(3.0, -1.0)
  assert_eq(z + w, @complex.Complex::new(4.0, 1.0))
  assert_eq(z - w, @complex.Complex::new(-2.0, 3.0))
  assert_eq(z * w, @complex.Complex::new(5.0, 5.0))
  assert_eq(z * w / w, z)
  assert_eq(-z, @complex.Complex::new(-1.0, -2.0))
}
```

## Conjugate and inverse

### `Complex::conjugate`

Returns $\bar z = a - bi$.

```mbti
pub fn[T : Neg] Complex::conjugate(Complex[T]) -> Complex[T]
pub impl[T : Neg] @luna-generic.Conjugate for Complex[T]
```

### `Complex::inv`

Returns $z^{-1} = \bar z / (a^2 + b^2)$.

```mbti
pub fn[T : @luna-generic.Field] Complex::inv(Complex[T]) -> Complex[T]
pub impl[T : @luna-generic.Field] @luna-generic.Inverse for Complex[T]
```

It has the same unscaled formula, the same size ranges and the same abort
on a zero or underflowed modulus as `Complex::div`: `inv` of $10^{-160}$ is
$\infty + \mathrm{NaN}\,i$, and `inv` of $10^{-170}$ aborts.

```moonbit
test "conjugate and inverse" {
  let z = @complex.Complex::new(3.0, 4.0)
  assert_eq(z.conjugate(), @complex.Complex::new(3.0, -4.0))
  assert_eq(z * z.conjugate(), @complex.Complex::new(25.0, 0.0))
  assert_eq(z.inv(), @complex.Complex::new(0.12, -0.16))
}
```

## Equality and text

### `Complex::equal`

Compares both parts; the promoted method of the derived `Eq`. Prefer `==`.

```mbti
pub fn[T : Eq] Complex::equal(Complex[T], Complex[T]) -> Bool
```

### `Complex::to_string`

Formats $z$ as `"<re> + <im>i"` using `T`'s `Show`.

```mbti
pub fn[T : Show] Complex::to_string(Complex[T]) -> String
pub impl[T : Show] Show for Complex[T]
```

The sign of the imaginary part is printed by `T`, so $1 - 2i$ prints as
`1 + -2i`. String interpolation `"\{z}"` uses the same text.

```moonbit
test "text form" {
  inspect(@complex.Complex::new(1.5, -2.0), content="1.5 + -2i")
  debug_inspect(@complex.Complex::new(1, 2), content="{ re: 1, im: 2 }")
}
```

## Structure instances

`Complex[T]` implements the `luna-generic` structure traits under the
bounds below. The [core design](../design/core.md) derives each law.

| Instance | Bound on `T` |
| --- | --- |
| `Zero` | `Zero` |
| `One` | `One + Zero` |
| `AddMonoid` | `Add + Zero` |
| `AddGroup` | `Add + Zero + Neg + Sub` |
| `MulMonoid` | `Ring` |
| `Semiring` | `Ring` |
| `Ring` | `Ring` |
| `Inverse` | `Field` |
| `MulGroup` | `Field` |
| `Field` | `Field` |
| `Conjugate` | `Neg` |

> [!WARNING]
> `Complex[T]` is a field only when $-1$ is not a square in `T`. That holds
> for the real-number types `Float` and `Double`, but not for
> `Complex[Double]`: in `Complex[Complex[Double]]` the non-zero value
> $1 + i\,j$ (with $i$ the inner and $j$ the outer unit) has squared modulus
> $1 + i^2 = 0$, so `inv` aborts. The `Field` instance is still provided for
> every `T : Field`; see the [core design](../design/core.md#when-the-construction-is-a-field).

For `T = Double` the laws hold only up to rounding, and the field law
$z z^{-1} = 1$ for $z \ne 0$ fails outside the range of the table under
`Complex::div`: `inv` aborts for non-zero $|z| < 1.5 \times 10^{-162}$ and
returns $0$ for $|z| > 1.3 \times 10^{154}$. The
[core design](../design/core.md#floating-point-instances) derives these
limits.

```moonbit
fn[T : @lg.Field] average(a : T, b : T) -> T {
  let two = @lg.One::one() + @lg.One::one()
  (a + b) / two
}

test "generic field code accepts complex numbers" {
  let m = average(@complex.Complex::new(1.0, 2.0), @complex.Complex::new(3.0, 0.0))
  assert_eq(m, @complex.Complex::new(2.0, 1.0))
}
```

## Deprecated

These method forms come from the trait instances and are hidden from the
interface file; they warn when used outside the package.

| Deprecated method | Replacement |
| --- | --- |
| `z.not_equal(w)` | `z != w` |
| `z.output(logger)` | `z.to_string()` or `"\{z}"` |
| `z.to_repr()` | `Repr(z)` or `@debug.Debug::to_repr(z)` |
