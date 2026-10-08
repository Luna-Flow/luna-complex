# Contribution guidelines

This guide collects the rules for changing `luna-complex`. Run
`./ready_to_pr.sh` before opening a pull request.

## Code style

- Format all code with `moon fmt`.
- Prefer the shared `using` imports in `src/alias.mbt` and
  `src/float_backend/alias.mbt` over repeated fully qualified calls.
- Keep comments short and technical. Comments explain numerical stability
  choices, branch selection or non-obvious contracts; they do not restate
  the code.
- Promote trait methods explicitly in `src/extends.mbt`; deprecated method
  forms stay there with `#deprecated` and `#doc(hidden)`.

## Naming

- Bindings and functions: lowercase with underscores, such as `pow_real`.
- Types and traits: PascalCase, such as `Complex` or
  `FloatingBackendScalar`.
- Files: lowercase with underscores, named after the behaviour they own.
  Avoid catch-all files such as `utils.mbt`.

## Package boundaries

- The root package owns the generic `Complex[T]`: construction, mutation,
  algebraic operations and `luna-generic` instances. It contains no
  floating-point semantics.
- `src/float_backend` owns the floating-point capability traits and the
  analytic functions. Under current MoonBit rules a package cannot add
  methods or trait instances to a type of another package, so these are
  free functions.
- Add an instance to `Complex[T]` only when the construction satisfies its
  laws under the stated bound; see the [core design](design/core.md).
- Keep public API changes deliberate; internal helpers stay private.

## Numerical changes

- State the formula and the reason for any rescaling or special case in
  the [float_backend design](design/float_backend.md), and the observable
  branch and special-value behaviour in the
  [float_backend API](api/float_backend.md).
- Add regression tests for every changed numerical behaviour: identities
  such as `exp(log z) = z`, values on and near branch cuts, huge and tiny
  inputs, and special values.

## Testing

- Black-box tests live in `*_test.mbt` next to the code and use qualified
  names such as `@luna-complex.Complex::new`.
- Run `moon test` on all targets you change behaviour for, and
  `moon test --enable-coverage` before submitting.
- Regenerate `pkg.generated.mbti` with `moon info` whenever the public API
  changes, and review its diff.

## Documentation

- The manual lives in `doc/manual`. After changing English pages, run
  `lunadoc update` and update the Chinese and Japanese catalogs in
  `doc/locale`.
- Code examples in the manual must compile against the current code.

## Commits and releases

- Use English Conventional Commits, such as
  `fix(float_backend): use pi on the negative real axis`.
- Keep each commit focused on one logical change.
- Before publishing, update the version in `moon.mod`, update `README.md`
  and `CHANGELOG.md`, run `moon check` and `moon test --enable-coverage`,
  and trigger the publish workflow with the exact version from `moon.mod`.
- If you are not a maintainer, ask before changing dependency or version
  declarations in `moon.mod`.
