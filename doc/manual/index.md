# luna-complex

`luna-complex` provides a generic `Complex[T]` core for algebraic complex arithmetic in LunaFlow, with `Double`-specific analytic and transcendental helpers split into the `Luna-Flow/luna-complex/double_ext` subpackage. This manual describes version 0.2.0.

## Packages

| Package | Source | Contents |
| --- | --- | --- |
| `Luna-Flow/luna-complex` | `src` | The generic `Complex[T]` type, its trait implementations, and basic algebraic operations. |
| `Luna-Flow/luna-complex/double_ext` | `src/double_ext` | `Complex[Double]` functions such as `polar`, `arg`, `abs`, `sqrt`, `log`, `sin`, `cos`, `asin`, `acosh`, and `atanh`. |

The root package owns generic `Complex[T]` structure, algebraic operations, and trait-driven constraints.

`Complex[T]` is a mutable struct with explicit `re` / `im` fields for in-place updates when desired. Besides `Complex::new`, it provides `set`, `set_re`, and `set_im`. Under the matching constraints on `T`, it implements the `luna-generic` algebra traits from `Zero` and `AddMonoid` up to `Ring` and `Field`, together with `Conjugate`, `Inverse`, the arithmetic operators, `Eq`, and `Show`. Because the constraints are traits rather than a fixed scalar type, values can nest, as in `Complex[Complex[Double]]`.

`double_ext` covers the elementary functions (`exp`, `log`, `log_10`, `log_b`, `pow`, `pow_real`, `sqrt`), the trigonometric and hyperbolic functions with their inverses, and real-argument variants such as `sqrt_real`, `asin_real`, and `acosh_real`. It relies on `Luna-Flow/arithmetic` for the elementary-function capability surface and keeps the `Double`-only numeric-stability logic inside the subpackage.

Use this subsystem when you need logarithmic, trigonometric, or hyperbolic helpers specialized for `Complex[Double]`.

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
let w = @double_ext.polar(2.0, 0.7853981633974483)

let magnitude = @double_ext.abs(z)
let principal_log = @double_ext.log(z)
let inverse_sine = @double_ext.asin(z)
```

## Design notes

The analytic functions are free functions, such as `@double_ext.log(z)` and `@double_ext.sin(z)`, not methods. MoonBit does not allow a subpackage to add methods or trait implementations to a type defined in another package, so `double_ext` cannot attach them to `Complex[T]`. Restoring method-style transcendental APIs would require moving those definitions back into the root package or introducing a different wrapper design.

The split is intentional: once real-function and transcendental trait constraints exist, they can replace the `Double` extension layer without changing the generic core.

## Where to go next

The generated interface files `src/pkg.generated.mbti` and `src/double_ext/pkg.generated.mbti` list every public signature, and the package documentation on [mooncakes.io](https://mooncakes.io/docs/Luna-Flow/luna-complex) renders them. To work on the library, read the [contribution guidelines](contributing.md).
