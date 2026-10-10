# luna-complex

This manual documents the code of `Luna-Flow/luna-complex` at version `0.2.0`
(the version in `moon.mod`) on MoonBit 0.10, including the unreleased changes
listed in [CHANGELOG.md](../../CHANGELOG.md).

## Overview

`Luna-Flow/luna-complex` provides complex numbers for Luna Flow. The root
package defines the generic type `Complex[T]`, the ring $T[i]/(i^2 + 1)$
over any scalar `T`, with its arithmetic and `luna-generic` structure
instances. The `float_backend` package adds the analytic functions of
`Complex[Double]` (roots, logarithms, powers, trigonometric and hyperbolic
functions and their inverses) with numerically stable formulas, and the
capability traits for floating-point scalars.

> [!WARNING]
> On the negative real axis `arg` returns $2\pi$ instead of $\pi$, so
> `log(-1)` is $2\pi i$, `pow_real(-4 + 0i, 0.5)` is $-2$ instead of $2i$,
> and `acos`, `acosh` and the functions built on them return values off by
> $\pi$ for some negative inputs. The
> [float_backend design](design/float_backend.md#known-deviations-from-the-principal-values)
> lists every affected case.

## Install

```bash
moon add Luna-Flow/luna-complex@0.3.0
```

Then import the packages you need in your `moon.pkg`. The examples in this
manual use these aliases:

```moonbit nocheck
import {
  "Luna-Flow/luna-complex" @complex,
  "Luna-Flow/luna-complex/float_backend" @fb,
}
```

The packages need the MoonBit toolchain 0.10 or later (`moonc` ≥ 0.10) with
`moon.mod` / `moon.pkg` manifests; the tests run on `wasm-gc`, `wasm`, `js`
and `native`. They depend on `Luna-Flow/luna-generic` 0.4.0,
`Luna-Flow/arithmetic` 0.5.0 and `Kaida-Amethyst/math`.

## Pages

The root package is documented under the name `core`. `float_backend`
replaces the former `double_ext` package.

| Part | Tutorial | API | Design |
| --- | --- | --- | --- |
| `core` (`Luna-Flow/luna-complex`): generic `Complex[T]`, arithmetic, structure instances | [tutorial](tutorial/core.md) | [API](api/core.md) | [design](design/core.md) |
| `float_backend` (`Luna-Flow/luna-complex/float_backend`): analytic functions of `Complex[Double]`, floating-point capability traits | [tutorial](tutorial/float_backend.md) | [API](api/float_backend.md) | [design](design/float_backend.md) |

The [contribution guide](contributing.md) collects the rules for changing
the code and the manual.

## Exported items

- `core`: the type `Complex[T]` with `new`, `set`, `set_re`, `set_im`,
  `zero`, `one`, `add`, `sub`, `neg`, `mul`, `div`, `conjugate`, `inv`,
  `equal` and `to_string`
- `core` instances: `Add`, `Sub`, `Neg`, `Mul`, `Div`, `Show`, and the
  `luna-generic` traits `Zero`, `One`, `AddMonoid`, `AddGroup`,
  `MulMonoid`, `Semiring`, `Ring`, `Inverse`, `MulGroup`, `Field` and
  `Conjugate`
- `float_backend` modulus and argument: `abs`, `abs_sqr`, `abs_log`, `arg`,
  `polar`
- `float_backend` arithmetic: `div`, `sqrt`, `sqrt_real`, `exp`, `log`,
  `log_10`, `log_b`, `pow`, `pow_real`, `op_bin_re`, `op_bin_im`
- `float_backend` trigonometric and hyperbolic functions: `sin`, `cos`,
  `tan`, `sec`, `csc`, `cot`, `sinh`, `cosh`, `tanh`, `sech`, `csch`,
  `coth`
- `float_backend` inverse functions: `asin`, `acos`, `atan`, `asec`, `acsc`,
  `acot`, `asinh`, `acosh`, `atanh`, `asech`, `acsch`, `acoth`, and the
  real-argument forms `asin_real`, `acos_real`, `asec_real`, `acsc_real`,
  `acosh_real`, `atanh_real`
- `float_backend` storage: `pack`, `native_pack`
- `float_backend` traits: `FloatingAnalyticScalar`, `FloatingSpecialValues`,
  `FloatingBackendScalar`, and the re-exported type `Complex`

## Where to read next

The [core tutorial](tutorial/core.md) computes with `Complex[T]`, and the
[float_backend tutorial](tutorial/float_backend.md) adds roots, logarithms
and trigonometry. The API pages state the branch, special-value and abort
behaviour of every item, and the design pages derive the algebra and the
stable formulas.

- New to the package: read the [core tutorial](tutorial/core.md), then the
  [float_backend tutorial](tutorial/float_backend.md).
- Using it in a library: keep the [core API](api/core.md) and the
  [float_backend API](api/float_backend.md) at hand; the latter states the
  branch, special-value and abort behaviour of every function, including the
  known deviations on the negative real axis.
- Contributing: read the [core design](design/core.md) for the algebra and
  the lawfulness of the instances, the
  [float_backend design](design/float_backend.md) for the derivations of the
  stable formulas and the branch cuts, and the
  [contribution guide](contributing.md).

## Validation

Recommended release checks:

```bash
moon check --target all
moon test
moon info
```
