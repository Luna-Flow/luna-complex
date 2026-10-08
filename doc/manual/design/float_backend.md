# float_backend design

This page derives the formulas that `float_backend` implements for
`Complex[Double]`, explains how each one avoids overflow, underflow and
cancellation, states the branch cuts and principal values, and explains why
the scalar capabilities are split into three traits.

## Design goal

Provide the elementary functions of $\mathbb C$ for `Complex[Double]` with
principal values on documented branch cuts, numerically stable formulas
over the whole `Double` range, and the IEEE special values handled where
it matters, while keeping all of this out of the generic
[core](core.md).

## Constraints

- The functions must work over the whole `Double` range: $x^2 + y^2$
  overflows for $|z| > 1.34 \times 10^{154}$ and underflows for
  $|z| < 1.5 \times 10^{-162}$, although $z$ and most results are
  representable.
- Near the branch points and the branch cuts the textbook formulas cancel
  catastrophically.
- The package cannot add methods to `Complex[T]`, which belongs to the core
  package.
- The real elementary functions come from `arithmetic` and
  `Kaida-Amethyst/math`; the package does not implement real
  transcendental functions itself.

## Main design decisions

- Free functions over `Complex[Double]`, with `_real` variants that take a
  `Double`.
- Scaled formulas for the modulus, the square root, division, the tangent
  and the inverse functions; the Hull–Fairgrieve–Tang algorithm for the
  arcsine and arccosine; Kahan's formula for the inverse hyperbolic cosine.
- Binary powering for integer exponents.
- Reciprocal functions as compositions with `Complex::inv` of the core.
- Three capability traits for the real scalar, none of which a public
  function uses yet.

## Mathematical background

### Polar form

Every $z = x + iy \ne 0$ has a polar form $z = r e^{i\theta}$ with $r = |z|
= \sqrt{x^2 + y^2}$. The angle $\theta$ is determined modulo $2\pi$; the
principal argument $\operatorname{Arg} z$ is the representative in
$(-\pi, \pi]$, which equals $\operatorname{atan2}(y, x)$ off the negative
real axis.

### The principal logarithm and its branch cut

The solutions of $e^w = z$ are $w = \ln|z| + i(\operatorname{Arg} z +
2k\pi)$. The principal logarithm takes $k = 0$:

$$
\operatorname{Log} z = \ln|z| + i\operatorname{Arg} z .
$$

$\operatorname{Arg}$ jumps by $2\pi$ across the negative real axis, so
$\operatorname{Log}$ is analytic on $\mathbb C \setminus (-\infty, 0]$ and
$(-\infty, 0]$ is its *branch cut*. All other multi-valued functions are
defined through $\operatorname{Log}$ and inherit cuts from it.[^kahan]

[^kahan]: W. Kahan, "Branch cuts for complex elementary functions, or much
ado about nothing's sign bit", in *The State of the Art in Numerical
Analysis*, Clarendon Press, 1987. It also discusses how a signed zero can
select the side of a cut.

### Principal values of the other functions

$$
\begin{aligned}
\sqrt z &= e^{\frac12 \operatorname{Log} z}, &
z^w &= e^{w \operatorname{Log} z}, \\
\operatorname{asin} z &= -i\operatorname{Log}\big(iz + \sqrt{1 - z^2}\big), &
\operatorname{acos} z &= \tfrac{\pi}{2} - \operatorname{asin} z, \\
\operatorname{atan} z &= \tfrac{i}{2}\big(\operatorname{Log}(1 - iz) - \operatorname{Log}(1 + iz)\big), &
\operatorname{asinh} z &= -i\operatorname{asin}(iz), \\
\operatorname{acosh} z &= 2\operatorname{Log}\Big(\sqrt{\tfrac{z + 1}{2}} + \sqrt{\tfrac{z - 1}{2}}\Big), &
\operatorname{atanh} z &= \tfrac12\big(\operatorname{Log}(1 + z) - \operatorname{Log}(1 - z)\big).
\end{aligned}
$$

| Function | Branch cuts | Principal range |
| --- | --- | --- |
| `log` | $(-\infty, 0]$ | $\operatorname{Im} \in (-\pi, \pi]$ |
| `sqrt` | $(-\infty, 0)$ | $\operatorname{Re} \ge 0$ |
| `pow` | $(-\infty, 0]$ in $z$ (non-integer $w$) | from $\operatorname{Log}$ |
| `asin` | $(-\infty, -1) \cup (1, \infty)$ | $\operatorname{Re} \in [-\pi/2, \pi/2]$ |
| `acos` | $(-\infty, -1) \cup (1, \infty)$ | $\operatorname{Re} \in [0, \pi]$ |
| `atan` | $i(-\infty, -1) \cup i(1, \infty)$ | $\operatorname{Re} \in [-\pi/2, \pi/2]$ |
| `asinh` | $i(-\infty, -1) \cup i(1, \infty)$ | $\operatorname{Im} \in [-\pi/2, \pi/2]$ |
| `acosh` | $(-\infty, 1)$ | $\operatorname{Re} \ge 0$, $\operatorname{Im} \in [-\pi, \pi]$ |
| `atanh` | $(-\infty, -1) \cup (1, \infty)$ | $\operatorname{Im} \in [-\pi/2, \pi/2]$ |

The reciprocal functions are compositions: $\sec z = 1/\cos z$,
$\operatorname{asec} z = \operatorname{acos}(1/z)$, and so on.

### Real and imaginary parts

The trigonometric and hyperbolic functions split by the addition theorems
with $\cos(iy) = \cosh y$ and $\sin(iy) = i\sinh y$:

$$
\begin{aligned}
\sin(x + iy) &= \sin x\cosh y + i\cos x\sinh y, &
\cos(x + iy) &= \cos x\cosh y - i\sin x\sinh y, \\
\sinh(x + iy) &= \sinh x\cos y + i\cosh x\sin y, &
\cosh(x + iy) &= \cosh x\cos y + i\sinh x\sin y .
\end{aligned}
$$

## Decisions in detail

### Three capability traits

**Problem.** The algorithms need more from the real scalar than
`luna-generic` and `arithmetic` traits, but not every scalar type has every
extra capability.

**Options.** One large "floating real" trait; no traits (hard-code
`Double`); a layered set.

**Choice.** Three traits, each a separate concern:

- `FloatingAnalyticScalar` names the algebraic and analytic capabilities
  (a `Field` with `Num`, `Compare`, constants and the real elementary
  functions and their inverses). It assumes nothing about IEEE 754, so an
  exact or interval type could satisfy it.
- `FloatingSpecialValues` names the IEEE 754 layer: NaN, signed infinities
  and the sign of zero. These have no meaning for a type without them, so
  they are not part of the analytic trait.
- `FloatingBackendScalar` combines both and adds the primitives the stable
  algorithms below use: `hypot` (modulus without overflow), `log1p`
  (logarithms near one), `trunc` and `to_int` (detecting integer exponents
  in `pow`) and `from_double` (constants).

Code can then require the smallest trait that states its needs, as Luna
Flow prefers over a single "real number" trait. All three are implemented
for `Float` and `Double`. The public functions are still written for
`Complex[Double]` and call the `Double` primitives directly; no function is
generic over the traits yet.

### Free functions

MoonBit does not allow a package to add methods or trait instances to a
type defined in another package, so the analytic functions cannot be
methods of `Complex[T]`. They are free functions, `@fb.log(z)`, and the
generic core stays free of floating-point semantics.

### Modulus without overflow

The direct $\sqrt{x^2 + y^2}$ overflows when $|x| > 1.34 \times 10^{154}$,
although $|z|$ is representable, and underflows for tiny inputs. With $m =
\max(|x|, |y|)$ and $t = \min(|x|, |y|)/m \in [0, 1]$:

$$
|z| = m\sqrt{1 + t^2}, \qquad
\ln|z| = \ln m + \tfrac12 \ln(1 + t^2), \qquad
|z|^2 = m^2\big((x/m)^2 + (y/m)^2\big).
$$

`abs` delegates to `hypot`, which uses this kind of scaling; `abs_log` uses
the second form, so $\ln|z|$ is finite for every finite non-zero $z$; and
`abs_sqr` uses the third, which only overflows when $|z|^2$ itself does.

### Stable square root

The textbook formulas

$$
\operatorname{Re}\sqrt z = \sqrt{\frac{|z| + x}{2}}, \qquad
\operatorname{Im}\sqrt z = \operatorname{sign}(y)\sqrt{\frac{|z| - x}{2}}
$$

cancel catastrophically: for $x > 0$ and $|y| \ll x$, $|z| - x$ loses all
digits, and for $x < 0$, $|z| + x$ does. The package computes only the
cancellation-free quantity

$$
w = \sqrt{\frac{|x| + |z|}{2}} =
\begin{cases}
\sqrt{|x|}\,\sqrt{\tfrac12\big(1 + \sqrt{1 + t^2}\big)}, & |x| \ge |y|,\ t = |y|/|x|, \\
\sqrt{|y|}\,\sqrt{\tfrac12\big(t + \sqrt{1 + t^2}\big)}, & |x| < |y|,\ t = |x|/|y|,
\end{cases}
$$

where the scaled forms avoid overflow, and recovers the other part from
$\operatorname{Re}\sqrt z \cdot \operatorname{Im}\sqrt z = y/2$. For $x \ge
0$ the root is $w + \frac{y}{2w}i$; indeed, with $w^2 = (x + |z|)/2$,

$$
\Big(w + \frac{y}{2w}i\Big)^2 = w^2 - \frac{y^2}{4w^2} + yi
= \frac{(x + |z|)^2 - y^2}{2(x + |z|)} + yi
= \frac{2x^2 + 2x|z|}{2(x + |z|)} + yi = x + yi .
$$

For $x < 0$ the root is $\frac{|y|}{2w} \pm wi$ with the sign of $y$, by
the same computation with $|x|$. The real part is never negative, as the
principal branch requires. On the cut, $y = -0$ is treated like $y = +0$, so
both sides map to $+\sqrt{|x|}\,i$.

### Smith's division

The textbook quotient divides by $c^2 + d^2$, with the overflow problems of
the [core design](core.md#textbook-division-in-the-generic-core). Smith's
method divides by the larger component first.[^smith] For $|c| \ge |d|$ let
$r = d/c$, so $|r| \le 1$:

$$
\frac{a + bi}{c + di}
= \frac{(a + bi)(c - di)}{c^2 + d^2}
= \frac{(a + bi)(1 - ri)}{c(1 + r^2)}
= \frac{(a + br) + (b - ar)i}{c(1 + r^2)} ,
$$

and symmetrically with $r = c/d$ when $|d| > |c|$. Only $r^2 \le 1$ is
squared, so $1 \le 1 + r^2 \le 2$ never overflows. `div` computes the
reciprocal $s = 1/c$ once and returns

$$
\frac{a s + b s r}{1 + r^2} + \frac{b s - a s r}{1 + r^2}\, i ,
$$

which avoids forming $c(1 + r^2)$, a product that could overflow for
$|c| > \Omega/2$, where $\Omega \approx 1.8 \times 10^{308}$ is the largest
finite `Double`. The reciprocal has its own limits: for
$|c| < 1/\Omega \approx 5.6 \times 10^{-309}$ it overflows to $\infty$, and
the result becomes NaN even when the quotient is finite (the
[API](../api/float_backend.md#div) gives an example); for
$|c| > 2^{1022}$ it is subnormal and loses a few bits. Dividing $a$ and $b$
by $c$ directly, instead of multiplying them by $s$, would avoid both.

If $w$ has an infinite part and $z$ has no NaN part, `div` replaces every
part of $w$ by its infinity sign ($\pm 1$, or $0$ for a finite part). A
finite numerator then gives zero parts, as C99 Annex G requires. An
infinite numerator gives the quotient of the sign patterns, so
$\infty/\infty = 1$, where C99 returns NaN.

[^smith]: R. L. Smith, "Algorithm 116: Complex division", *Communications of
the ACM* 5(8), 1962.

### Exact integer powers

$z^n$ through $e^{n\operatorname{Log} z}$ rounds the angle $n\theta$ and
the modulus $e^{n\ln|z|}$, so even $(1 + i)^2$ would not come out as
exactly $2i$. For a real integer exponent with $|n| \le 2^{31} - 1$, `pow`
and `pow_real` use binary powering instead: $O(\log |n|)$ complex
multiplications, exact for small Gaussian integers, and $z^{-n} =
(z^{-1})^n$. Other exponents use the polar form of $e^{w\operatorname{Log}
z}$: with $\ell = \ln|z|$ from `abs_log` and $\theta = \arg z$,

$$
z^w = e^{(u + iv)(\ell + i\theta)} = e^{u\ell - v\theta}\big(\cos(u\theta + v\ell) + i\sin(u\theta + v\ell)\big),
\qquad w = u + iv .
$$

At $z = 0$, $0^0 = 1$, $0^w = 0$ for real $w > 0$, and every other
exponent gives NaN.

### Overflow-free tangent

$\tan(x + iy) = \dfrac{\sin 2x + i\sinh 2y}{\cos 2x + \cosh 2y}$, using
$\cos^2 x + \sinh^2 y = \frac12(\cos 2x + \cosh 2y)$. For large $|y|$ both
$\sinh 2y$ and $\cosh 2y$ overflow while $\tan z \to \pm i$. Multiplying
numerator and denominator by $2d$ with $d = e^{-2|y|}$, and using $2d\cosh
2y = 1 + d^2$, $2d\sinh 2y = \operatorname{sign}(y)(1 - d^2)$:

$$
\tan(x + iy) = \frac{2d\sin 2x + i\operatorname{sign}(y)(1 - d^2)}{1 + d^2 + 2d\cos 2x} .
$$

`tan` uses this form for $|y| \ge 1$ and the direct form below, where it
is accurate. `tanh` applies the same derivation with the roles of $x$ and
$y$ exchanged.

### The arcsine algorithm of Hull, Fairgrieve and Tang

For $x, y \ge 0$, let $r = |z + 1|$, $s = |z - 1|$, $A = \frac{r + s}{2}
\ge 1$ and $B = x/A \le 1$. Then[^hft]

$$
\operatorname{asin} z = \arcsin B + i\ln\big(A + \sqrt{A^2 - 1}\big),
\qquad
\operatorname{acos} z = \arccos B - i\ln\big(A + \sqrt{A^2 - 1}\big),
$$

and the other quadrants follow from oddness in each part. Both formulas
lose accuracy in two regions, which the algorithm treats separately:

- When $B$ is close to $1$ ($B > 0.6417$), $\arcsin B$ is ill-conditioned.
  The real part is computed as $\arctan(x/\sqrt D)$ with a quantity $D$
  formed from $r + x + 1$ and $s \pm (1 - x)$ without subtraction.
- When $A$ is close to $1$ ($A \le 1.5$), $\ln(A + \sqrt{A^2 - 1})$
  suffers from $A^2 - 1$. The algorithm computes $A - 1$ without
  cancellation from $y^2/(r + x + 1)$ and $s \pm (1 - x)$ and uses
  $\operatorname{log1p}\big((A - 1) + \sqrt{(A - 1)(A + 1)}\big)$.

For $|x|$ or $|y|$ above $10^{150}$, where $r$ and $s$ would overflow,
`asin` uses the asymptotic form $\operatorname{asin} z \approx
\operatorname{atan2}(x, y) + i(\ln 2 + \ln|z|)$. To derive it for
$x, y \ge 0$, note that the leading terms of $iz + \sqrt{1 - z^2}$ cancel,
because $\sqrt{1 - z^2} \approx -iz$ there. Use instead

$$
\big(iz + \sqrt{1 - z^2}\big)\big(\sqrt{1 - z^2} - iz\big) = 1 - z^2 + z^2 = 1,
\qquad
iz + \sqrt{1 - z^2} = \frac{1}{\sqrt{1 - z^2} - iz} = \frac{i}{2z}\big(1 + O(|z|^{-2})\big).
$$

Then $\operatorname{Log}\frac{i}{2z} = -\ln(2|z|) + i\big(\tfrac{\pi}{2} - \arg z\big)$,
and multiplying by $-i$ gives

$$
\operatorname{asin} z = \Big(\frac{\pi}{2} - \arg z\Big) + i\ln(2|z|) + O(|z|^{-2})
= \operatorname{atan2}(x, y) + i(\ln 2 + \ln|z|) + O(|z|^{-2}),
$$

using $\pi/2 - \operatorname{atan2}(y, x) = \operatorname{atan2}(x, y)$ in
the first quadrant. For $|z| > 10^{150}$ the neglected term is below
$10^{-300}$. `acos` uses $\pi/2 - \operatorname{asin} z$ there, which gives
the principal value in every quadrant.

[^hft]: T. E. Hull, T. F. Fairgrieve and P. T. P. Tang, "Implementing the
complex arcsine and arccosine functions using exception handling", *ACM
Transactions on Mathematical Software* 23(3), 1997. The crossover values
$1.5$ and $0.6417$ are theirs.

### Arctangent and inverse hyperbolic tangent

Writing $q = (1 + iz)/(1 - iz)$ with $z = x + iy$:

$$
q = \frac{(1 - y) + ix}{(1 + y) - ix}, \qquad
|q|^2 = \frac{x^2 + (1 - y)^2}{x^2 + (1 + y)^2}, \qquad
\arg q = \operatorname{atan2}\big(2x,\ 1 - x^2 - y^2\big),
$$

and $\operatorname{atan} z = \frac{1}{2i}\operatorname{Log} q$ gives

$$
\operatorname{atan} z = \tfrac12\operatorname{atan2}(2x, 1 - x^2 - y^2) +
\tfrac{i}{4}\ln\frac{x^2 + (1 + y)^2}{x^2 + (1 - y)^2} .
$$

The ratio inside the logarithm equals $(1 + u)/(1 - u)$ with $u =
2y/(1 + |z|^2)$; for $|u| < 0.1$ the package evaluates it as
$\operatorname{log1p}(u) - \operatorname{log1p}(-u)$ to keep accuracy near
the real axis. For large $|z|$ the real part is evaluated on $x/m, y/m$
with $m = \max(|x|, |y|)$. `atanh` is the same computation with $x$ and $y$
exchanged, from $\operatorname{atanh} z = -i\operatorname{atan}(iz)$, and
switches to $\operatorname{log1p}$ when $|4x/((1 - x)^2 + y^2)| < 1/4$.

### Inverse hyperbolic cosine by Kahan's formula

`acosh` uses $2\operatorname{Log}\big(\sqrt{(z + 1)/2} + \sqrt{(z -
1)/2}\big)$, built from the stable square root. Unlike
$\operatorname{Log}(z + \sqrt{z^2 - 1})$, it has the correct cut $(-\infty, 1)$ without extra
sign adjustments. The first root has its cut on $(-\infty, -1)$ and the
second on $(-\infty, 1)$, so together they cut exactly $(-\infty, 1)$. The
logarithm adds no cut of its own: both principal roots have a non-negative
real part, so their sum $S$ has $\operatorname{Re} S \ge 0$ and never lies
on $(-\infty, 0]$ unless $S = 0$, which would need $(z + 1)/2 = (z - 1)/2 = 0$.
The identity itself follows from squaring:
$S^2 = z + 2\sqrt{(z+1)/2}\sqrt{(z-1)/2}$, so $S^2 = z + \sqrt{z^2 - 1}$
for the branch of $\sqrt{z^2 - 1}$ that this product selects, and
$2\operatorname{Log} S = \operatorname{Log} S^2$ because
$|\arg S| \le \pi/2$.

### Exact real fast paths

`sin` and `cos` return the real function for $y = 0$ exactly; `asin`,
`acos`, `asinh`, `acosh` and `atanh` dispatch real inputs to the `_real`
functions and purely imaginary inputs to the real inverse functions of $y$.
This keeps results on the real line exactly real, and the `_real`
functions also serve callers who start from a `Double`.

### Reciprocal functions through the core inverse

`sec`, `csc`, `cot`, their hyperbolic counterparts and the inverse
reciprocal functions are compositions with `Complex::inv` of the
[core](core.md#floating-point-instances). They inherit its unscaled formula
and its limits, instead of producing infinities at poles: an abort when the
modulus of the argument is below about $1.5 \times 10^{-162}$ (which in
practice happens at $0$ for `csc`, `cot`, `csch`, `coth` and the inverse
reciprocal functions), infinite or NaN parts for moduli below about
$10^{-154}$, and NaN parts for moduli above about $1.3 \times 10^{154}$. The
other poles, such as $\pi/2$ for `sec`, are not representable exactly, and
the computed $\cos$ there is about $6 \times 10^{-17}$, so `sec` returns a
large finite value. `acot` special-cases $z = 0$ to return $\pi/2$.

## Correctness and invariants

### Identities checked by the test suite

`exp(log z) = z`, `sin(asin z) = z`, `cos(acos z) = z`, `tan(atan z) = z`,
`sinh(asinh z) = z` and `tanh(atanh z) = z` at sample points in the first
quadrant, with tolerances $10^{-10}$ to $10^{-12}$; `sqrt(-3 + 4i) = 1 +
2i`; regressions for huge `asin` arguments, the `atan` cut, infinite
`atanh` and `acosh` inputs, division by infinity and $0^0$, $0^{-1}$.

### Values on the branch cuts

A function is discontinuous across its cut, so the value on the cut has to
agree with one side. With signed zeros a library can let the sign of a zero
part pick the side (C99 Annex G does). This package ignores the sign of
zero: it tests `y == 0.0` or `x == 0.0` and sends exact real or imaginary
inputs to fast paths. The value on each cut therefore matches one fixed
side, measured by comparing $f(p)$ with $f(p \pm 10^{-9} i)$ (real-axis
cuts) or $f(p \pm 10^{-9})$ (imaginary-axis cuts):

| Function | Cut | Value on the cut matches |
| --- | --- | --- |
| `sqrt` | $x < 0$ | the upper side ($y > 0$) |
| `asin`, `acos` | $x > 1$ and $x < -1$ | the upper side |
| `atanh` | $x > 1$ and $x < -1$ | the upper side |
| `acosh` | $-1 \le x < 1$ | the upper side |
| `atan`, `asinh` | $y > 1$ | the right side ($x > 0$) |
| `atan`, `asinh` | $y < -1$ | the left side ($x < 0$) |
| `log`, `pow`, `acosh` | $x < 0$, resp. $x < -1$ for `acosh` | neither side (the $2\pi$ defect below) |

The real-axis cuts thus behave like C99 with $y = +0$. On the
imaginary-axis cuts `atan` and `asinh` attach the upper cut to the right
half-plane and the lower cut to the left one. That keeps them odd on the
cuts ($f(-z) = -f(z)$), but differs from C99 with $x = +0$ on the lower
cut: C99 gives `casinh(+0 - 2i)` $= 1.317 - i\pi/2$, this package
$-1.317 - i\pi/2$.

### Known deviations from the principal values

The implementation uses the constant $2\pi$ (`tau`) in places where the
principal value needs $\pi$:

| Function and input | Returned | Principal value |
| --- | --- | --- |
| `arg(z)`, $y = \pm 0$, $x < 0$ | $2\pi$ | $\pi$ (C99: $\pm\pi$ by the sign of $y$) |
| `log(z)`, same inputs | $\ln\lvert x\rvert  + 2\pi i$ | $\ln\lvert x\rvert  + \pi i$ |
| `pow`, `pow_real`, negative real base, non-integer exponent | angle $2\pi$ | angle $\pi$ |
| `acos(z)`, $x < 0$, $y \ne 0$ | $2\pi - \rho + \dots$ | $\pi - \rho + \dots$ |
| `acos_real(x)`, $x < -1$ | $2\pi - i\operatorname{acosh}\lvert x\rvert $ | $\pi - i\operatorname{acosh}\lvert x\rvert $ |
| `asec_real(x)`, $-1 < x < 0$ | $2\pi - i\operatorname{acosh}\lvert 1/x\rvert $ | $\pi - i\operatorname{acosh}\lvert 1/x\rvert $ |
| `acosh_real(x)` and `acosh(x + 0i)`, $x < -1$ | $\operatorname{acosh}\lvert x\rvert  + 2\pi i$ | $\operatorname{acosh}\lvert x\rvert  + \pi i$ |
| `asec(z)`, $\operatorname{Re} z < 0$ except real $z \le -1$ | through `acos`: real part $+\pi$ | principal |
| `asech(x + 0i)`, $-1 < x < 0$ | $\operatorname{acosh}\lvert 1/x\rvert + 2\pi i$ | $\operatorname{acosh}\lvert 1/x\rvert + \pi i$ |
| `log_10`, `log_b` | through `log` | principal |

Because $e^{2\pi i} = 1$ while $e^{\pi i} = -1$, these values are not even
logarithms or inverses of the input: `exp(log(-1))` is $1$, and
`cos(acos(z))` is $-z$ for $x < 0$. For powers the error is a rotation by
$e^{i\pi w}$: $(-4)^{1/2}$ comes out as $2e^{i\pi} = -2$ instead of $2i$, and
$(-8)^{1/3}$ as $2e^{2\pi i/3} = -1 + 1.732i$ instead of $1 + 1.732i$. Only
the mid-range branch of `acos` is affected: for a part above $10^{150}$,
`acos` uses $\pi/2 - \operatorname{asin} z$ and returns the principal
value, so its real part jumps by $\pi$ at that threshold. The test suite
currently asserts the $2\pi$ value of `arg` on the negative axis. These are
defects to be fixed in the implementation; this manual records the current
behaviour.

### Other accuracy notes

- `asin` evaluates $\sqrt{A^2 - 1}$ in its $A \le 1.5$ branch where the
  Hull–Fairgrieve–Tang algorithm (and `acos` here) uses $\sqrt{(A - 1)(A +
  1)}$. Close to the branch points $\pm1$ this loses digits: at $1 +
  10^{-10}i$ the imaginary part has a relative error near $4 \times
  10^{-8}$.
- `exp` overflows in $e^x$ before multiplying by $\cos y$ and $\sin y$, so
  `exp(710 + 0i)` has a NaN imaginary part ($\infty \cdot 0$). `sin`,
  `cos`, `sinh` and `cosh` have the same product structure: `sin(800i)` has
  a NaN real part, `cosh(800 + 0i)` and `sinh(800 + 0i)` a NaN imaginary
  part. Testing for an exactly zero factor before multiplying would give the
  C99 values.
- `abs_log` evaluates $\tfrac12\ln(1 + t^2)$ with `ln`, not `log1p`. For
  $t^2$ below the unit roundoff, $1 + t^2$ rounds to $1$ and the term
  vanishes, so the relative error of $\ln|z|$ is large when $|z|$ is close
  to $1$: `abs_log(1 + 1e-10i)` is $0$ instead of $5 \times 10^{-21}$. The
  absolute error stays below about $10^{-16}$.
- `div` multiplies by $1/c$, which overflows for a subnormal $c$; see
  [Smith's division](#smiths-division).
- The trait method `FloatingSpecialValues::is_negative_zero` is
  `is_neg_inf(1.0 / x)` without a test for zero, so it is also true for
  negative subnormal numbers whose reciprocal overflows. The package's own
  functions use a private helper that tests `x == 0.0` first.
- The `Float` instance of `log1p` is $\ln(1 + x)$, which loses relative
  accuracy for $|x| \ll 1$ and returns $0$ below about $6 \times 10^{-8}$;
  no public function uses it yet.
- `asec_real` and `acsc_real` have no NaN check, so a NaN argument gives a
  finite real part ($2\pi$, resp. $-\pi/2$) with a NaN imaginary part.

## Alternatives rejected

- **Methods on `Complex`.** Not possible from a separate package, and
  moving the functions into the core would bring IEEE semantics into the
  generic type.
- **A single floating-real trait.** It would force IEEE special values on
  every analytic scalar.
- **Textbook formulas everywhere.** Simpler, but they overflow for
  $|z| \gtrsim 10^{154}$ and cancel near the branch cuts, as derived above.
- **Full C99 Annex G special-value tables.** Only the cases listed in the
  API are handled; the remaining infinities and NaN propagate through
  ordinary arithmetic.

## Boundaries

- Analytic functions for `Complex[Double]` only; no `Complex[Float]`
  functions, although the traits are implemented for `Float`.
- No signed-zero selection of the side of a branch cut; `arg` also returns
  the same value for $y = +0$ and $y = -0$.
- Reciprocal functions abort at poles instead of returning infinities.
- No error bounds are certified; accuracy is checked by regression tests.
- No checked or contextual (`Result`) variants.
