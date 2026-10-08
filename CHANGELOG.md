# Changelog

All notable changes to `Luna-Flow/luna-complex` are recorded here. The
project uses semantic versioning.

## Unreleased

### Breaking changes

- The `Luna-Flow/luna-complex/double_ext` package is removed. Its
  `Complex[Double]` analytic functions now live in
  `Luna-Flow/luna-complex/float_backend` with the same names and
  signatures; replace the import path and the package alias.
- `float_backend` adds the capability traits `FloatingAnalyticScalar`,
  `FloatingSpecialValues` and `FloatingBackendScalar`, implemented for
  `Float` and `Double`.

### Changed

- Migrated to MoonBit 0.10: `moon.mod` declares `source = "src"` directly,
  `Complex[T]` derives `Debug` (so `assert_eq` and `debug_inspect` work),
  and trait methods are promoted explicitly in `src/extends.mbt`.
- Generic code calls trait methods in qualified form (`Zero::zero()`,
  `One::one()`, `Inverse::inv(..)`).
- Dependencies: `luna-generic` 0.3.3 and `arithmetic` 0.2.2.
- `update_deps.sh` upgrades every dependency listed in `moon.mod`.
- Tests use package-qualified names.

### Deprecated

- The implicitly promoted method forms `Complex::not_equal`,
  `Complex::output` and `Complex::to_repr`. Use `!=`, `to_string` or
  string interpolation, and `Repr(z)` / `@debug.Debug::to_repr`.

### Documentation

- Documentation rewritten (API, tutorial and design pages for both
  packages, with derivations of the stable formulas and branch cuts) with
  zh_CN and ja_JP translations.
- `.gitignore` ignores local AI agent state.
- Manual brought to the Luna Flow documentation standard: the overview has
  install, page, export and validation sections and a warning about the
  negative real axis; API pages gain purpose sections; tutorials gain task
  tables and use `test` blocks with `inspect`; design pages state their
  constraints and main decisions.
- Logic review of the manual: the core design no longer assumes a
  commutative `T` for the ring instances and derives the size limits of the
  unscaled division for `Double`; the float_backend design corrects the
  derivation of the asymptotic arcsine, the claims about Smith's division
  and C99, and the acosh cut argument, and adds the side each function
  takes on its branch cuts. Newly documented defects: `is_negative_zero` is
  true for tiny negative subnormals, `div` returns NaN for subnormal
  divisors, `exp`/`sin`/`cos`/`sinh`/`cosh` give NaN parts from
  $\infty \cdot 0$, `abs_log` loses relative accuracy near $|z| = 1$,
  `asec`/`asech` inherit the $2\pi$ defect, and the reciprocal functions
  abort or return NaN for tiny and huge moduli, not only at exact zeros.

## 0.2.0 and earlier

No changelog was kept before this file; see the git history. The version in
`moon.mod` is `0.2.0`.
