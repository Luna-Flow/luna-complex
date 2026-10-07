# LUNA-COMPLEX

[![img](https://img.shields.io/badge/Maintainer-KCN--judu-violet)](https://github.com/KCN-judu) [![img](https://img.shields.io/badge/License-Apache%202.0-blue)](https://github.com/Luna-Flow/luna-complex/blob/main/LICENSE) ![img](https://img.shields.io/badge/State-active-success)

## v0.3.0 - Floating Backend Split

`luna-complex` provides a generic `Complex[T]` core for algebraic complex arithmetic in LunaFlow, with floating analytic and transcendental helpers split into the `Luna-Flow/luna-complex/float_backend` backend package.

### Package Positioning

- `Complex[T]` is a mutable struct with explicit `re` / `im` fields for in-place updates when desired.
- The root package keeps only the generic core: construction, mutation, conjugation, identities, and basic arithmetic under algebraic trait constraints.
- `Luna-Flow/luna-complex/float_backend` carries the current floating analytic backend, including the complete `Complex[Double]` elementary, trigonometric, and hyperbolic implementation.
- The `float_backend` internals are split between function-level APIs, backend capability traits, and numeric-stability helpers.
- `float_backend` currently exposes free functions such as `@float_backend.log(z)` and `@float_backend.sin(z)`.
  MoonBit does not allow this subpackage to add methods to the root-package `Complex[T]` type directly.
- This split keeps floating arithmetic, IEEE special values, and branch-cut behavior out of the root package's generic algebraic semantics.

### Current Repository State

- Source is organized into a generic core package plus a `float_backend` package for floating analytic behavior.
- `float_backend` uses `Luna-Flow/arithmetic` for the elementary-function capability surface and keeps floating backend traits local to the subpackage.
- Generic tests cover algebraic behavior, including nested values such as `Complex[Complex[Double]]`.
- `float_backend` tests cover both smoke behavior and representative stability regressions for the floating backend layer.
- The repository now uses `moon.mod` / `moon.pkg` manifests and a publish workflow that requires explicit version confirmation.

### Quick Start

```moonbit
using @core {type Complex}

let z : Complex[Double] = Complex::new(1.0, 2.0)
let nested : Complex[Complex[Double]] = Complex::new(z, Complex::zero())

let sum = z + Complex::one()
let product = z * z
let nested_inverse = nested.inv()
```

```moonbit
using @core {type Complex}

let z : Complex[Double] = Complex::new(1.0, 2.0)
let w = @float_backend.polar(2.0, 0.7853981633974483)

let magnitude = @float_backend.abs(z)
let principal_log = @float_backend.log(z)
let inverse_sine = @float_backend.asin(z)
```

### Current Public Surface

- Root package `Luna-Flow/luna-complex`:
  generic `Complex[T]`, trait implementations, and basic algebraic operations.
- Subpackage `Luna-Flow/luna-complex/float_backend`:
  floating backend traits plus `Complex[Double]` helpers such as `polar`, `arg`, `abs`, `sqrt`, `log`, `sin`, `cos`, `asin`, `acosh`, `atanh`, and related functions.
- Internal numeric helpers in `float_backend` are intentionally not part of the public API surface.
- If you need method-style transcendental APIs again later, that will require moving those definitions back into the root package or introducing a different wrapper design.

### Documentation

API documentation is available at [mooncakes.io](https://mooncakes.io/docs/Luna-Flow/luna-complex).
When browsing docs, check both the root package and the `float_backend` subpackage because the analytic `Double` APIs are no longer in the root package.

The manual, with Chinese and Japanese translations, is published at <https://luna-flow.github.io/en/luna-complex/>; its English source lives in [`doc/manual/`](doc/manual/index.md).
Contribution guidance is in [`doc/manual/contributing.md`](doc/manual/contributing.md).

### Development

Useful local commands:

```bash
moon fmt
moon check
moon test --enable-coverage
moon info
./ready_to_pr.sh
```

`ready_to_pr.sh` formats the code, runs checks, refreshes coverage artifacts, and regenerates `pkg.generated.mbti`.

### Release Checklist

Before publishing to mooncakes:

1. Update `moon.mod` to a new unreleased version.
2. Update `README.md` if the package summary or release notes no longer match the repository state.
3. Run `moon check` and `moon test --enable-coverage`.
4. Trigger the `publish-package` workflow and enter the exact version from `moon.mod`.

If mooncakes reports that the version already exists, bump the version before retrying.
