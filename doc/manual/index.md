# luna-complex

`Luna-Flow/luna-complex` provides complex numbers for Luna Flow. The root
package defines the generic type `Complex[T]`, the ring $T[i]/(i^2 + 1)$
over any scalar `T`, with its arithmetic and `luna-generic` structure
instances. The `float_backend` package adds the analytic functions of
`Complex[Double]` (roots, logarithms, powers, trigonometric and hyperbolic
functions and their inverses) with numerically stable formulas, and the
capability traits for floating-point scalars.

This manual documents the code of version `0.2.0` (the version in
`moon.mod`) on MoonBit 0.10.

## Packages

| Package | Import path | Role | Pages |
| --- | --- | --- | --- |
| `core` | `Luna-Flow/luna-complex` | generic `Complex[T]`: construction, mutation, arithmetic, conjugation, structure instances | [API](api/core.md) · [tutorial](tutorial/core.md) · [design](design/core.md) |
| `float_backend` | `Luna-Flow/luna-complex/float_backend` | analytic functions of `Complex[Double]`; `FloatingAnalyticScalar`, `FloatingSpecialValues`, `FloatingBackendScalar` | [API](api/float_backend.md) · [tutorial](tutorial/float_backend.md) · [design](design/float_backend.md) |

The root package is documented under the name `core`. `float_backend`
replaces the former `double_ext` package.

## Reading paths

**First steps.** Read the [core tutorial](tutorial/core.md) for arithmetic,
then the [float_backend tutorial](tutorial/float_backend.md) for `sqrt`,
`log`, `sin` and the other functions.

**Using the library.** Keep the [core API](api/core.md) and the
[float_backend API](api/float_backend.md) at hand; the latter states the
branch, special-value and abort behaviour of every function, including the
known deviations on the negative real axis.

**Contributing.** Read the [core design](design/core.md) for the algebra
and the lawfulness of the instances, the
[float_backend design](design/float_backend.md) for the derivations of the
stable formulas and the branch cuts, and the
[contribution guide](contributing.md).

## Installation

```bash
moon add Luna-Flow/luna-complex@0.2.0
```

```moonbit nocheck
import {
  "Luna-Flow/luna-complex" @complex,
  "Luna-Flow/luna-complex/float_backend" @fb,
}
```

## Toolchain

MoonBit `moonc` 0.10 or newer with `moon.mod` / `moon.pkg` manifests. The
tests run on `wasm-gc`, `wasm`, `js` and `native`.

## Validation

```bash
moon check --target all
moon test
moon info
```
