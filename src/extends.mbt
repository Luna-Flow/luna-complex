///|
pub extend Complex with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend Complex with Eq::{not_equal}

///|
pub extend Complex with Show::{to_string}

///|
#deprecated("Use `to_string` or `\"\\{x}\"` instead", skip_current_package=true)
#doc(hidden)
pub extend Complex with Show::{output}

///|
pub extend Complex with Add::{add}

///|
pub extend Complex with Sub::{sub}

///|
pub extend Complex with Neg::{neg}

///|
pub extend Complex with Mul::{mul}

///|
pub extend Complex with Div::{div}

///|
pub extend Complex with Zero::{zero}

///|
pub extend Complex with One::{one}

///|
pub extend Complex with Conjugate::{conjugate}

///|
pub extend Complex with Inverse::{inv}

///|
#deprecated("Use `Repr(x)` or `@debug.Debug::to_repr` instead", skip_current_package=true)
#doc(hidden)
pub extend Complex with @debug.Debug::{to_repr}
