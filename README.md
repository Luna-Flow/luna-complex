# luna-complex

[![img](https://img.shields.io/badge/Maintainer-KCN--judu-violet)](https://github.com/KCN-judu) [![img](https://img.shields.io/badge/License-Apache%202.0-blue)](https://github.com/Luna-Flow/luna-complex/blob/main/LICENSE) ![img](https://img.shields.io/badge/State-active-success)

`luna-complex` provides complex numbers for Luna Flow. The generic
`Complex[T]` implements complex arithmetic and the `luna-generic` structure
traits over any scalar type, and the `float_backend` package adds the
analytic functions of `Complex[Double]` (roots, logarithms, powers,
trigonometric and hyperbolic functions and their inverses) with
numerically stable formulas.

## Install

```bash
moon add Luna-Flow/luna-complex@0.2.0
```

```moonbit nocheck
// moon.pkg
import {
  "Luna-Flow/luna-complex" @complex,
  "Luna-Flow/luna-complex/float_backend" @fb,
}
```

## Example

```moonbit
fn main {
  let z = @complex.Complex::new(-3.0, 4.0)
  let w = @complex.Complex::new(1.0, 2.0)
  println("z * w   = \{z * w}")
  println("|z|     = \{@fb.abs(z)}")
  println("sqrt(z) = \{@fb.sqrt(z)}")
}
```

```text
z * w   = -11 + -2i
|z|     = 5
sqrt(z) = 1 + 2i
```

## Packages

| Package | Purpose |
| --- | --- |
| `Luna-Flow/luna-complex` | generic `Complex[T]`: construction, in-place setters, arithmetic, conjugation, `Zero` … `Field` instances |
| `Luna-Flow/luna-complex/float_backend` | `Complex[Double]` analytic functions as free functions (`abs`, `arg`, `div`, `sqrt`, `exp`, `log`, `pow`, trigonometric and hyperbolic functions and inverses); capability traits `FloatingAnalyticScalar`, `FloatingSpecialValues`, `FloatingBackendScalar` |

The analytic functions are free functions such as `@fb.log(z)`, because a
package cannot add methods to a type defined in another package.

## Known issues

The `float_backend` functions have documented defects that are not fixed
yet: `arg` returns $2\pi$ on the negative real axis (so `log(-1)` is
$2\pi i$ and non-integer powers of negative reals are wrong), `acos` and
`acosh` are off by $\pi$ for some negative inputs, reciprocal functions
abort near zero, and `div` returns NaN for subnormal divisors. The
`Field` instance of `Complex[Complex[Double]]` breaks the field laws. The
[float_backend design](doc/manual/design/float_backend.md#known-deviations-from-the-principal-values)
and the [core design](doc/manual/design/core.md#when-the-construction-is-a-field)
list the details.

## Toolchain

MoonBit `moonc` 0.10 or newer, with `moon.mod` / `moon.pkg` manifests. Tests
run on `wasm-gc`, `wasm`, `js` and `native`.

## Documentation

The manual, with API, tutorial and design pages for both packages and
Chinese and Japanese translations, is published at
<https://lunaflow.cn/en/luna-complex/>. Its English source is
[`doc/manual/index.md`](doc/manual/index.md). Changes between versions are
listed in [CHANGELOG.md](CHANGELOG.md).

## Contributing

See the [contribution guide](doc/manual/contributing.md). Run
`./ready_to_pr.sh` before opening a pull request.

## License

Apache-2.0. See [LICENSE](LICENSE).
