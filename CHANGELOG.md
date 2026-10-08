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

## 0.2.0 and earlier

No changelog was kept before this file; see the git history. The version in
`moon.mod` is `0.2.0`.
