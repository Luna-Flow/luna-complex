# core tutorial

This tutorial uses the generic `Complex[T]` type for complex arithmetic. You
will build and print complex numbers, compute with them over `Double` and
over the integers, write generic code that accepts complex numbers through
the `luna-generic` traits, and update values in place. The algebra behind
it is in the [core design](../design/core.md).

## Quick start

```bash
moon add Luna-Flow/luna-complex@0.2.0
```

```moonbit nocheck
import {
  "Luna-Flow/luna-complex" @complex,
}
```

```moonbit
fn main {
  let z = @complex.Complex::new(1.0, 2.0)
  let w = @complex.Complex::new(3.0, -1.0)
  println("z + w = \{z + w}")
  println("z * w = \{z * w}")
  println("z / w = \{z / w}")
}
```

```text
z + w = 4 + 1i
z * w = 5 + 5i
z / w = 0.1 + 0.7000000000000001i
```

## Everyday tasks

### Conjugate and squared modulus

$z\bar z = |z|^2$ is real:

```moonbit
fn main {
  let z = @complex.Complex::new(3.0, 4.0)
  let n = z * z.conjugate()
  println("z * conj(z) = \{n}")
  println("1 / z = \{z.inv()}")
}
```

```text
z * conj(z) = 25 + 0i
1 / z = 0.12 + -0.16i
```

### Gaussian integers

Over `Int`, `Complex[Int]` is the ring $\mathbb Z[i]$ of Gaussian integers.
Everything except division works, and results are exact:

```moonbit
fn main {
  let a = @complex.Complex::new(2, 1)
  let b = @complex.Complex::new(2, -1)
  println("(2 + i)(2 - i) = \{a * b}")
  let mut p = @complex.Complex::one()
  for _ in 0..<4 {
    p = p * @complex.Complex::new(1, 1)
  }
  println("(1 + i)^4 = \{p}")
}
```

```text
(2 + i)(2 - i) = 5 + 0i
(1 + i)^4 = -4 + 0i
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

fn main {
  let one : @complex.Complex[Double] = @complex.Complex::one()
  let zero : @complex.Complex[Double] = @complex.Complex::zero()
  let i = @complex.Complex::new(0.0, 1.0)
  println("p(i) = \{horner([one, zero, one], i)}")
  println("p(2) = \{horner([1.0, 0.0, 1.0], 2.0)}")
}
```

```text
p(i) = 0 + 0i
p(2) = 5
```

### Update in place

`set`, `set_re` and `set_im` overwrite a value. Every binding to it sees
the change:

```moonbit
fn main {
  let acc = @complex.Complex::new(0.0, 0.0)
  let shared = acc
  for k in 1..=3 {
    let kd = k.to_double()
    acc.set(acc.re + kd, acc.im - kd)
  }
  println("acc    = \{acc}")
  println("shared = \{shared}")
}
```

```text
acc    = 6 + -6i
shared = 6 + -6i
```

## Going further

### Nested complex numbers

`Complex[T]` works for any `T` with the required traits, including
`Complex[Double]` itself:

```moonbit
fn main {
  let a = @complex.Complex::new(1.0, 2.0)
  let b = @complex.Complex::new(-0.5, 0.25)
  let z = @complex.Complex::new(a, b)
  let w = z * z.inv()
  println("z * z^-1 = (\{w.re}) + (\{w.im})j")
}
```

```text
z * z^-1 = (1.0000000000000002 + 5.204170427930421e-17i) + (0 + 0i)j
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
  zero, also when it underflows for $|w| \lesssim 10^{-162}$. Use
  `@fb.div` from `float_backend` for robust division.
- **Large values overflow in division.** $c^2 + d^2$ overflows for $|w|
  \gtrsim 10^{154}$.
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
