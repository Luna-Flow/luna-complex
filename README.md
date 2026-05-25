# LUNA-COMPLEX

[![img](https://img.shields.io/badge/Maintainer-KCN--judu-violet)](https://github.com/KCN-judu) [![img](https://img.shields.io/badge/License-MIT-blue)](https://github.com/Luna-Flow/luna-complex/blob/main/LICENSE) ![img](https://img.shields.io/badge/State-active-success)

## v0.1.0-alpha-4 - Governance Refresh

`luna-complex` provides a `Complex` type for double-precision complex arithmetic in LunaFlow. The package focuses on an ergonomic API for algebraic operations, logarithmic and exponential functions, trigonometric and hyperbolic functions, and their inverse counterparts.

### Package Positioning

- `Complex` is a mutable struct with explicit `re` / `im` fields for in-place updates when desired.
- Core arithmetic and transcendental APIs stay available as instance methods and standard trait implementations.
- Numerical edge cases such as magnitude scaling, branch-sensitive inverse functions, and stable logarithmic transforms are handled in the library implementation rather than delegated to callers.
- Public transcendental APIs follow principal-value conventions from standard complex analysis:
  `arg(z) ∈ (-π, π]`, `log`, `sqrt`, inverse trigonometric functions, and inverse hyperbolic functions all use their principal branches.
- Exact singularities return explicit special values:
  logarithmic divergences use signed infinities when the principal direction is determined, and genuinely undefined branch/singularity points return `NaN` components.

### Current Repository State

- Source is organized by behavior: core data model, elementary functions, trigonometric functions, hyperbolic functions, and trait implementations.
- Tests are organized by semantic area and include both regression cases and algebraic identity checks.
- The repository now uses `moon.mod` / `moon.pkg` manifests and a publish workflow that requires explicit version confirmation.

### Quick Start

```moonbit
let z = Complex::new(1.0, 2.0)
let w = Complex::polar(2.0, @lm.PI_OVER_4)

let sum = z + w
let product = z * w
let magnitude = z.abs()
let principal_log = z.log()
let inverse_sine = z.asin()
```

### Documentation

API documentation is available at [mooncakes.io](https://mooncakes.io/docs/Luna-Flow/luna-complex).

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
