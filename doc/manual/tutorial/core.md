# core tutorial

This tutorial uses the generic `Complex[T]` type for complex arithmetic. You
will build and print complex numbers, compute with them over `Double` and
over the integers, write generic code that accepts complex numbers through
the `luna-generic` traits, and update values in place. The algebra behind
it is in the [core design](../design/core.md). Every example is a test that
you can paste into a `_test.mbt` file and run with `moon test`; the expected
output is written in the `inspect` calls.

| I want to | Use |
| --- | --- |
| build a complex number | `@complex.Complex::new(re, im)` |
| add, subtract, multiply, divide | `+`, `-`, `*`, `/` |
| conjugate or invert | `z.conjugate()`, `z.inv()` |
| compute exactly with Gaussian integers | `Complex[Int]` or `Complex[BigInt]` |
| pass complex numbers to generic code | a `luna-generic` bound such as `T : @lg.Ring` |
| update a value in place | `z.set(re, im)`, `z.set_re(re)`, `z.set_im(im)` |
| take roots, logarithms, sines | the [float_backend](float_backend.md) package |

## Quick start

```bash
moon add Luna-Flow/luna-complex@0.2.0
```

Import the root package in the `moon.pkg` of the package that uses it. The
generic example below also uses `Luna-Flow/luna-generic` as `@lg`:

```moonbit nocheck
import {
  "Luna-Flow/luna-complex" @complex,
  "Luna-Flow/luna-generic" @lg,
}
```

The smallest useful program builds two numbers and combines them:

```moonbit
test "quick start" {
  let z = @complex.Complex::new(1.0, 2.0)
  let w = @complex.Complex::new(3.0, -1.0)
  inspect(z + w, content="4 + 1i")
  inspect(z * w, content="5 + 5i")
  inspect(z / w, content="0.1 + 0.7000000000000001i")
}
```

## Everyday tasks

### Conjugate and squared modulus

$z\bar z = |z|^2$ is real:

```moonbit
test "conjugate and modulus" {
  let z = @complex.Complex::new(3.0, 4.0)
  inspect(z * z.conjugate(), content="25 + 0i")
  inspect(z.inv(), content="0.12 + -0.16i")
}
```

### Gaussian integers

Over `Int`, `Complex[Int]` is the ring $\mathbb Z[i]$ of Gaussian integers.
Everything except division works, and results are exact:

```moonbit
test "gaussian integers" {
  let a = @complex.Complex::new(2, 1)
  let b = @complex.Complex::new(2, -1)
  inspect(a * b, content="5 + 0i")
  let mut p = @complex.Complex::one()
  for _ in 0..<4 {
    p = p * @complex.Complex::new(1, 1)
  }
  inspect(p, content="-4 + 0i")
}
```

$5 = (2 + i)(2 - i)$ shows that $5$ is not prime in $\mathbb Z[i]$.

### Generic code over a ring

Code written against `luna-generic` traits accepts complex numbers. Here a
Horner evaluation of $p(x) = x^2 + 1$:

```moonbit
fn[T : @lg.Ring] horner(coefficients : Array[T], x : T) -> T {
  let mut acc : T = @lg.Zero::zero()
  for i = coefficients.length() - 1; i >= 0; i = i - 1 {
    acc = acc * x + coefficients[i]
  }
  acc
}

test "horner" {
  let one : @complex.Complex[Double] = @complex.Complex::one()
  let zero : @complex.Complex[Double] = @complex.Complex::zero()
  let i = @complex.Complex::new(0.0, 1.0)
  inspect(horner([one, zero, one], i), content="0 + 0i")
  inspect(horner([1.0, 0.0, 1.0], 2.0), content="5")
}
```

### Update in place

`set`, `set_re` and `set_im` overwrite a value. Every binding to it sees
the change:

```moonbit
test "update in place" {
  let acc = @complex.Complex::new(0.0, 0.0)
  let shared = acc
  for k in 1..=3 {
    let kd = k.to_double()
    acc.set(acc.re + kd, acc.im - kd)
  }
  inspect(acc, content="6 + -6i")
  inspect(shared, content="6 + -6i")
}
```

## Going further

### Nested complex numbers

`Complex[T]` works for any `T` with the required traits, including
`Complex[Double]` itself:

```moonbit
test "nested complex numbers" {
  let a = @complex.Complex::new(1.0, 2.0)
  let b = @complex.Complex::new(-0.5, 0.25)
  let z = @complex.Complex::new(a, b)
  let w = z * z.inv()
  inspect(w.re, content="1.0000000000000002 + 5.204170427930421e-17i")
  inspect(w.im, content="0 + 0i")
}
```

The product is $1$ up to rounding, because the squared modulus $a^2 + b^2$
of this $z$ is invertible. In general `Complex[Complex[Double]]` is not a field; see the
pitfalls below.

### Analytic functions

The core has no `sqrt`, `exp` or `sin`. Import
`Luna-Flow/luna-complex/float_backend` for `Complex[Double]`; the
[float_backend tutorial](float_backend.md) shows how.

## Common pitfalls

- **Division by zero aborts.** `z / w` and `w.inv()` call
  `Inverse::inv` on $c^2 + d^2$; for `Double` that aborts when the value is
  zero, also when it underflows for $|w| \lesssim 10^{-162}$, and gives
  infinite or NaN parts for $|w| \lesssim 10^{-154}$. Use `@fb.div` from
  `float_backend` for robust division.
- **Large values overflow in division.** $c^2 + d^2$ overflows for $|w|
  \gtrsim 10^{154}$, and the quotient becomes zero or NaN.
- **Shared mutation.** `let shared = z` does not copy; the setters change
  every alias.
- **Text form.** Negative imaginary parts print as `+ -2i`; use
  `debug_inspect` or your own formatting when you need another form.
- **Nested types are not fields.** In `Complex[Complex[Double]]`, values
  such as $1 + i\,j$ have a zero squared modulus and `inv` aborts.

## Next steps

- The [core API](../api/core.md) lists every method and instance.
- The [core design](../design/core.md) derives the construction and the
  field condition.
- The [float_backend tutorial](float_backend.md) adds the analytic
  functions.
- [luna-generic](https://lunaflow.cn/en/luna-generic/) documents the
  traits used in generic code.
