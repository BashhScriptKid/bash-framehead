# `pfloat`

Pure Bash floating-point arithmetic — two independent implementations: **fixed-point** (`pfloat::fixed::`) using scaled integers, and **IEEE 754 double-precision** (`pfloat::ieee754::`) using 64-bit bit patterns. Backward-compatibility wrappers (`pfloat::`) alias to fixed-point. **129 functions total.**

---

## Concepts

### Fixed-Point (`pfloat::fixed::`)

Decimal numbers are stored as scaled integers. The global `pfloat_SCALE` (default: 5) determines how many decimal places are preserved internally. All arithmetic is pure Bash integer math — no `bc` required.

```bash
# Set precision before use
pfloat_SCALE=5

pfloat::fixed::add "3.14" "2.86"     # → 6.00000
pfloat::fixed::mul "1.5" "2.0"       # → 3.00000
```

### IEEE 754 (`pfloat::ieee754::`)

Double-precision floating-point using binary64 bit patterns. Each value is a 64-bit integer representing the IEEE 754 encoding. Operations follow the IEEE 754 standard (rounding, subnormals, NaN, Inf). Uses `bc` for large-number arithmetic.

```bash
bits_a=$(pfloat::ieee754::from_string "3.14")
bits_b=$(pfloat::ieee754::from_string "2.0")
result=$(pfloat::ieee754::mul "$bits_a" "$bits_b")
pfloat::ieee754::to_string "$result"   # → 6.28

# Inspect the bit layout
pfloat::ieee754::dump "$bits_a"
```

---

## Fixed-Point Arithmetic

All functions output scaled decimal strings. Integer arithmetic is pure Bash — no external tools needed.

### Basic Operations

| Function | Description |
|----------|-------------|
| `pfloat::fixed::add` | Addition |
| `pfloat::fixed::sub` | Subtraction |
| `pfloat::fixed::mul` | Multiplication (with overflow-protection fast path for integers) |
| `pfloat::fixed::div` | Division (error on division by zero) |
| `pfloat::fixed::mod` | Modulo |
| `pfloat::fixed::neg` | Negation |
| `pfloat::fixed::abs` | Absolute value |
| `pfloat::fixed::sqr` | Square (delegates to `mul`) |

### Comparison

| Function | Description |
|----------|-------------|
| `pfloat::fixed::eq` | Equal to |
| `pfloat::fixed::ne` | Not equal to |
| `pfloat::fixed::lt` | Less than |
| `pfloat::fixed::le` | Less than or equal |
| `pfloat::fixed::gt` | Greater than |
| `pfloat::fixed::ge` | Greater than or equal |
| `pfloat::fixed::is_zero` | Check if zero |
| `pfloat::fixed::is_positive` | Check if positive |
| `pfloat::fixed::is_negative` | Check if negative |

### Rounding

| Function | Description |
|----------|-------------|
| `pfloat::fixed::floor` | Floor — largest integer ≤ n |
| `pfloat::fixed::ceil` | Ceiling — smallest integer ≥ n |
| `pfloat::fixed::round` | Round to nearest integer |
| `pfloat::fixed::trunc` | Truncate toward zero |

### Power & Root

| Function | Description |
|----------|-------------|
| `pfloat::fixed::sqrt` | Square root (Newton-Raphson iteration) |
| `pfloat::fixed::pow` | Power (exponentiation by squaring, supports negative exponents) |
| `pfloat::fixed::cbrt` | Cube root (Newton-Raphson) |

### Min/Max/Clamp

| Function | Description |
|----------|-------------|
| `pfloat::fixed::min` | Minimum of two values |
| `pfloat::fixed::max` | Maximum of two values |
| `pfloat::fixed::clamp` | Clamp n between min and max |

### Interpolation & Mapping

| Function | Description |
|----------|-------------|
| `pfloat::fixed::lerp` | Linear interpolation: `a + t*(b-a)` |
| `pfloat::fixed::inv_lerp` | Inverse lerp: `(v-a)/(b-a)` |
| `pfloat::fixed::map` | Map v from range `[imin, imax]` to `[omin, omax]` |
| `pfloat::fixed::normalize` | Normalise to 0–1 range |

### Statistics

| Function | Description |
|----------|-------------|
| `pfloat::fixed::sum` | Sum of all arguments |
| `pfloat::fixed::avg` | Arithmetic mean |
| `pfloat::fixed::mean` | Mean of two values |
| `pfloat::fixed::geomean` | Geometric mean: `sqrt(a*b)` |
| `pfloat::fixed::harmean` | Harmonic mean: `2*a*b/(a+b)` |

### Percentage

| Function | Description |
|----------|-------------|
| `pfloat::fixed::percent` | `(part/total)*100` |
| `pfloat::fixed::percent_of` | `total*(pct/100)` |
| `pfloat::fixed::percent_change` | `((new-old)/old)*100` |

### Distance

| Function | Description |
|----------|-------------|
| `pfloat::fixed::dist2` | Euclidean distance between two 2D points |
| `pfloat::fixed::dist3` | Euclidean distance between two 3D points |

### Misc

| Function | Description |
|----------|-------------|
| `pfloat::fixed::sign` | Sign: -1, 0, or 1 |
| `pfloat::fixed::recip` | Reciprocal: `1/n` |
| `pfloat::fixed::factorial` | Factorial (truncates input) |
| `pfloat::fixed::sigmoid` | Logistic sigmoid: `1/(1+e^(-x))` |
| `pfloat::fixed::softplus` | Softplus: `ln(1+e^x)` |

---

## IEEE 754 Operations

All IEEE 754 functions operate on 64-bit integer representations of binary64 values.

### Conversion

| Function | Description |
|----------|-------------|
| `pfloat::ieee754::from_string` | Convert decimal string to IEEE 754 bits |
| `pfloat::ieee754::to_string` | Convert IEEE 754 bits to decimal string |
| `pfloat::ieee754::from_int` | Convert raw 64-bit integer to bits (identity) |
| `pfloat::ieee754::to_int` | Convert bits to raw 64-bit integer (identity) |
| `pfloat::ieee754::from_binary` | Convert binary string to bits (flat 64-char or 3-arg sign/exp/mant) |
| `pfloat::ieee754::to_binary` | Convert bits to binary string (optional separator) |

### Arithmetic

| Function | Description |
|----------|-------------|
| `pfloat::ieee754::add` | Addition (handles NaN, Inf, subnormals) |
| `pfloat::ieee754::sub` | Subtraction (uses addition with negated operand) |
| `pfloat::ieee754::mul` | Multiplication (chunked 26-bit to avoid overflow) |
| `pfloat::ieee754::div` | Division |
| `pfloat::ieee754::sqrt` | Square root (Newton-Raphson) |

### Comparison

| Function | Description |
|----------|-------------|
| `pfloat::ieee754::eq` | Equal to (handles signed zero) |
| `pfloat::ieee754::ne` | Not equal to |
| `pfloat::ieee754::lt` | Less than |
| `pfloat::ieee754::le` | Less than or equal |
| `pfloat::ieee754::gt` | Greater than |
| `pfloat::ieee754::ge` | Greater than or equal |

### Classification

| Function | Description |
|----------|-------------|
| `pfloat::ieee754::is_nan` | Check if NaN |
| `pfloat::ieee754::is_inf` | Check if Infinity |
| `pfloat::ieee754::is_finite` | Check if finite |
| `pfloat::ieee754::is_zero` | Check if zero |
| `pfloat::ieee754::is_positive` | Check if positive (strict) |
| `pfloat::ieee754::is_negative` | Check if negative |

### Unary

| Function | Description |
|----------|-------------|
| `pfloat::ieee754::neg` | Negation (flip sign bit) |
| `pfloat::ieee754::abs` | Absolute value (clear sign bit) |
| `pfloat::ieee754::sign` | Sign: -1, 0, or 1 |

### Diagnostics

| Function | Description |
|----------|-------------|
| `pfloat::ieee754::dump` | Print full bit breakdown: sign, exponent (binary), mantissa (binary), decimal value |

---

## Backward Compatibility

Short-form wrappers (`pfloat::add`, `pfloat::sqrt`, etc.) delegate to their `pfloat::fixed::` counterparts. All 39 wrappers mirror the fixed-point API exactly.

```bash
# Both are equivalent:
pfloat::add "1.5" "2.5"           # backward-compat wrapper
pfloat::fixed::add "1.5" "2.5"    # canonical form
```

## Configuration

```bash
# Set fixed-point precision (number of decimal digits)
pfloat_SCALE=8
```

Higher scale = more precision but larger intermediate integers (risk of overflow at very high scales).

## Dependencies

- **Requires**: `runtime`
- **External tools**: None for fixed-point; `bc` for some IEEE 754 conversion steps and `pfloat::ieee754::div`
