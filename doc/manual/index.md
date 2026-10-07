# luna-complex

`luna-complex` provides a generic `Complex[T]` core for algebraic complex arithmetic in LunaFlow, with floating analytic and transcendental helpers split into the `Luna-Flow/luna-complex/float_backend` backend package. This manual describes version 0.3.0.

## Packages

| Package | Source | Contents |
| --- | --- | --- |
| [`Luna-Flow/luna-complex`](api/core.md) | `src` | The generic `Complex[T]` type, its trait implementations, and basic algebraic operations. |
| [`Luna-Flow/luna-complex/float_backend`](api/float_backend.md) | `src/float_backend` | Floating backend traits plus `Complex[Double]` functions such as `polar`, `arg`, `abs`, `sqrt`, `log`, `sin`, `cos`, `asin`, `acosh`, and `atanh`. |

The root package owns generic `Complex[T]` structure, algebraic operations, and trait-driven constraints.

`Complex[T]` is a mutable struct with explicit `re` / `im` fields for in-place updates when desired. Besides `Complex::new`, it provides `set`, `set_re`, and `set_im`. Under the matching constraints on `T`, it implements the `luna-generic` algebra traits from `Zero` and `AddMonoid` up to `Ring` and `Field`, together with `Conjugate`, `Inverse`, the arithmetic operators, `Eq`, and `Show`. Because the constraints are traits rather than a fixed scalar type, values can nest, as in `Complex[Complex[Double]]`.

`float_backend` covers the elementary functions (`exp`, `log`, `log_10`, `log_b`, `pow`, `pow_real`, `sqrt`), the trigonometric and hyperbolic functions with their inverses, and real-argument variants such as `sqrt_real`, `asin_real`, and `acosh_real`. It relies on `Luna-Flow/arithmetic` for the elementary-function capability surface and keeps its floating backend traits, IEEE special-value handling, and numeric-stability logic inside the package.

Use `float_backend` when a `Complex[Double]` value needs analytic or transcendental functions.

## Quick start

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

## Design notes

The analytic functions are free functions, such as `@float_backend.log(z)` and `@float_backend.sin(z)`, not methods. MoonBit does not allow a subpackage to add methods or trait implementations to a type defined in another package, so `float_backend` cannot attach them to `Complex[T]`. Restoring method-style transcendental APIs would require moving those definitions back into the root package or introducing a different wrapper design.

The split is intentional: it keeps floating arithmetic, IEEE special values, and branch-cut behavior out of the root package's generic algebraic semantics.

## Where to go next

Each package has an API reference ([core](api/core.md), [float_backend](api/float_backend.md)), a tutorial ([core](tutorial/core.md), [float_backend](tutorial/float_backend.md)), and a design note ([core](design/core.md), [float_backend](design/float_backend.md)).

The generated interface files `src/pkg.generated.mbti` and `src/float_backend/pkg.generated.mbti` list every public signature, and the package documentation on [mooncakes.io](https://mooncakes.io/docs/Luna-Flow/luna-complex) renders them. To work on the library, read the [contribution guidelines](contributing.md).
