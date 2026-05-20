# `math`

Integer and floating-point arithmetic, vector operations, matrix algebra, trigonometry, combinatorics, and unit conversion. **150 functions.** Integer ops are pure Bash; floating-point delegates to `bc`. Vector and matrix types use comma-separated string representations.

---

## Setup & Utilities

| Function | Description |
|----------|-------------|
| `math::has_bc` | Check if `bc` is available |
| `math::bc` | Safe `bc` wrapper with scale support |

## Basic Arithmetic

| Function | Description |
|----------|-------------|
| `math::abs` | Absolute value (integer) |
| `math::absf` | Absolute value (float, uses `bc`) |
| `math::min` | Minimum of two integers |
| `math::minf` | Minimum of two floats |
| `math::max` | Maximum of two integers |
| `math::maxf` | Maximum of two floats |
| `math::clamp` | Clamp n between min and max (integer) |
| `math::clampf` | Clamp n between min and max (float) |
| `math::div` | Integer division (truncated toward zero) |
| `math::mod` | Modulo |
| `math::pow` | Integer exponentiation |
| `math::sum` | Sum of a sequence of integers |
| `math::sumf` | Sum of a sequence of floats |
| `math::product` | Product of a sequence of integers |
| `math::productf` | Product of a sequence of floats |

```bash
math::abs -42          # → 42
math::clamp 15 0 10    # → 10
math::pow 2 10         # → 1024
math::sum 1 2 3 4 5    # → 15
```

## Number Theory

| Function | Description |
|----------|-------------|
| `math::is_int` | Check if value is an integer |
| `math::is_even` | Check if integer is even |
| `math::is_odd` | Check if integer is odd |
| `math::is_prime` | Check if integer is prime |
| `math::is_palindrome` | Check if integer is a palindrome |
| `math::gcd` | Greatest common divisor (Euclidean algorithm) |
| `math::lcm` | Least common multiple |
| `math::factorial` | Factorial of n |
| `math::fibonacci` | nth Fibonacci term (0-indexed) |
| `math::int_sqrt` | Integer square root (floor) |
| `math::digit_sum` | Sum of digits |
| `math::digit_count` | Count number of digits |
| `math::digit_reverse` | Reverse digits of an integer |

```bash
math::gcd 48 18         # → 6
math::lcm 12 15         # → 60
math::factorial 5       # → 120
math::fibonacci 10      # → 55
```

---

## Vec2 Operations

2D vectors represented as comma-separated strings `"x,y"`.

| Function | Description |
|----------|-------------|
| `math::vec2::new` | Create a new vec2 |
| `math::vec2::new::fast` | Fast variant writing to a nameref |
| `math::vec2::add` | Add two vec2 vectors |
| `math::vec2::addf` | Add two vec2 vectors (float) |
| `math::vec2::sub` | Subtract vec2 b from vec2 a |
| `math::vec2::subf` | Subtract vec2 b from vec2 a (float) |
| `math::vec2::scale` | Scale a vec2 by a scalar |
| `math::vec2::scalef` | Scale a vec2 by a scalar (float) |
| `math::vec2::dot` | Dot product — returns scalar |
| `math::vec2::dotf` | Dot product (float) |
| `math::vec2::magnitude` | Magnitude (length) — requires `bc` |
| `math::vec2::magnitudef` | Magnitude with explicit scale |
| `math::vec2::normalise` | Normalise to unit length |
| `math::vec2::normalisef` | Normalise with explicit scale |
| `math::vec2::distance` | Distance between two points |
| `math::vec2::distancef` | Distance between two points (float) |
| `math::vec2::eq` | Check if two vec2 are equal |

```bash
math::vec2::add "3,4" "1,2"           # → 4,6
math::vec2::dot "1,0" "0,1"           # → 0 (perpendicular)
math::vec2::magnitude "3,4"           # → 5.0
math::vec2::normalise "3,4"           # → .6000000000,.8000000000
math::vec2::distance "0,0" "3,4"      # → 5.0
```

## Vec3 Operations

3D vectors represented as `"x,y,z"`.

| Function | Description |
|----------|-------------|
| `math::vec3::new` | Create a new vec3 |
| `math::vec3::new::fast` | Fast variant writing to a nameref |
| `math::vec3::add` / `::addf` | Add two vec3 vectors |
| `math::vec3::sub` / `::subf` | Subtract vec3 b from vec3 a |
| `math::vec3::scale` / `::scalef` | Scale by a scalar |
| `math::vec3::dot` / `::dotf` | Dot product |
| `math::vec3::cross` / `::crossf` | Cross product |
| `math::vec3::magnitude` / `::magnitudef` | Magnitude (length) |
| `math::vec3::normalise` / `::normalisef` | Normalise to unit length |
| `math::vec3::distance` / `::distancef` | Distance between two points |
| `math::vec3::eq` | Check if two vec3 are equal |

```bash
math::vec3::cross "1,0,0" "0,1,0"    # → 0,0,1
math::vec3::magnitude "1,2,3"        # → 3.7416573867
```

---

## Matrix Operations

Matrices use a dimension string `"RxC"` and flat space-separated element lists. Float variants suffixed with `f` use `bc`.

### Construction & Inspection

| Function | Description | Fast |
|----------|-------------|------|
| `math::matrix::new` | Create a matrix (all zeros or fill value) | `::fast` |
| `math::matrix::identity` | Generate an N×N identity matrix | `::fast` |
| `math::matrix::is_square` | Check if a matrix is square | — |
| `math::matrix::eq` | Check element-wise equality | — |
| `math::matrix::flatten` | Flatten to newline-separated list | — |
| `math::matrix::print` | Print in human-readable row-major format | — |
| `math::matrix::trace` / `::tracef` | Sum of diagonal elements | — |
| `math::matrix::diagonal` | Extract diagonal elements | — |
| `math::matrix::rank` | Compute rank via Gaussian elimination | — |

### Arithmetic

| Function | Description | Fast |
|----------|-------------|------|
| `math::matrix::add` / `::addf` | Element-wise addition | `::fast` |
| `math::matrix::sub` / `::subf` | Element-wise subtraction | `::fast` |
| `math::matrix::scale` / `::scalef` | Multiply every element by a scalar | `::fast` |
| `math::matrix::mul` / `::mulf` | Matrix multiplication | `::fast` |
| `math::matrix::hadamard` / `::hadamardf` | Element-wise multiplication | `::fast` |

### Advanced

| Function | Description |
|----------|-------------|
| `math::matrix::transpose` | Transpose — rows become columns |
| `math::matrix::minor` | Minor — submatrix with row i and col j removed |
| `math::matrix::determinant` | Determinant of a square matrix |
| `math::matrix::cofactor` | Cofactor matrix |
| `math::matrix::adjugate` | Adjugate (transpose of cofactor matrix) |
| `math::matrix::inverse` | Inverse of a square matrix |
| `math::matrix::lu` | LU decomposition |
| `math::matrix::pow` / `::powf` | Raise square matrix to integer power |

```bash
# Create a 2x3 matrix and a 3x2 matrix, then multiply
a=($(math::matrix::new 2x3 1))
b=($(math::matrix::new 3x2 2))
math::matrix::mul "2x2" "3x2" "${a[*]}" "${b[*]}"
```

---

## Floating Point (requires `bc`)

| Function | Description |
|----------|-------------|
| `math::floor` | Floor — largest integer ≤ n |
| `math::ceil` | Ceiling — smallest integer ≥ n |
| `math::round` | Round to nearest integer or d decimal places |
| `math::sqrt` | Square root |
| `math::log` | Natural logarithm |
| `math::log2` | Log base 2 |
| `math::log10` | Log base 10 |
| `math::logn` | Log with arbitrary base |
| `math::exp` | Exponential e^n |
| `math::powf` | Power (floating point) |
| `math::sigmoid` | Sigmoid — array-primary, operates in one awk pass |
| `math::sigmoid::singleton` | Sigmoid for a single value |
| `math::softmax` | Softmax with optional temperature |

```bash
math::round 3.14159 2     # → 3.14
math::sqrt 2              # → 1.4142135623
math::log10 100           # → 2.0000000000
math::powf 2 3.5          # → 11.3137084989
```

## Trigonometry (requires `bc`, angles in radians)

| Function | Description |
|----------|-------------|
| `math::sin` | Sine |
| `math::cos` | Cosine |
| `math::tan` | Tangent |
| `math::asin` | Arcsine |
| `math::acos` | Arccosine |
| `math::atan` | Arctangent |
| `math::atan2` | Arctangent of y/x |
| `math::deg_to_rad` | Convert degrees to radians |
| `math::rad_to_deg` | Convert radians to degrees |

## Percentage & Interpolation

| Function | Description |
|----------|-------------|
| `math::percent` | `(part / total) * 100` |
| `math::percent_of` | `total * (pct / 100)` |
| `math::percent_change` | `((new - old) / old) * 100` |
| `math::lerp` | Linear interpolation: `a + t*(b-a)` |
| `math::lerp_unclamped` | Lerp without clamping t |
| `math::map` | Map value from one range to another |
| `math::normalize` | Normalise value to 0.0–1.0 range |

## Combinatorics

| Function | Description |
|----------|-------------|
| `math::choose` | Binomial coefficient C(n, k) — "n choose k" |
| `math::permute` | Number of permutations P(n, k) |

## Unit Conversion

| Function | Description |
|----------|-------------|
| `math::unitconvert` | Universal unit conversion dispatcher |

```bash
math::unitconvert km mi 5       # → 3.106855
math::unitconvert kg lb 10      # → 22.046200
```

## Dependencies

- **Requires**: `runtime`
- **External tools**: `bc` (required for all float, trig, matrix determinant/inverse functions)
