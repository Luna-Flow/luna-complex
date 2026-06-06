# LUNA-COMPLEX

[![img](https://img.shields.io/badge/Maintainer-KCN--judu-violet)](https://github.com/KCN-judu) [![img](https://img.shields.io/badge/License-MIT-blue)](https://github.com/Luna-Flow/luna-complex/blob/main/LICENSE) ![img](https://img.shields.io/badge/State-active-success)

## v0.2.0 - Generic Core Split

`luna-complex` provides a generic `Complex[T]` core for algebraic complex arithmetic in LunaFlow, with `Double`-specific analytic and transcendental helpers split into the `Luna-Flow/luna-complex/double_ext` subpackage.

### Package Positioning

- `Complex[T]` is a mutable struct with explicit `re` / `im` fields for in-place updates when desired.
- The root package keeps only the generic core: construction, mutation, conjugation, identities, and basic arithmetic under algebraic trait constraints.
- `Luna-Flow/luna-complex/double_ext` carries the current `Complex[Double]` elementary, trigonometric, and hyperbolic implementation.
- The `double_ext` internals are now split between function-level APIs and `Double`-specific numeric-stability helpers.
- `double_ext` currently exposes free functions such as `@double_ext.log(z)` and `@double_ext.sin(z)`.
  MoonBit does not allow this subpackage to add methods to the root-package `Complex[T]` type directly.
- This split is intentional so future real-function / transcendental trait constraints can replace the `Double` extension layer cleanly.

### Current Repository State

- Source is organized into a generic core package plus a `double_ext` subpackage for `Double`-specific analytic behavior.
- `double_ext` uses `Luna-Flow/arithmetic` for the elementary-function capability surface while keeping `Double`-only stability logic local to the subpackage.
- Generic tests cover algebraic behavior, including nested values such as `Complex[Complex[Double]]`.
- `double_ext` tests cover both smoke behavior and representative stability regressions for the split-out `Double` numeric layer.
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
let w = @double_ext.polar(2.0, 0.7853981633974483)

let magnitude = @double_ext.abs(z)
let principal_log = @double_ext.log(z)
let inverse_sine = @double_ext.asin(z)
```

### Current Public Surface

- Root package `Luna-Flow/luna-complex`:
  generic `Complex[T]`, trait implementations, and basic algebraic operations.
- Subpackage `Luna-Flow/luna-complex/double_ext`:
  `Complex[Double]` helpers such as `polar`, `arg`, `abs`, `sqrt`, `log`, `sin`, `cos`, `asin`, `acosh`, `atanh`, and related functions.
- Internal numeric helpers in `double_ext` are intentionally not part of the public API surface.
- If you need method-style transcendental APIs again later, that will require moving those definitions back into the root package or introducing a different wrapper design.

### Documentation

API documentation is available at [mooncakes.io](https://mooncakes.io/docs/Luna-Flow/luna-complex).
When browsing docs, check both the root package and the `double_ext` subpackage because the analytic `Double` APIs are no longer in the root package.

Contribution guidance is available in:

- English: `doc/en_US/CONTRIBUTING.md`
- 简体中文: `doc/zh_CN/CONTRIBUTING.md`
- 日本語: `doc/ja_JP/CONTRIBUTING.md`

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
