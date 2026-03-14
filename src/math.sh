#!/usr/bin/env bash
# math.sh — bash-frameheader math lib
# Requires: runtime.sh (runtime::has_command)
#
# Pure bash integer arithmetic where possible.
# Floating point operations require bc — math::bc() checks availability.
# Scale (decimal places) defaults to 10 unless overridden via MATH_SCALE.
#
# ------------------------------------------------------------------------------
# NAMING CONVENTION — f suffix and ::singleton
# ------------------------------------------------------------------------------
# `f` suffix (e.g. clampf, addf):
#   Marks a float variant where the base function is integer-primary.
#   Absence of `f` on a float-native function (sqrt, lerp, sigmoid) signals
#   that the function is already float-only — no int version exists or makes sense.
#   If a function's domain is obviously integer (mod, gcd, factorial), no `f`
#   counterpart is added — the name already implies integer intent.
#   If a function's domain is ambiguous (clamp, abs, min, max), an `f` counterpart
#   exists (even as a redirect) so that absence of `f` elsewhere is unambiguous.
#
# `::singleton` suffix (e.g. math::sigmoid::singleton):
#   Marks a single-value escape hatch for functions that are array-primary by design.
#   Absence of ::singleton means the function naturally accepts scalar args.
#   Presence signals: "the array form is the intended call path; use this sparingly."
# ------------------------------------------------------------------------------

MATH_SCALE="${MATH_SCALE:-10}"

# ==============================================================================
# CONSTANTS
# 42 digits
# Some constants are truncated to 42 digits where available —
# enough for the observable universe with room for Douglas Adams,
# others are given with their commonly known precision.
# ==============================================================================

# Fundamental constants
readonly MATH_PI="3.141592653589793238462643383279502884197169"
readonly MATH_E="2.718281828459045235360287471352662497757237"
readonly MATH_PHI="1.618033988749894848204586834365638117720309"  # Golden ratio
readonly MATH_TAU="6.283185307179586476925286766559005768394338"  # 2π

# Square roots
readonly MATH_SQRT2="1.414213562373095048801688724209698078569671"
readonly MATH_SQRT3="1.732050807568877293527446341505872366942805"
readonly MATH_SQRT5="2.236067977499789696409173668731276235440618"
readonly MATH_SQRT10="3.162277660168379331998893544432718533719555"

# Logarithms
readonly MATH_LN2="0.693147180559945309417232121458176568075500"
readonly MATH_LN10="2.302585092994045684017991454684364207601101"
readonly MATH_LOG2E="1.442695040888963407359924681001892137426645"   # log_2 (e)
readonly MATH_LOG10E="0.434294481903251827651128918916605082294397"  # log_10(e)

# Euler-related
readonly MATH_EULER_MASCHERONI="0.577215664901532860606512090082402431042159" # γ
readonly MATH_CATALAN="0.915965594177219015054603514932384110774149"          # G
readonly MATH_APERY="1.202056903159594285399738161511449990764986"            # ζ(3)

# Trigonometric (in radians)
readonly MATH_DEG_TO_RAD="0.017453292519943295769236907684886127134428"  # π/180
readonly MATH_RAD_TO_DEG="57.29577951308232087679815481410517033240547"  # 180/π

# Special angles (in radians)
readonly MATH_PI_OVER_2="1.570796326794896619231321691639751442098584"  # π/2
readonly MATH_PI_OVER_3="1.047197551196597746154214461093167628065723"  # π/3
readonly MATH_PI_OVER_4="0.785398163397448309615660845819875721049292"  # π/4
readonly MATH_PI_OVER_6="0.523598775598298873077107230546583814032861"  # π/6

# Physics/astronomy constants (SI units)
readonly MATH_SPEED_OF_LIGHT="299792458"                                      # c   @ m/s    (exact)
readonly MATH_GRAVITATIONAL_CONSTANT="0.0000000000667430"                     # G   @ m³ kg⁻^-1 s^-2
readonly MATH_PLANCK_CONSTANT="0.000000000000000000000000000000000662607015"  # h   @ J·s    (exact)
readonly MATH_AVOGADRO_NUMBER="602214076000000000000000"                      # N_A @ mol^-1 (exact)
readonly MATH_BOLTZMANN_CONSTANT="0.00000000000000000000001380649"            # k_B @ J/K    (exact)
readonly MATH_ELEMENTARY_CHARGE="0.0000000000000000001602176634"              # e   @ C      (exact)

# Derived physics constants
readonly MATH_REDUCED_PLANCK_CONSTANT="0.00000000000000000000000000000000010545718"  # ħ = h/2π

# Engineering constants
readonly MATH_EARTH_GRAVITY="9.80665"                # g   @ m/s² (standard gravity)
readonly MATH_STANDARD_ATMOSPHERE="101325"           # atm @ Pa
readonly MATH_STEFAN_BOLTZMANN="0.00000005670374419" # σ   @ W·m⁻²·K⁻⁴

# Number theory
readonly MATH_KHINCHIN="2.685452001065306445309714835481795693820382"           # K₀
readonly MATH_GLAISHER_KINKELIN="1.282427129100622636875342568869791727767688"  # A
readonly MATH_MILLS="1.306377883863080690468614492602605712916784"              # θ
readonly MATH_PLASTIC="1.324717957244746025960908854478097340734404"            # ρ

# Geometry
readonly MATH_SILVER_RATIO="2.414213562373095048801688724209698078569671"  # 1+√2
readonly MATH_BRONZE_RATIO="3.302775637731994646559610633735247973125648"  # (3+√13)/2
readonly MATH_SUPER_GOLDEN_RATIO="1.465571231876768026656731225219939108025577"

# Limits and bounds
readonly MATH_FEIGENBAUM_ALPHA="2.502907875095892822283902873218215786381271"
readonly MATH_FEIGENBAUM_DELTA="4.669201609102990671853203820466201617258185"

# Probability/statistics
readonly MATH_GAUSS_CONSTANT="0.834626841674073186281429732799046808993993"  # G
readonly MATH_ERDOS_BORWEIN="1.606695152415291763783301523190924580480579"   # E

# Computer science
readonly MATH_SHANNON_ENTROPY_BASE2="1.442695040888963407359924681001892137426645"  # 1/ln(2)
readonly MATH_GOLDEN_ANGLE="2.399963229728653322231555506633613853124999"           # 2π/φ² radians

# Famous irrationals
readonly MATH_CHAITIN="0.0078749969978123844"                            # Ω (Chaitin's constant, approximate)
readonly MATH_TWIN_PRIME="0.660161815846869573927812110014555778432623"  # C₂

# Dimensionless physical constants
readonly MATH_FINE_STRUCTURE="0.0072973525693"  # α
readonly MATH_PROTON_ELECTRON_MASS_RATIO="1836.15267343"

# Mathematical bounds
readonly MATH_LOWER_GAMMA="-0.072815845483676724860586375874901319137736"  # γ₁
readonly MATH_UPPER_GAMMA="0.989055995327972555395395651500634707939184"   # γ₂

# ==============================================================================
# ALIASES - Practical alternative names
# ==============================================================================

# Common mathematical names
readonly MATH_GOLDEN_RATIO="$MATH_PHI"
readonly MATH_EULER_GAMMA="$MATH_EULER_MASCHERONI"
readonly MATH_TWICE_PI="$MATH_TAU"
readonly MATH_CATALANS_CONSTANT="$MATH_CATALAN"
readonly MATH_APERYS_CONSTANT="$MATH_APERY"
readonly MATH_CHAITINS_CONSTANT="$MATH_CHAITIN"
readonly MATH_TWIN_PRIME_CONSTANT="$MATH_TWIN_PRIME"

# Physics constants (standard symbol names)
readonly MATH_c="$MATH_SPEED_OF_LIGHT"
readonly MATH_G="$MATH_GRAVITATIONAL_CONSTANT"
readonly MATH_h="$MATH_PLANCK_CONSTANT"
readonly MATH_hbar="$MATH_REDUCED_PLANCK_CONSTANT"
readonly MATH_N_A="$MATH_AVOGADRO_NUMBER"
readonly MATH_k_B="$MATH_BOLTZMANN_CONSTANT"
readonly MATH_e="$MATH_ELEMENTARY_CHARGE"
readonly MATH_g="$MATH_EARTH_GRAVITY"
readonly MATH_atm="$MATH_STANDARD_ATMOSPHERE"
readonly MATH_sigma="$MATH_STEFAN_BOLTZMANN"
readonly MATH_alpha="$MATH_FINE_STRUCTURE"

# Conversion shortcuts
readonly MATH_DEG2RAD="$MATH_DEG_TO_RAD"
readonly MATH_RAD2DEG="$MATH_RAD_TO_DEG"


# ==============================================================================
# BC WRAPPER
# ==============================================================================

# Check if bc is available
math::has_bc() {
    runtime::has_command bc
}

math::bc() {
    local expr="$1" scale="${2:-$MATH_SCALE}"
    if ! math::has_bc; then
        echo "math::bc: requires bc (GNU coreutils)" >&2
        return 1
    fi
    echo "scale=${scale}; ${expr}" | bc -l | sed 's/^\./0./; s/^-\./-0./'
}


# Safe bc wrapper — checks availability, applies scale
# Usage: math::bc expression [scale]
# Example: math::bc "4 * a(1)" 42


# ==============================================================================
# FLOAT DETECTION HELPER
# Internal helper — not exported as part of the public math API
# ==============================================================================

_math::is_float() {
    [[ "$1" =~ ^-?[0-9]+(\.[0-9]+)?([Ee][+-]?[0-9]+)?$ ]] && [[ "$1" == *"."* || "$1" == *[Ee]* ]]
}

math::is_int() {
    [[ "$1" =~ ^-?[0-9]+$ ]]
}

# ==============================================================================
# BASIC INTEGER ARITHMETIC
# Pure bash — no bc needed
# ==============================================================================

# Absolute value (integer)
# Usage: math::abs n
math::abs() {
    _math::is_float "$1" && { echo "math::abs: float input — use math::absf" >&2; return 1; }
    echo $(( $1 < 0 ? -$1 : $1 ))
}

# Absolute value (float) — Usage: math::absf n [scale]
math::absf() {
    local scale="${2:-$MATH_SCALE}"
    math::bc "if ($1 < 0) { -($1) } else { $1 }" "$scale"
}

# Minimum of two values (integer)
math::min() {
    _math::is_float "$1" || _math::is_float "$2" && { echo "math::min: float input — use math::minf" >&2; return 1; }
    echo $(( $1 < $2 ? $1 : $2 ))
}

# Minimum of two values (float) — Usage: math::minf a b [scale]
math::minf() {
    local scale="${3:-$MATH_SCALE}"
    math::bc "if ($1 < $2) { $1 } else { $2 }" "$scale"
}

# Maximum of two values (integer)
math::max() {
    _math::is_float "$1" || _math::is_float "$2" && { echo "math::max: float input — use math::maxf" >&2; return 1; }
    echo $(( $1 > $2 ? $1 : $2 ))
}

# Maximum of two values (float) — Usage: math::maxf a b [scale]
math::maxf() {
    local scale="${3:-$MATH_SCALE}"
    math::bc "if ($1 > $2) { $1 } else { $2 }" "$scale"
}

# Clamp n between min and max inclusive
# Usage: math::clamp n min max
math::clamp() {
    local n="$1" lo="$2" hi="$3"
    _math::is_float "$n" || _math::is_float "$lo" || _math::is_float "$hi" && { echo "math::clamp: float input — use math::clampf" >&2; return 1; }
    echo $(( n < lo ? lo : (n > hi ? hi : n) ))
}

math::clampf() {
    local n="$1" lo="$2" hi="$3"
    local scale=${4:-$MATH_SCALE}
    local result
    result=$(math::bc "if ($n < $lo) $lo else if ($n > $hi) $hi else $n" "$scale")
    # Format with consistent decimal places (bc is being inconsistent for some reason)
    printf "%.${scale}f\n" "$result"
}

# Integer division (truncated toward zero)
# Usage: math::div dividend divisor
math::div() {
    _math::is_float "$1" || _math::is_float "$2" && { echo "math::div: float input — use math::bc for float division" >&2; return 1; }
    echo $(( $1 / $2 ))
}

# Modulo
math::mod() {
    _math::is_float "$1" || _math::is_float "$2" && { echo "math::mod: float input — use math::bc for float modulo" >&2; return 1; }
    echo $(( $1 % $2 ))
}

# Integer exponentiation
# Usage: math::pow base exponent
math::pow() {
    local base="$1" exp="$2" result=1
    _math::is_float "$base" || _math::is_float "$exp" && { echo "math::pow: float input — use math::powf" >&2; return 1; }
    while (( exp > 0 )); do
        (( exp % 2 == 1 )) && result=$(( result * base ))
        base=$(( base * base ))
        exp=$(( exp / 2 ))
    done
    echo "$result"
}

# Greatest common divisor (Euclidean algorithm)
# Usage: math::gcd a b
math::gcd() {
    _math::is_float "$1" || _math::is_float "$2" && { echo "math::gcd: float input — gcd is integer-only" >&2; return 1; }
    local a=$(( $1 < 0 ? -$1 : $1 ))
    local b=$(( $2 < 0 ? -$2 : $2 ))
    while (( b != 0 )); do
        local t=$b
        b=$(( a % b ))
        a=$t
    done
    echo "$a"
}

# Least common multiple
# Usage: math::lcm a b
math::lcm() {
    local a="$1" b="$2"
    _math::is_float "$a" || _math::is_float "$b" && { echo "math::lcm: float input — lcm is integer-only" >&2; return 1; }
    local gcd
    gcd=$(math::gcd "$a" "$b")
    echo $(( (a / gcd) * b ))
}

# Check if integer is even
math::is_even() {
    _math::is_float "$1" && { echo "math::is_even: float input — is_even is integer-only" >&2; return 1; }
    (( $1 % 2 == 0 ))
}

# Check if integer is odd
math::is_odd() {
    _math::is_float "$1" && { echo "math::is_odd: float input — is_odd is integer-only" >&2; return 1; }
    (( $1 % 2 != 0 ))
}

# Check if integer is prime
math::is_prime() {
    local n="$1"
    _math::is_float "$n" && { echo "math::is_prime: float input — is_prime is integer-only" >&2; return 1; }
    (( n < 2 )) && return 1
    (( n == 2 )) && return 0
    (( n % 2 == 0 )) && return 1
    local i=3
    while (( i * i <= n )); do
        (( n % i == 0 )) && return 1
        (( i += 2 ))
    done
    return 0
}

# Factorial (integer)
# Usage: math::factorial n
math::factorial() {
    local n="$1" result=1
    _math::is_float "$n" && { echo "math::factorial: float input — factorial is integer-only" >&2; return 1; }
    (( n < 0 )) && { echo "math::factorial: negative input" >&2; return 1; }
    local i
    for (( i=2; i<=n; i++ )); do result=$(( result * i )); done
    echo "$result"
}

# Fibonacci (nth term, 0-indexed)
# Usage: math::fibonacci n
math::fibonacci() {
    local n="$1" a=0 b=1 i
    _math::is_float "$n" && { echo "math::fibonacci: float input — fibonacci is integer-only" >&2; return 1; }
    (( n == 0 )) && echo 0 && return
    for (( i=1; i<n; i++ )); do
        local t=$(( a + b ))
        a=$b
        b=$t
    done
    echo "$b"
}

# Integer square root (floor)
# Usage: math::isqrt n
math::int_sqrt() {
    local n="$1" x
    _math::is_float "$n" && { echo "math::int_sqrt: float input — use math::sqrt" >&2; return 1; }
    (( n < 0 )) && { echo "math::isqrt: negative input" >&2; return 1; }
    (( n == 0 )) && echo 0 && return
    x=$(( n / 2 + 1 ))
    local y=$(( (x + n / x) / 2 ))
    while (( y < x )); do
        x=$y
        y=$(( (x + n / x) / 2 ))
    done
    echo "$x"
}

# Sum of a sequence of integers
# Usage: math::sum n1 n2 n3 ...
math::sum() {
    local total=0
    for n in "$@"; do
        _math::is_float "$n" && { echo "math::sum: float input — use math::sumf" >&2; return 1; }
        (( total += n ))
    done
    echo "$total"
}

# Sum of a sequence of floats
# Usage: math::sumf scale n1 n2 n3 ...
math::sumf() {
    local scale=$1; shift
    local total="0"
    for n in "$@"; do total=$(math::bc "$total + $n" "$scale"); done
    echo "$total"
}

# Product of a sequence of integers
math::product() {
    local result=1
    for n in "$@"; do
        _math::is_float "$n" && { echo "math::product: float input — use math::productf" >&2; return 1; }
        (( result *= n ))
    done
    echo "$result"
}

# Product of a sequence of floats
# Usage: math::productf scale n1 n2 n3 ...
math::productf() {
    local scale=$1; shift
    local result="1"
    for n in "$@"; do result=$(math::bc "$result * $n" "$scale"); done
    echo "$result"
}

# ==============================================================================
# math::vec2 / math::vec3 — Vector operations
# Vectors are passed and returned as comma-separated strings: "x,y" or "x,y,z"
# Integer variants take components directly
# Float variants (f suffix) take scale as first argument
#
# Example:
#   a="1,2,3"
#   b="4,5,6"
#   math::vec3::dot "$a" "$b"                          # → 32
#   math::vec3::add "$a" "$b"                          # → 5,7,9
#   math::vec3::dot "$(math::vec3::add "$a" "$b")" "$b" # composable
#
#   # Destructure result
#   IFS=, read -r x y z <<< "$(math::vec3::add "$a" "$b")"
#
#   # Take just one component
#   IFS=, read -r x _ _ <<< "$(math::vec3::add "$a" "$b")"
# ==============================================================================

# Internal: split a comma-separated vec2 into positional vars
# Usage: _math::vec2::split "x,y" → sets _v_x1 _v_y1
_math::vec2::unpack2() {
    local -n _x="$1" _y="$2"
    IFS=, read -r _x _y <<< "$3"
}

# Internal: split two comma-separated vec2s into positional vars
_math::vec2::unpack4() {
    local -n _x1="$1" _y1="$2" _x2="$3" _y2="$4"
    IFS=, read -r _x1 _y1 <<< "$5"
    IFS=, read -r _x2 _y2 <<< "$6"
}

# Internal: split a comma-separated vec3 into positional vars
_math::vec3::unpack3() {
    local -n _x="$1" _y="$2" _z="$3"
    IFS=, read -r _x _y _z <<< "$4"
}

# Internal: split two comma-separated vec3s into positional vars
_math::vec3::unpack6() {
    local -n _x1="$1" _y1="$2" _z1="$3" _x2="$4" _y2="$5" _z2="$6"
    IFS=, read -r _x1 _y1 _z1 <<< "$7"
    IFS=, read -r _x2 _y2 _z2 <<< "$8"
}

# ==============================================================================
# math::vec2
# ==============================================================================

# Add two vec2 vectors
# Usage: math::vec2::add "x1,y1" "x2,y2"
# Returns: "x,y"
math::vec2::add() {
    local x1 y1 x2 y2
    _math::vec2::unpack4 x1 y1 x2 y2 "$1" "$2"
    echo "$(( x1 + x2 )),$(( y1 + y2 ))"
}

# Add two vec2 vectors with floating point precision
# Usage: math::vec2::addf scale "x1,y1" "x2,y2"
# Returns: "x,y"
math::vec2::addf() {
    local scale=$1 x1 y1 x2 y2
    _math::vec2::unpack4 x1 y1 x2 y2 "$2" "$3"
    echo "$(math::bc "$x1 + $x2" "$scale"),$(math::bc "$y1 + $y2" "$scale")"
}

# Subtract vec2 b from vec2 a
# Usage: math::vec2::sub "x1,y1" "x2,y2"
# Returns: "x,y"
math::vec2::sub() {
    local x1 y1 x2 y2
    _math::vec2::unpack4 x1 y1 x2 y2 "$1" "$2"
    echo "$(( x1 - x2 )),$(( y1 - y2 ))"
}

# Subtract vec2 b from vec2 a with floating point precision
# Usage: math::vec2::subf scale "x1,y1" "x2,y2"
# Returns: "x,y"
math::vec2::subf() {
    local scale=$1 x1 y1 x2 y2
    _math::vec2::unpack4 x1 y1 x2 y2 "$2" "$3"
    echo "$(math::bc "$x1 - $x2" "$scale"),$(math::bc "$y1 - $y2" "$scale")"
}

# Scale a vec2 by a scalar
# Usage: math::vec2::scale "x,y" scalar
# Returns: "x,y"
math::vec2::scale() {
    local x y
    _math::vec2::unpack2 x y "$1"
    echo "$(( x * $2 )),$(( y * $2 ))"
}

# Scale a vec2 by a scalar with floating point precision
# Usage: math::vec2::scalef scale "x,y" scalar
# Returns: "x,y"
math::vec2::scalef() {
    local scale=$1 x y
    _math::vec2::unpack2 x y "$2"
    echo "$(math::bc "$x * $3" "$scale"),$(math::bc "$y * $3" "$scale")"
}

# Dot product of two vec2 vectors
# Usage: math::vec2::dot "x1,y1" "x2,y2"
# Returns: scalar integer
math::vec2::dot() {
    local x1 y1 x2 y2
    _math::vec2::unpack4 x1 y1 x2 y2 "$1" "$2"
    echo "$(( x1 * x2 + y1 * y2 ))"
}

# Dot product of two vec2 vectors with floating point precision
# Usage: math::vec2::dotf scale "x1,y1" "x2,y2"
# Returns: scalar float
math::vec2::dotf() {
    local scale=$1 x1 y1 x2 y2
    _math::vec2::unpack4 x1 y1 x2 y2 "$2" "$3"
    math::bc "$x1 * $x2 + $y1 * $y2" "$scale"
}

# Magnitude (length) of a vec2 — requires bc
# Usage: math::vec2::magnitude "x,y"
# Returns: scalar float
math::vec2::magnitude() {
    local x y
    _math::vec2::unpack2 x y "$1"
    math::bc "sqrt($x * $x + $y * $y)"
}

# Magnitude with explicit scale
# Usage: math::vec2::magnitudef scale "x,y"
# Returns: scalar float
math::vec2::magnitudef() {
    local scale=$1 x y
    _math::vec2::unpack2 x y "$2"
    math::bc "sqrt($x * $x + $y * $y)" "$scale"
}

# Normalise a vec2 to unit length — requires bc
# Usage: math::vec2::normalise "x,y"
# Returns: "x,y"
math::vec2::normalise() {
    local x y mag
    _math::vec2::unpack2 x y "$1"
    mag=$(math::bc "sqrt($x * $x + $y * $y)")
    echo "$(math::bc "$x / $mag"),$(math::bc "$y / $mag")"
}

# Normalise a vec2 with explicit scale
# Usage: math::vec2::normalisef scale "x,y"
# Returns: "x,y"
math::vec2::normalisef() {
    local scale=$1 x y mag
    _math::vec2::unpack2 x y "$2"
    mag=$(math::bc "sqrt($x * $x + $y * $y)" "$scale")
    echo "$(math::bc "$x / $mag" "$scale"),$(math::bc "$y / $mag" "$scale")"
}

# Distance between two vec2 points — requires bc
# Usage: math::vec2::distance "x1,y1" "x2,y2"
# Returns: scalar float
math::vec2::distance() {
    local x1 y1 x2 y2
    _math::vec2::unpack4 x1 y1 x2 y2 "$1" "$2"
    math::bc "sqrt(($x1-$x2)*($x1-$x2) + ($y1-$y2)*($y1-$y2))"
}

# Distance between two vec2 points with explicit scale
# Usage: math::vec2::distancef scale "x1,y1" "x2,y2"
# Returns: scalar float
math::vec2::distancef() {
    local scale=$1 x1 y1 x2 y2
    _math::vec2::unpack4 x1 y1 x2 y2 "$2" "$3"
    math::bc "sqrt(($x1-$x2)*($x1-$x2) + ($y1-$y2)*($y1-$y2))" "$scale"
}

# Check if two vec2 vectors are equal
# Usage: math::vec2::eq "x1,y1" "x2,y2"
# Returns: 0 if equal, 1 otherwise
math::vec2::eq() {
    [[ "$1" == "$2" ]]
}

# ==============================================================================
# math::vec3
# ==============================================================================

# Add two vec3 vectors
# Usage: math::vec3::add "x1,y1,z1" "x2,y2,z2"
# Returns: "x,y,z"
math::vec3::add() {
    local x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$1" "$2"
    echo "$(( x1 + x2 )),$(( y1 + y2 )),$(( z1 + z2 ))"
}

# Add two vec3 vectors with floating point precision
# Usage: math::vec3::addf scale "x1,y1,z1" "x2,y2,z2"
# Returns: "x,y,z"
math::vec3::addf() {
    local scale=$1 x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$2" "$3"
    echo "$(math::bc "$x1 + $x2" "$scale"),$(math::bc "$y1 + $y2" "$scale"),$(math::bc "$z1 + $z2" "$scale")"
}

# Subtract vec3 b from vec3 a
# Usage: math::vec3::sub "x1,y1,z1" "x2,y2,z2"
# Returns: "x,y,z"
math::vec3::sub() {
    local x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$1" "$2"
    echo "$(( x1 - x2 )),$(( y1 - y2 )),$(( z1 - z2 ))"
}

# Subtract vec3 b from vec3 a with floating point precision
# Usage: math::vec3::subf scale "x1,y1,z1" "x2,y2,z2"
# Returns: "x,y,z"
math::vec3::subf() {
    local scale=$1 x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$2" "$3"
    echo "$(math::bc "$x1 - $x2" "$scale"),$(math::bc "$y1 - $y2" "$scale"),$(math::bc "$z1 - $z2" "$scale")"
}

# Scale a vec3 by a scalar
# Usage: math::vec3::scale "x,y,z" scalar
# Returns: "x,y,z"
math::vec3::scale() {
    local x y z
    _math::vec3::unpack3 x y z "$1"
    echo "$(( x * $2 )),$(( y * $2 )),$(( z * $2 ))"
}

# Scale a vec3 by a scalar with floating point precision
# Usage: math::vec3::scalef scale "x,y,z" scalar
# Returns: "x,y,z"
math::vec3::scalef() {
    local scale=$1 x y z
    _math::vec3::unpack3 x y z "$2"
    echo "$(math::bc "$x * $3" "$scale"),$(math::bc "$y * $3" "$scale"),$(math::bc "$z * $3" "$scale")"
}

# Dot product of two vec3 vectors
# Usage: math::vec3::dot "x1,y1,z1" "x2,y2,z2"
# Returns: scalar integer
math::vec3::dot() {
    local x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$1" "$2"
    echo "$(( x1 * x2 + y1 * y2 + z1 * z2 ))"
}

# Dot product of two vec3 vectors with floating point precision
# Usage: math::vec3::dotf scale "x1,y1,z1" "x2,y2,z2"
# Returns: scalar float
math::vec3::dotf() {
    local scale=$1 x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$2" "$3"
    math::bc "$x1 * $x2 + $y1 * $y2 + $z1 * $z2" "$scale"
}

# Cross product of two vec3 vectors
# Usage: math::vec3::cross "x1,y1,z1" "x2,y2,z2"
# Returns: "x,y,z"
math::vec3::cross() {
    local x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$1" "$2"
    echo "$(( y1*z2 - z1*y2 )),$(( z1*x2 - x1*z2 )),$(( x1*y2 - y1*x2 ))"
}

# Cross product of two vec3 vectors with floating point precision
# Usage: math::vec3::crossf scale "x1,y1,z1" "x2,y2,z2"
# Returns: "x,y,z"
math::vec3::crossf() {
    local scale=$1 x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$2" "$3"
    echo "$(math::bc "$y1*$z2 - $z1*$y2" "$scale"),$(math::bc "$z1*$x2 - $x1*$z2" "$scale"),$(math::bc "$x1*$y2 - $y1*$x2" "$scale")"
}

# Magnitude (length) of a vec3 — requires bc
# Usage: math::vec3::magnitude "x,y,z"
# Returns: scalar float
math::vec3::magnitude() {
    local x y z
    _math::vec3::unpack3 x y z "$1"
    math::bc "sqrt($x*$x + $y*$y + $z*$z)"
}

# Magnitude with explicit scale
# Usage: math::vec3::magnitudef scale "x,y,z"
# Returns: scalar float
math::vec3::magnitudef() {
    local scale=$1 x y z
    _math::vec3::unpack3 x y z "$2"
    math::bc "sqrt($x*$x + $y*$y + $z*$z)" "$scale"
}

# Normalise a vec3 to unit length — requires bc
# Usage: math::vec3::normalise "x,y,z"
# Returns: "x,y,z"
math::vec3::normalise() {
    local x y z mag
    _math::vec3::unpack3 x y z "$1"
    mag=$(math::bc "sqrt($x*$x + $y*$y + $z*$z)")
    echo "$(math::bc "$x / $mag"),$(math::bc "$y / $mag"),$(math::bc "$z / $mag")"
}

# Normalise a vec3 with explicit scale
# Usage: math::vec3::normalisef scale "x,y,z"
# Returns: "x,y,z"
math::vec3::normalisef() {
    local scale=$1 x y z mag
    _math::vec3::unpack3 x y z "$2"
    mag=$(math::bc "sqrt($x*$x + $y*$y + $z*$z)" "$scale")
    echo "$(math::bc "$x / $mag" "$scale"),$(math::bc "$y / $mag" "$scale"),$(math::bc "$z / $mag" "$scale")"
}

# Distance between two vec3 points — requires bc
# Usage: math::vec3::distance "x1,y1,z1" "x2,y2,z2"
# Returns: scalar float
math::vec3::distance() {
    local x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$1" "$2"
    math::bc "sqrt(($x1-$x2)*($x1-$x2) + ($y1-$y2)*($y1-$y2) + ($z1-$z2)*($z1-$z2))"
}

# Distance between two vec3 points with explicit scale
# Usage: math::vec3::distancef scale "x1,y1,z1" "x2,y2,z2"
# Returns: scalar float
math::vec3::distancef() {
    local scale=$1 x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$2" "$3"
    math::bc "sqrt(($x1-$x2)*($x1-$x2) + ($y1-$y2)*($y1-$y2) + ($z1-$z2)*($z1-$z2))" "$scale"
}

# Check if two vec3 vectors are equal
# Usage: math::vec3::eq "x1,y1,z1" "x2,y2,z2"
# Returns: 0 if equal, 1 otherwise
math::vec3::eq() {
    [[ "$1" == "$2" ]]
}

# ==============================================================================
# math::matrix — Matrix operations
#
# Dimensions are passed as "RxC" strings: "2x3" = 2 rows, 3 cols
# Elements are passed either as a named array (nameref) or flat args (spaghetti)
# The function auto-detects the calling pattern by checking if the first
# element arg looks like a number or an identifier.
#
# Two variants:
#   math::matrix::*        — echoes result as space-separated flat list
#   math::matrix::*::fast  — first arg is output array name, no subshell
#
# CALLING PATTERNS:
#
#   # Nameref style — pass array names
#   local -a a=(1 2 3 4) b=(5 6 7 8)
#   read -ra result <<< "$(math::matrix::mul "2x2" "2x2" a b)"
#
#   # Spaghetti style — pass elements directly
#   read -ra result <<< "$(math::matrix::mul "2x2" "2x2" 1 2 3 4 5 6 7 8)"
#
#   # Fast variant — output array written in place, no subshell
#   local -a result=()
#   math::matrix::mul::fast result "2x2" "2x2" a b
#   math::matrix::mul::fast result "2x2" "2x2" 1 2 3 4 5 6 7 8
#
# Warning: in nameref style, pass the array NAME not the expanded value.
#   Correct: math::matrix::mul "2x2" "2x2" a b
#   Wrong:   math::matrix::mul "2x2" "2x2" "${a[@]}" "${b[@]}"
# ==============================================================================

# ------------------------------------------------------------------------------
# Internal helpers — parsing and unpacking only, no bc calls
# ------------------------------------------------------------------------------

# Parse a dimension string into rows and cols
# Usage: _math::matrix::dim "2x3" rows_var cols_var
_math::matrix::dim() {
    local -n _rows="$2" _cols="$3"
    IFS='x' read -r _rows _cols <<< "$1"
}

# Unpack a single matrix from either nameref or spaghetti args into a target array
# Usage: _math::matrix::unpack target_var size [name_or_elements...]
# Returns: number of args consumed via _math_unpack_consumed
_math::matrix::unpack() {
    local -n _target="$1"
    local size="$2"; shift 2
    if [[ "$1" =~ ^-?[0-9] ]]; then
        _target=("${@:1:$size}")
        _math_unpack_consumed="$size"
    else
        local -n _src="$1"
        _target=("${_src[@]}")
        _math_unpack_consumed=1
    fi
}

# Unpack two matrices from either nameref or spaghetti args
# Usage: _math::matrix::unpack2 target_a target_b size_a size_b [args...]
_math::matrix::unpack2() {
    local -n _ta="$1" _tb="$2"
    local size_a="$3" size_b="$4"; shift 4
    if [[ "$1" =~ ^-?[0-9] ]]; then
        _ta=("${@:1:$size_a}")
        _tb=("${@:$(( size_a + 1 )):$size_b}")
    else
        local -n _sa="$1" _sb="$2"
        _ta=("${_sa[@]}")
        _tb=("${_sb[@]}")
    fi
}

# ==============================================================================
# math::matrix::add — Element-wise addition
# ==============================================================================

# Add two matrices element-wise
# Usage: math::matrix::add "RxC" a b
# Returns: flat space-separated element list
math::matrix::add() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:2}"
    local -a _result=()
    local i
    for (( i = 0; i < size; i++ )); do
        _result+=("$(( _a[$i] + _b[$i] ))")
    done
    echo "${_result[@]}"
}

# Add two matrices element-wise, writing result into output array
# Usage: math::matrix::add::fast result "RxC" a b
math::matrix::add::fast() {
    local -n _out="$1"; shift
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:2}"
    _out=()
    local i
    for (( i = 0; i < size; i++ )); do
        _out+=("$(( _a[$i] + _b[$i] ))")
    done
}

# Add two matrices element-wise with floating point precision
# Usage: math::matrix::addf scale "RxC" a b
# Returns: flat space-separated element list
math::matrix::addf() {
    local scale=$1 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:3}"
    local -a _result=()
    local i
    for (( i = 0; i < size; i++ )); do
        _result+=("$(math::bc "${_a[$i]} + ${_b[$i]}" "$scale")")
    done
    echo "${_result[@]}"
}

# Add two matrices element-wise with floating point precision, writing into output array
# Usage: math::matrix::addf::fast result scale "RxC" a b
math::matrix::addf::fast() {
    local -n _out="$1"; shift
    local scale=$1 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:3}"
    _out=()
    local i
    for (( i = 0; i < size; i++ )); do
        _out+=("$(math::bc "${_a[$i]} + ${_b[$i]}" "$scale")")
    done
}

# ==============================================================================
# math::matrix::sub — Element-wise subtraction
# ==============================================================================

# Subtract matrix b from matrix a element-wise
# Usage: math::matrix::sub "RxC" a b
# Returns: flat space-separated element list
math::matrix::sub() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:2}"
    local -a _result=()
    local i
    for (( i = 0; i < size; i++ )); do
        _result+=("$(( _a[$i] - _b[$i] ))")
    done
    echo "${_result[@]}"
}

# Subtract matrix b from matrix a element-wise, writing into output array
# Usage: math::matrix::sub::fast result "RxC" a b
math::matrix::sub::fast() {
    local -n _out="$1"; shift
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:2}"
    _out=()
    local i
    for (( i = 0; i < size; i++ )); do
        _out+=("$(( _a[$i] - _b[$i] ))")
    done
}

# Subtract matrix b from matrix a element-wise with floating point precision
# Usage: math::matrix::subf scale "RxC" a b
# Returns: flat space-separated element list
math::matrix::subf() {
    local scale=$1 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:3}"
    local -a _result=()
    local i
    for (( i = 0; i < size; i++ )); do
        _result+=("$(math::bc "${_a[$i]} - ${_b[$i]}" "$scale")")
    done
    echo "${_result[@]}"
}

# Subtract matrix b from matrix a element-wise with floating point precision, writing into output array
# Usage: math::matrix::subf::fast result scale "RxC" a b
math::matrix::subf::fast() {
    local -n _out="$1"; shift
    local scale=$1 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:3}"
    _out=()
    local i
    for (( i = 0; i < size; i++ )); do
        _out+=("$(math::bc "${_a[$i]} - ${_b[$i]}" "$scale")")
    done
}

# ==============================================================================
# math::matrix::scale — Scalar multiplication
# ==============================================================================

# Multiply every element of a matrix by a scalar
# Usage: math::matrix::scale "RxC" scalar a
# Returns: flat space-separated element list
math::matrix::scale() {
    local scalar=$2 rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"
    local -a _result=()
    local i
    for (( i = 0; i < size; i++ )); do
        _result+=("$(( _a[$i] * scalar ))")
    done
    echo "${_result[@]}"
}

# Multiply every element of a matrix by a scalar, writing into output array
# Usage: math::matrix::scale::fast result "RxC" scalar a
math::matrix::scale::fast() {
    local -n _out="$1"; shift
    local scalar=$2 rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"
    _out=()
    local i
    for (( i = 0; i < size; i++ )); do
        _out+=("$(( _a[$i] * scalar ))")
    done
}

# Multiply every element of a matrix by a scalar with floating point precision
# Usage: math::matrix::scalef scale "RxC" scalar a
# Returns: flat space-separated element list
math::matrix::scalef() {
    local scale=$1 scalar=$3 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:4}"
    local -a _result=()
    local i
    for (( i = 0; i < size; i++ )); do
        _result+=("$(math::bc "${_a[$i]} * $scalar" "$scale")")
    done
    echo "${_result[@]}"
}

# Multiply every element of a matrix by a scalar with floating point precision, writing into output array
# Usage: math::matrix::scalef::fast result scale "RxC" scalar a
math::matrix::scalef::fast() {
    local -n _out="$1"; shift
    local scale=$1 scalar=$3 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:4}"
    _out=()
    local i
    for (( i = 0; i < size; i++ )); do
        _out+=("$(math::bc "${_a[$i]} * $scalar" "$scale")")
    done
}

# ==============================================================================
# math::matrix::mul — Matrix multiplication
# ==============================================================================

# Multiply two matrices — cols of a must equal rows of b
# Usage: math::matrix::mul "RxC" "RxC" a b
# Returns: flat space-separated element list
# Warning: cols_a must equal rows_b — "2x3" * "3x2" is valid, "2x3" * "2x3" is not
math::matrix::mul() {
    local rows_a cols_a rows_b cols_b
    _math::matrix::dim "$1" rows_a cols_a
    _math::matrix::dim "$2" rows_b cols_b
    if (( cols_a != rows_b )); then
        echo "Error: math::matrix::mul: incompatible dimensions $1 * $2" >&2
        return 1
    fi
    local size_a=$(( rows_a * cols_a )) size_b=$(( rows_b * cols_b ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size_a" "$size_b" "${@:3}"
    local -a _result=()
    local i j k sum
    for (( i = 0; i < rows_a; i++ )); do
        for (( j = 0; j < cols_b; j++ )); do
            sum=0
            for (( k = 0; k < cols_a; k++ )); do
                sum=$(( sum + _a[$i * $cols_a + $k] * _b[$k * $cols_b + $j] ))
            done
            _result+=("$sum")
        done
    done
    echo "${_result[@]}"
}

# Multiply two matrices, writing result into output array
# Usage: math::matrix::mul::fast result "RxC" "RxC" a b
# Warning: cols_a must equal rows_b
math::matrix::mul::fast() {
    local -n _out="$1"; shift
    local rows_a cols_a rows_b cols_b
    _math::matrix::dim "$1" rows_a cols_a
    _math::matrix::dim "$2" rows_b cols_b
    if (( cols_a != rows_b )); then
        echo "Error: math::matrix::mul::fast: incompatible dimensions $1 * $2" >&2
        return 1
    fi
    local size_a=$(( rows_a * cols_a )) size_b=$(( rows_b * cols_b ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size_a" "$size_b" "${@:3}"
    _out=()
    local i j k sum
    for (( i = 0; i < rows_a; i++ )); do
        for (( j = 0; j < cols_b; j++ )); do
            sum=0
            for (( k = 0; k < cols_a; k++ )); do
                sum=$(( sum + _a[$i * $cols_a + $k] * _b[$k * $cols_b + $j] ))
            done
            _out+=("$sum")
        done
    done
}

# Multiply two matrices with floating point precision
# Usage: math::matrix::mulf scale "RxC" "RxC" a b
# Returns: flat space-separated element list
# Warning: cols_a must equal rows_b
math::matrix::mulf() {
    local scale=$1 rows_a cols_a rows_b cols_b
    _math::matrix::dim "$2" rows_a cols_a
    _math::matrix::dim "$3" rows_b cols_b
    if (( cols_a != rows_b )); then
        echo "Error: math::matrix::mulf: incompatible dimensions $2 * $3" >&2
        return 1
    fi
    local size_a=$(( rows_a * cols_a )) size_b=$(( rows_b * cols_b ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size_a" "$size_b" "${@:4}"
    local -a _result=()
    local i j k sum
    for (( i = 0; i < rows_a; i++ )); do
        for (( j = 0; j < cols_b; j++ )); do
            sum="0"
            for (( k = 0; k < cols_a; k++ )); do
                sum=$(math::bc "$sum + ${_a[$i * $cols_a + $k]} * ${_b[$k * $cols_b + $j]}" "$scale")
            done
            _result+=("$sum")
        done
    done
    echo "${_result[@]}"
}

# Multiply two matrices with floating point precision, writing into output array
# Usage: math::matrix::mulf::fast result scale "RxC" "RxC" a b
# Warning: cols_a must equal rows_b
math::matrix::mulf::fast() {
    local -n _out="$1"; shift
    local scale=$1 rows_a cols_a rows_b cols_b
    _math::matrix::dim "$2" rows_a cols_a
    _math::matrix::dim "$3" rows_b cols_b
    if (( cols_a != rows_b )); then
        echo "Error: math::matrix::mulf::fast: incompatible dimensions $2 * $3" >&2
        return 1
    fi
    local size_a=$(( rows_a * cols_a )) size_b=$(( rows_b * cols_b ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size_a" "$size_b" "${@:4}"
    _out=()
    local i j k sum
    for (( i = 0; i < rows_a; i++ )); do
        for (( j = 0; j < cols_b; j++ )); do
            sum="0"
            for (( k = 0; k < cols_a; k++ )); do
                sum=$(math::bc "$sum + ${_a[$i * $cols_a + $k]} * ${_b[$k * $cols_b + $j]}" "$scale")
            done
            _out+=("$sum")
        done
    done
}

# ==============================================================================
# math::matrix::transpose
# ==============================================================================

# Transpose a matrix — rows become columns
# Usage: math::matrix::transpose "RxC" a
# Returns: flat space-separated element list
math::matrix::transpose() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:2}"
    local -a _result=()
    local i j
    for (( j = 0; j < cols; j++ )); do
        for (( i = 0; i < rows; i++ )); do
            _result+=("${_a[$i * $cols + $j]}")
        done
    done
    echo "${_result[@]}"
}

# Transpose a matrix, writing into output array
# Usage: math::matrix::transpose::fast result "RxC" a
math::matrix::transpose::fast() {
    local -n _out="$1"; shift
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:2}"
    _out=()
    local i j
    for (( j = 0; j < cols; j++ )); do
        for (( i = 0; i < rows; i++ )); do
            _out+=("${_a[$i * $cols + $j]}")
        done
    done
}

# ==============================================================================
# math::matrix::identity
# ==============================================================================

# Generate an identity matrix of given size
# Usage: math::matrix::identity "NxN"
# Returns: flat space-separated element list
# Note: only square matrices have an identity — NxN only
math::matrix::identity() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local -a _result=()
    local i j
    for (( i = 0; i < rows; i++ )); do
        for (( j = 0; j < cols; j++ )); do
            (( i == j )) && _result+=(1) || _result+=(0)
        done
    done
    echo "${_result[@]}"
}

# Generate an identity matrix, writing into output array
# Usage: math::matrix::identity::fast result "NxN"
math::matrix::identity::fast() {
    local -n _out="$1"; shift
    local rows cols
    _math::matrix::dim "$1" rows cols
    _out=()
    local i j
    for (( i = 0; i < rows; i++ )); do
        for (( j = 0; j < cols; j++ )); do
            (( i == j )) && _out+=(1) || _out+=(0)
        done
    done
}

# ==============================================================================
# math::matrix::eq
# ==============================================================================

# Check if two matrices are equal element-wise
# Usage: math::matrix::eq "RxC" a b
# Returns: 0 if equal, 1 otherwise
math::matrix::eq() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:2}"
    local i
    for (( i = 0; i < size; i++ )); do
        [[ "${_a[$i]}" != "${_b[$i]}" ]] && return 1
    done
    return 0
}

# ==============================================================================
# math::matrix::is_square
# ==============================================================================

# Check if a matrix is square (rows == cols)
# Usage: math::matrix::is_square "RxC"
# Returns: 0 if square, 1 otherwise
math::matrix::is_square() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    (( rows == cols ))
}

# ==============================================================================
# math::matrix::trace
# ==============================================================================

# Sum of diagonal elements — square matrices only
# Usage: math::matrix::trace "NxN" a
# Returns: scalar integer
# Note: for float input use math::matrix::tracef
math::matrix::trace() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:2}"
    local sum=0 i
    for (( i = 0; i < rows; i++ )); do
        sum=$(( sum + _a[$i * $cols + $i] ))
    done
    echo "$sum"
}

# Sum of diagonal elements with floating point precision
# Usage: math::matrix::tracef scale "NxN" a
# Returns: scalar float
math::matrix::tracef() {
    local scale=$1 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"
    local sum="0" i
    for (( i = 0; i < rows; i++ )); do
        sum=$(math::bc "$sum + ${_a[$i * $cols + $i]}" "$scale")
    done
    echo "$sum"
}

# ==============================================================================
# math::matrix::diagonal
# ==============================================================================

# Extract diagonal elements as a flat list
# Usage: math::matrix::diagonal "NxN" a
# Returns: flat space-separated element list
math::matrix::diagonal() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:2}"
    local -a _result=()
    local i
    for (( i = 0; i < rows; i++ )); do
        _result+=("${_a[$i * $cols + $i]}")
    done
    echo "${_result[@]}"
}

# ==============================================================================
# math::matrix::flatten
# ==============================================================================

# Flatten a matrix to a newline-separated list (one element per line)
# Usage: math::matrix::flatten "RxC" a
# Returns: one element per line
math::matrix::flatten() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:2}"
    printf '%s\n' "${_a[@]}"
}

# ==============================================================================
# math::matrix::print
# ==============================================================================

# Print a matrix in row-major human-readable format
# Usage: math::matrix::print "RxC" a
math::matrix::print() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:2}"
    local i j
    for (( i = 0; i < rows; i++ )); do
        for (( j = 0; j < cols; j++ )); do
            printf '%s ' "${_a[$i * $cols + $j]}"
        done
        echo
    done
}

# ==============================================================================
# math::matrix::hadamard — Element-wise multiplication
# ==============================================================================

# Multiply two matrices element-wise (Hadamard product)
# Usage: math::matrix::hadamard "RxC" a b
# Returns: flat space-separated element list
math::matrix::hadamard() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:2}"
    local -a _result=()
    local i
    for (( i = 0; i < size; i++ )); do
        _result+=("$(( _a[$i] * _b[$i] ))")
    done
    echo "${_result[@]}"
}

# Hadamard product, writing into output array
# Usage: math::matrix::hadamard::fast result "RxC" a b
math::matrix::hadamard::fast() {
    local -n _out="$1"; shift
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:2}"
    _out=()
    local i
    for (( i = 0; i < size; i++ )); do
        _out+=("$(( _a[$i] * _b[$i] ))")
    done
}

# Hadamard product with floating point precision
# Usage: math::matrix::hadamardf scale "RxC" a b
# Returns: flat space-separated element list
math::matrix::hadamardf() {
    local scale=$1 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:3}"
    local -a _result=()
    local i
    for (( i = 0; i < size; i++ )); do
        _result+=("$(math::bc "${_a[$i]} * ${_b[$i]}" "$scale")")
    done
    echo "${_result[@]}"
}

# Hadamard product with floating point precision, writing into output array
# Usage: math::matrix::hadamardf::fast result scale "RxC" a b
math::matrix::hadamardf::fast() {
    local -n _out="$1"; shift
    local scale=$1 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:3}"
    _out=()
    local i
    for (( i = 0; i < size; i++ )); do
        _out+=("$(math::bc "${_a[$i]} * ${_b[$i]}" "$scale")")
    done
}

# ==============================================================================
# math::matrix::minor
# ==============================================================================

# Compute the minor of a matrix — submatrix with row i and col j removed
# Usage: math::matrix::minor "NxN" row col a
# Returns: flat space-separated element list of the (N-1)x(N-1) submatrix
# Note: row and col are 0-indexed
math::matrix::minor() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local skip_row=$2 skip_col=$3
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:4}"
    local -a _result=()
    local i j
    for (( i = 0; i < rows; i++ )); do
        (( i == skip_row )) && continue
        for (( j = 0; j < cols; j++ )); do
            (( j == skip_col )) && continue
            _result+=("${_a[$i * $cols + $j]}")
        done
    done
    echo "${_result[@]}"
}

# ==============================================================================
# math::matrix::determinant — via LU decomposition (float, requires bc)
# ==============================================================================

# Compute determinant of a square matrix — requires bc
# Usage: math::matrix::determinant scale "NxN" a
# Returns: scalar float
# Note: uses LU decomposition internally for O(n³) performance.
#   intermediate steps use scale+4 precision to reduce rounding drift.
#   bc represents fractions as repeating decimals, so results for integer
#   matrices may have small floating point drift (e.g. -2.00000004 instead
#   of -2). use a higher scale and round the result if exact integers are needed.
# Warning: scale 0 will produce incorrect results due to intermediate truncation
math::matrix::determinant() {
    local scale=$1 rows cols
    local work_scale=$(( scale + 4 ))
    _math::matrix::dim "$2" rows cols
    if (( rows != cols )); then
        echo "Error: math::matrix::determinant: matrix must be square" >&2
        return 1
    fi
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"

    # LU decomposition — Doolittle method
    # U stored in upper triangle, L in lower (diagonal of L is 1)
    local n=$rows
    local -a _lu=("${_a[@]}")
    local sign=1
    local i j k pivot tmp

    for (( k = 0; k < n; k++ )); do
        # Partial pivoting
        local max_val="${_lu[$k * $n + $k]}"
        local max_row=$k
        for (( i = k + 1; i < n; i++ )); do
            local val="${_lu[$i * $n + $k]}"
            local abs_val abs_max
            abs_val=$(math::bc "if ($val < 0) { -($val) } else { ($val) }" "$work_scale")
            abs_max=$(math::bc "if ($max_val < 0) { -($max_val) } else { ($max_val) }" "$work_scale")
            if [[ $(math::bc "$abs_val > $abs_max" "$work_scale") -eq 1 ]]; then
                max_val="$val"
                max_row=$i
            fi
        done

        # Swap rows if needed
        if (( max_row != k )); then
            for (( j = 0; j < n; j++ )); do
                tmp="${_lu[$k * $n + $j]}"
                _lu[$k * $n + $j]="${_lu[$max_row * $n + $j]}"
                _lu[$max_row * $n + $j]="$tmp"
            done
            sign=$(( sign * -1 ))
        fi

        local pivot_val="${_lu[$k * $n + $k]}"
        if [[ $(math::bc "$pivot_val == 0" "$work_scale") -eq 1 ]]; then
            echo "0"
            return 0
        fi

        for (( i = k + 1; i < n; i++ )); do
            local factor
            factor=$(math::bc "${_lu[$i * $n + $k]} / $pivot_val" "$work_scale")
            _lu[$i * $n + $k]="$factor"
            for (( j = k + 1; j < n; j++ )); do
                _lu[$i * $n + $j]=$(math::bc "${_lu[$i * $n + $j]} - $factor * ${_lu[$k * $n + $j]}" "$work_scale")
            done
        done
    done

    # Determinant = sign * product of U diagonal, rounded to requested scale
    local det="$sign"
    for (( i = 0; i < n; i++ )); do
        det=$(math::bc "$det * ${_lu[$i * $n + $i]}" "$work_scale")
    done
    math::bc "$det" "$scale"
}

# ==============================================================================
# math::matrix::lu — LU decomposition (requires bc)
# ==============================================================================

# LU decomposition of a square matrix — requires bc
# Writes L and U into separate output arrays
# Usage: math::matrix::lu scale "NxN" L_out U_out a
# Note: L is lower triangular with 1s on diagonal, U is upper triangular
math::matrix::lu() {
    local scale=$1 rows cols
    _math::matrix::dim "$2" rows cols
    if (( rows != cols )); then
        echo "Error: math::matrix::lu: matrix must be square" >&2
        return 1
    fi
    local -n _L="$3" _U="$4"
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:5}"

    local n=$rows
    local -a _lu=("${_a[@]}")
    local i j k

    for (( k = 0; k < n; k++ )); do
        local pivot_val="${_lu[$k * $n + $k]}"
        for (( i = k + 1; i < n; i++ )); do
            local factor
            factor=$(math::bc "${_lu[$i * $n + $k]} / $pivot_val" "$scale")
            _lu[$i * $n + $k]="$factor"
            for (( j = k + 1; j < n; j++ )); do
                _lu[$i * $n + $j]=$(math::bc "${_lu[$i * $n + $j]} - $factor * ${_lu[$k * $n + $j]}" "$scale")
            done
        done
    done

    # Extract L and U
    _L=()
    _U=()
    for (( i = 0; i < n; i++ )); do
        for (( j = 0; j < n; j++ )); do
            if (( i > j )); then
                _L+=("${_lu[$i * $n + $j]}")
                _U+=(0)
            elif (( i == j )); then
                _L+=(1)
                _U+=("${_lu[$i * $n + $j]}")
            else
                _L+=(0)
                _U+=("${_lu[$i * $n + $j]}")
            fi
        done
    done
}

# ==============================================================================
# math::matrix::cofactor
# ==============================================================================

# Compute the cofactor matrix — requires bc
# Usage: math::matrix::cofactor scale "NxN" a
# Returns: flat space-separated element list
math::matrix::cofactor() {
    local scale=$1 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"
    local n=$rows
    local -a _result=()
    local i j sign minor_list det

    for (( i = 0; i < n; i++ )); do
        for (( j = 0; j < n; j++ )); do
            read -ra minor_list <<< "$(math::matrix::minor "${n}x${n}" "$i" "$j" "${_a[@]}")"
            local sub_dim="$(( n - 1 ))x$(( n - 1 ))"
            det=$(math::matrix::determinant "$scale" "$sub_dim" "${minor_list[@]}")
            sign=$(( (i + j) % 2 == 0 ? 1 : -1 ))
            _result+=("$(math::bc "$sign * $det" "$scale")")
        done
    done
    echo "${_result[@]}"
}

# ==============================================================================
# math::matrix::adjugate
# ==============================================================================

# Compute the adjugate (transpose of cofactor matrix) — requires bc
# Usage: math::matrix::adjugate scale "NxN" a
# Returns: flat space-separated element list
math::matrix::adjugate() {
    local scale=$1 dim=$2
    local rows cols
    _math::matrix::dim "$dim" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"
    local -a cof
    read -ra cof <<< "$(math::matrix::cofactor "$scale" "$dim" "${_a[@]}")"
    math::matrix::transpose "$dim" "${cof[@]}"
}

# ==============================================================================
# math::matrix::inverse — requires bc
# ==============================================================================

# Compute the inverse of a square matrix — requires bc
# Usage: math::matrix::inverse scale "NxN" a
# Returns: flat space-separated element list
# Warning: returns error if matrix is singular (determinant = 0)
math::matrix::inverse() {
    local scale=$1 dim=$2
    local rows cols
    _math::matrix::dim "$dim" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"

    local det
    det=$(math::matrix::determinant "$scale" "$dim" "${_a[@]}")
    if [[ $(math::bc "$det == 0" "$scale") -eq 1 ]]; then
        echo "Error: math::matrix::inverse: matrix is singular (determinant = 0)" >&2
        return 1
    fi

    local inv_det
    inv_det=$(math::bc "1 / $det" "$scale")
    local -a adj
    read -ra adj <<< "$(math::matrix::adjugate "$scale" "$dim" "${_a[@]}")"
    math::matrix::scalef "$scale" "$dim" "$inv_det" "${adj[@]}"
}

# ==============================================================================
# math::matrix::pow
# ==============================================================================

# Raise a square matrix to an integer power via repeated multiplication
# Usage: math::matrix::pow "NxN" exponent a
# Returns: flat space-separated element list
# Note: exponent must be a non-negative integer. pow 0 returns identity matrix.
math::matrix::pow() {
    local dim=$1 exp=$2
    local rows cols
    _math::matrix::dim "$dim" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"

    if (( exp == 0 )); then
        math::matrix::identity "$dim"
        return
    fi

    local -a _result=("${_a[@]}")
    local i
    for (( i = 1; i < exp; i++ )); do
        read -ra _result <<< "$(math::matrix::mul "$dim" "$dim" "${_result[@]}" "${_a[@]}")"
    done
    echo "${_result[@]}"
}

# Raise a square matrix to an integer power with floating point precision
# Usage: math::matrix::powf scale "NxN" exponent a
# Returns: flat space-separated element list
math::matrix::powf() {
    local scale=$1 dim=$2 exp=$3
    local rows cols
    _math::matrix::dim "$dim" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:4}"

    if (( exp == 0 )); then
        math::matrix::identity "$dim"
        return
    fi

    local -a _result=("${_a[@]}")
    local i
    for (( i = 1; i < exp; i++ )); do
        read -ra _result <<< "$(math::matrix::mulf "$scale" "$dim" "$dim" "${_result[@]}" "${_a[@]}")"
    done
    echo "${_result[@]}"
}

# ==============================================================================
# math::matrix::rank — via row reduction (requires bc)
# ==============================================================================

# Compute the rank of a matrix via Gaussian elimination — requires bc
# Usage: math::matrix::rank scale "RxC" a
# Returns: integer rank
math::matrix::rank() {
    local scale=$1 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"

    local -a _m=("${_a[@]}")
    local rank=0 row=0 i j k factor pivot

    for (( j = 0; j < cols && row < rows; j++ )); do
        # Find pivot in column j from row onwards
        local pivot_row=-1
        for (( i = row; i < rows; i++ )); do
            if [[ $(math::bc "${_m[$i * $cols + $j]} != 0" "$scale") -eq 1 ]]; then
                pivot_row=$i
                break
            fi
        done
        (( pivot_row == -1 )) && continue

        # Swap pivot row into position
        if (( pivot_row != row )); then
            local tmp
            for (( k = 0; k < cols; k++ )); do
                tmp="${_m[$row * $cols + $k]}"
                _m[$row * $cols + $k]="${_m[$pivot_row * $cols + $k]}"
                _m[$pivot_row * $cols + $k]="$tmp"
            done
        fi

        pivot="${_m[$row * $cols + $j]}"
        for (( i = row + 1; i < rows; i++ )); do
            factor=$(math::bc "${_m[$i * $cols + $j]} / $pivot" "$scale")
            for (( k = j; k < cols; k++ )); do
                _m[$i * $cols + $k]=$(math::bc "${_m[$i * $cols + $k]} - $factor * ${_m[$row * $cols + $k]}" "$scale")
            done
        done

        (( rank++ ))
        (( row++ ))
    done

    echo "$rank"
}

# ==============================================================================
# FLOATING POINT (requires bc)
# ==============================================================================

# Floor — largest integer ≤ n
math::floor() {
    math::bc "scale=0; $1 / 1"
}

# Ceiling — smallest integer ≥ n
math::ceil() {
    math::bc "scale=0; if ($1 == ($1 / 1)) $1 else if ($1 > 0) ($1 / 1) + 1 else ($1 / 1)"
}


# Round to nearest integer (or to d decimal places)
# Usage: math::round n [decimal_places]
math::round() {
    local n="$1" d="${2:-0}"
    math::bc "scale=${d}; (${n} + 0.5 * (${n} > 0) - 0.5 * (${n} < 0)) / 1" "$d"
}

# Square root
math::sqrt() {
    local scale="${2:-$MATH_SCALE}"
    math::bc "sqrt($1)" "$scale"
}

# Natural logarithm
math::log() {
    math::bc "l($1)"
}

# Log base 2
math::log2() {
    math::bc "l($1) / l(2)"
}

# Log base 10
math::log10() {
    math::bc "l($1) / l(10)"
}

# Log with arbitrary base
# Usage: math::logn value base
math::logn() {
    math::bc "l($1) / l($2)"
}

# Exponential e^n
math::exp() {
    math::bc "e($1)"
}

# Power (floating point)
# Usage: math::powf base exponent
math::powf() {
    math::bc "e($2 * l($1))"
}

# Sigmoid — array-primary, operates in one awk pass
# Usage: math::sigmoid arr_name [scale]
# arr_name is a nameref to an indexed array; result echoed as space-separated floats
math::sigmoid() {
    local -n _sig_in="$1"
    local scale="${2:-$MATH_SCALE}"
    local -a _result=()
    for x in "${_sig_in[@]}"; do
        _result+=("$(math::bc "1 / (1 + e(-($x)))" "$scale")")
    done
    echo "${_result[@]}"
}

# Sigmoid — single value escape hatch
# Use math::sigmoid for batch processing; this forks bc once per call
# Usage: math::sigmoid::singleton value [scale]
math::sigmoid::singleton() {
    local scale="${2:-$MATH_SCALE}"
    math::bc "1 / (1 + e(-($1)))" "$scale"
}

# Softmax — array-primary (singleton is degenerate: softmax of one value is always 1.0)
# Usage: math::softmax arr_name [temperature [scale]]
# arr_name is a nameref to an indexed array; result echoed as space-separated floats
math::softmax() {
    local -n _softmax_in="$1"
    local temperature="${2:-1}" scale="${3:-$MATH_SCALE}"
    local -a arr=("${_softmax_in[@]}")

    if ! math::has_bc; then
        echo "Error: math::softmax requires bc for floating point operation."
        return 1
    fi

    if [[ $(math::bc "$temperature < 0") -eq 1 ]]; then
        echo "Error: math::softmax: Temperature cannot be lower than 0." >&2
        return 1
    fi

    ## T=0 is treated as T=1 (neutral temperature, no sharpening or flattening)
    ## Values between 0 and 1 are valid and will sharpen the distribution

    if [[ ${#arr[@]} -lt 2 ]]; then
        echo "Error: math::softmax requires more than 1 value" >&2
        return 1
    fi

    local -a exp_arr
    local exp_x

    for x in "${arr[@]}"; do
        exp_x=$(math::bc "if ($temperature > 0) { e($x / $temperature) } else { e($x) }" $scale)
        exp_arr+=("$exp_x")
    done

    # To maintain reliability and accuracy of normalisation,
    # normaliser_sum will not have scale applied
    local normaliser_sum=0
    for x in "${exp_arr[@]}"; do
        normaliser_sum=$(math::bc "$normaliser_sum + $x")
    done

    local -a softarr
    local softx

    for x in "${exp_arr[@]}"; do
        softx=$(math::bc "$x / $normaliser_sum" $scale)
        softarr+=("$softx")
    done

    echo "${softarr[@]}"
}

# ==============================================================================
# TRIGONOMETRY (requires bc)
# All angles in radians unless noted
# ==============================================================================

math::sin() {
    math::bc "s($1)"
}

math::cos() {
    math::bc "c($1)"
}

math::tan() {
    math::bc "s($1) / c($1)"
}

math::asin() {
    math::bc "a($1 / sqrt(1 - $1^2))"
}

math::acos() {
    math::bc "a(sqrt(1 - $1^2) / $1)"
}

math::atan() {
    math::bc "a($1)"
}

math::atan2() {
    math::bc "a($1 / $2)"
}

# Convert degrees to radians
math::deg_to_rad() {
    math::bc "$1 * $MATH_PI / 180"
}

# Convert radians to degrees
math::rad_to_deg() {
    math::bc "$1 * 180 / $MATH_PI"
}

# ==============================================================================
# PERCENTAGE / RATIO
# ==============================================================================

# Calculate percentage: (part / total) * 100
# Usage: math::percent part total [scale]
math::percent() {
    local part="$1" total="$2" scale="${3:-2}"
    math::bc "($part / $total) * 100" "$scale"
}

# Calculate what value is p% of total
# Usage: math::percent_of percent total [scale]
math::percent_of() {
    local pct="$1" total="$2" scale="${3:-2}"
    math::bc "($pct / 100) * $total" "$scale"
}

# Percentage change from old to new
# Usage: math::percent_change old new [scale]
math::percent_change() {
    local old="$1" new="$2" scale="${3:-2}"
    math::bc "(($new - $old) / $old) * 100" "$scale"
}

# ==============================================================================
# INTERPOLATION / MAPPING
# ==============================================================================

# Linear interpolation between a and b by factor t (0.0 - 1.0)
# Usage: math::lerp a b t [scale]
math::lerp() {
    local a="$1" b="$2" t="$3" scale="${4:-$MATH_SCALE}"
    math::bc "$a + ($b - $a) * $(math::clampf "$t" 0 1)" "$scale"
}

math::lerp_unclamped() {
    local a="$1" b="$2" t="$3" scale="${4:-$MATH_SCALE}"
    math::bc "$a + $t * ($b - $a)" "$scale"
}

# Map a value from one range to another
# Usage: math::map value in_min in_max out_min out_max [scale]
math::map() {
    local v="$1" imin="$2" imax="$3" omin="$4" omax="$5" scale="${6:-$MATH_SCALE}"
    math::bc "($v - $imin) * ($omax - $omin) / ($imax - $imin) + $omin" "$scale"
}

# Normalise a value to 0.0-1.0 range
# Usage: math::normalize value min max [scale]
math::normalize() {
    local v="$1" lo="$2" hi="$3" scale="${4:-$MATH_SCALE}"
    math::bc "($v - $lo) / ($hi - $lo)" "$scale"
}

# ==============================================================================
# NUMBER THEORY / COMBINATORICS
# ==============================================================================

# Binomial coefficient C(n, k) — "n choose k"
# Usage: math::choose n k
math::choose() {
    local n="$1" k="$2"
    _math::is_float "$n" || _math::is_float "$k" && { echo "math::choose: float input — choose is integer-only" >&2; return 1; }
    (( k > n )) && echo 0 && return
    (( k == 0 || k == n )) && echo 1 && return
    # Use the smaller of k and n-k for efficiency
    (( k > n - k )) && k=$(( n - k ))
    local result=1 i
    for (( i=0; i<k; i++ )); do
        result=$(( result * (n - i) / (i + 1) ))
    done
    echo "$result"
}

# Number of permutations P(n, k)
# Usage: math::permute n k
math::permute() {
    local n="$1" k="$2" result=1 i
    _math::is_float "$n" || _math::is_float "$k" && { echo "math::permute: float input — permute is integer-only" >&2; return 1; }
    for (( i=0; i<k; i++ )); do
        result=$(( result * (n - i) ))
    done
    echo "$result"
}

# Sum of digits of an integer
math::digit_sum() {
    local n="${1#-}" sum=0  # strip sign
    while (( n > 0 )); do
        (( sum += n % 10 ))
        (( n /= 10 ))
    done
    echo "$sum"
}

# Count number of digits
math::digit_count() {
    local n="${1#-}"
    (( n == 0 )) && echo 1 && return
    local count=0
    while (( n > 0 )); do
        (( count++ ))
        (( n /= 10 ))
    done
    echo "$count"
}

# Reverse digits of an integer
math::digit_reverse() {
    local n="${1#-}" sign="" result=0
    [[ "$1" == -* ]] && sign="-"
    while (( n > 0 )); do
        result=$(( result * 10 + n % 10 ))
        (( n /= 10 ))
    done
    echo "${sign}${result}"
}

# Check if integer is a palindrome
math::is_palindrome() {
    local n="${1#-}"
    local rev
    rev=$(math::digit_reverse "$n")
    (( n == rev ))
}

# math::unitconvert — universal unit conversion dispatcher
# Usage: math::unitconvert from to value [scale]
# Example: math::unitconvert km mi 100
#          math::unitconvert femtosecond nanosecond 1000
#          math::unitconvert b gib 1073741824

math::unitconvert() {
    local from="${1,,}" to="${2,,}" value="$3" scale="${4:-$MATH_SCALE}"

    [[ -z "$from" || -z "$to" || -z "$value" ]] && {
        echo "Usage: math::unitconvert <from> <to> <value> [scale]" >&2
        return 1
    }

    # Normalise verbose/alternative names to canonical short keys
    # from and to is duplicated for optimisation
    case "$from" in
        celsius|centigrade)                          from="celsius" ;;
        fahrenheit)                                  from="fahrenheit" ;;
        kelvin)                                      from="kelvin" ;;
        femtometre|femtometer|femtometres|femtometers) from="fm" ;;
        picometre|picometer|picometres|picometers)   from="pm" ;;
        nanometre_si|nanometer_si)                   from="nm_si" ;;
        micrometre|micrometer|micrometres|micrometers|um) from="um" ;;
        millimetre|millimeter|millimetres|millimeters|mm) from="mm" ;;
        centimetre|centimeter|centimetres|centimeters|cm) from="cm" ;;
        metre|meter|metres|meters)                   from="m" ;;
        kilometre|kilometer|kilometres|kilometers|km) from="km" ;;
        inch|inches)                                 from="in" ;;
        foot|feet)                                   from="ft" ;;
        yard|yards)                                  from="yd" ;;
        mile|miles)                                  from="mi" ;;
        nautical_mile|nautical_miles)                from="nm" ;;
        astronomical_unit|astronomical_units)        from="au" ;;
        light_year|lightyear|light_years|lightyears) from="ly" ;;
        light_hour|lighthour|light_hours|lighthours) from="lh" ;;
        light_day|lightday|light_days|lightdays)     from="ld" ;;
        parsec|parsecs)                              from="pc" ;;
        microgram|micrograms)                        from="ug" ;;
        milligram|milligrams|mg)                     from="mg" ;;
        gram|grams)                                  from="g" ;;
        kilogram|kilograms|kg)                       from="kg" ;;
        tonne|metric_ton|metric_tons)                from="t" ;;
        ounce|ounces)                                from="oz" ;;
        pound|pounds|lbs)                            from="lb" ;;
        stone|stones)                                from="st" ;;
        millilitre|milliliter|millilitres|milliliters|ml) from="ml" ;;
        litre|liter|litres|liters)                   from="l" ;;
        cubic_metre|cubic_meter)                     from="m3" ;;
        teaspoon|teaspoons)                          from="tsp" ;;
        tablespoon|tablespoons)                      from="tbsp" ;;
        fluid_ounce|fluid_ounces)                    from="floz" ;;
        pint|pints)                                  from="pt" ;;
        quart|quarts)                                from="qt" ;;
        gallon|gallons)                              from="gal" ;;
        kph|km_h|kilometres_per_hour|kilometers_per_hour) from="kmh" ;;
        mph|miles_per_hour)                          from="mph" ;;
        m_s|metres_per_second|meters_per_second)     from="ms" ;;
        knot|knots)                                  from="knot" ;;
        mach)                                        from="mach" ;;
        speed_of_light)                              from="c" ;;
        pascal|pascals)                              from="pa" ;;
        kilopascal|kilopascals)                      from="kpa" ;;
        bar|bars)                                    from="bar" ;;
        atmosphere|atmospheres)                      from="atm" ;;
        pounds_per_square_inch)                      from="psi" ;;
        millimetre_of_mercury|millimeter_of_mercury|torr) from="mmhg" ;;
        joule|joules)                                from="j" ;;
        kilojoule|kilojoules)                        from="kj" ;;
        calorie|calories)                            from="cal" ;;
        kilocalorie|kilocalories)                    from="kcal" ;;
        kilowatt_hour|kilowatt_hours)                from="kwh" ;;
        electronvolt|electronvolts)                  from="ev" ;;
        british_thermal_unit|british_thermal_units)  from="btu" ;;
        watt|watts)                                  from="w" ;;
        kilowatt|kilowatts)                          from="kw" ;;
        horsepower)                                  from="hp" ;;
        bit|bits)                                    from="b" ;;
        kilobit|kilobits)                            from="kb" ;;
        megabit|megabits)                            from="mb" ;;
        gigabit|gigabits)                            from="gb" ;;
        terabit|terabits)                            from="tb" ;;
        petabit|petabits)                            from="pb" ;;
        kibibit|kibibits)                            from="kib" ;;
        mebibit|mebibits)                            from="mib" ;;
        gibibit|gibibits)                            from="gib" ;;
        tebibit|tebibits)                            from="tib" ;;
        pebibit|pebibits)                            from="pib" ;;
        sector|sectors|512b)                         from="sector" ;;
        sector4k|4k_sector|advanced_format)          from="sector4k" ;;
        femtosecond|femtoseconds)                    from="fs" ;;
        picosecond|picoseconds)                      from="ps" ;;
        nanosecond|nanoseconds|ns)                   from="ns" ;;
        microsecond|microseconds|us)                 from="us" ;;
        millisecond|milliseconds|ms)                 from="ms" ;;
        second|seconds|sec)                          from="s" ;;
        minute|minutes)                              from="min" ;;
        hour|hours|hr)                               from="h" ;;
        day|days)                                    from="d" ;;
        week|weeks)                                  from="week" ;;
        year|years|yr)                               from="year" ;;
        degree|degrees)                              from="deg" ;;
        radian|radians)                              from="rad" ;;
        gradian|gradians|gon)                        from="grad" ;;
        arcminute|arcminutes)                        from="arcmin" ;;
        arcsecond|arcseconds)                        from="arcsec" ;;
    esac

    case "$to" in
        celsius|centigrade)                          to="celsius" ;;
        fahrenheit)                                  to="fahrenheit" ;;
        kelvin)                                      to="kelvin" ;;
        femtometre|femtometer|femtometres|femtometers) to="fm" ;;
        picometre|picometer|picometres|picometers)   to="pm" ;;
        nanometre_si|nanometer_si)                   to="nm_si" ;;
        micrometre|micrometer|micrometres|micrometers|um) to="um" ;;
        millimetre|millimeter|millimetres|millimeters|mm) to="mm" ;;
        centimetre|centimeter|centimetres|centimeters|cm) to="cm" ;;
        metre|meter|metres|meters)                   to="m" ;;
        kilometre|kilometer|kilometres|kilometers|km) to="km" ;;
        inch|inches)                                 to="in" ;;
        foot|feet)                                   to="ft" ;;
        yard|yards)                                  to="yd" ;;
        mile|miles)                                  to="mi" ;;
        nautical_mile|nautical_miles)                to="nm" ;;
        astronomical_unit|astronomical_units)        to="au" ;;
        light_year|lightyear|light_years|lightyears) to="ly" ;;
        light_hour|lighthour|light_hours|lighthours) to="lh" ;;
        light_day|lightday|light_days|lightdays)     to="ld" ;;
        parsec|parsecs)                              to="pc" ;;
        microgram|micrograms)                        to="ug" ;;
        milligram|milligrams|mg)                     to="mg" ;;
        gram|grams)                                  to="g" ;;
        kilogram|kilograms|kg)                       to="kg" ;;
        tonne|metric_ton|metric_tons)                to="t" ;;
        ounce|ounces)                                to="oz" ;;
        pound|pounds|lbs)                            to="lb" ;;
        stone|stones)                                to="st" ;;
        millilitre|milliliter|millilitres|milliliters|ml) to="ml" ;;
        litre|liter|litres|liters)                   to="l" ;;
        cubic_metre|cubic_meter)                     to="m3" ;;
        teaspoon|teaspoons)                          to="tsp" ;;
        tablespoon|tablespoons)                      to="tbsp" ;;
        fluid_ounce|fluid_ounces)                    to="floz" ;;
        pint|pints)                                  to="pt" ;;
        quart|quarts)                                to="qt" ;;
        gallon|gallons)                              to="gal" ;;
        kph|km_h|kilometres_per_hour|kilometers_per_hour) to="kmh" ;;
        mph|miles_per_hour)                          to="mph" ;;
        m_s|metres_per_second|meters_per_second)     to="ms" ;;
        knot|knots)                                  to="knot" ;;
        mach)                                        to="mach" ;;
        speed_of_light)                              to="c" ;;
        pascal|pascals)                              to="pa" ;;
        kilopascal|kilopascals)                      to="kpa" ;;
        bar|bars)                                    to="bar" ;;
        atmosphere|atmospheres)                      to="atm" ;;
        pounds_per_square_inch)                      to="psi" ;;
        millimetre_of_mercury|millimeter_of_mercury|torr) to="mmhg" ;;
        joule|joules)                                to="j" ;;
        kilojoule|kilojoules)                        to="kj" ;;
        calorie|calories)                            to="cal" ;;
        kilocalorie|kilocalories)                    to="kcal" ;;
        kilowatt_hour|kilowatt_hours)                to="kwh" ;;
        electronvolt|electronvolts)                  to="ev" ;;
        british_thermal_unit|british_thermal_units)  to="btu" ;;
        watt|watts)                                  to="w" ;;
        kilowatt|kilowatts)                          to="kw" ;;
        horsepower)                                  to="hp" ;;
        bit|bits)                                    to="b" ;;
        kilobit|kilobits)                            to="kb" ;;
        megabit|megabits)                            to="mb" ;;
        gigabit|gigabits)                            to="gb" ;;
        terabit|terabits)                            to="tb" ;;
        petabit|petabits)                            to="pb" ;;
        kibibit|kibibits)                            to="kib" ;;
        mebibit|mebibits)                            to="mib" ;;
        gibibit|gibibits)                            to="gib" ;;
        tebibit|tebibits)                            to="tib" ;;
        pebibit|pebibits)                            to="pib" ;;
        sector|sectors|512b)                         to="sector" ;;
        sector4k|4k_sector|advanced_format)          to="sector4k" ;;
        femtosecond|femtoseconds)                    to="fs" ;;
        picosecond|picoseconds)                      to="ps" ;;
        nanosecond|nanoseconds|ns)                   to="ns" ;;
        microsecond|microseconds|us)                 to="us" ;;
        millisecond|milliseconds|ms)                 to="ms" ;;
        second|seconds|sec)                          to="s" ;;
        minute|minutes)                              to="min" ;;
        hour|hours|hr)                               to="h" ;;
        day|days)                                    to="d" ;;
        week|weeks)                                  to="week" ;;
        year|years|yr)                               to="year" ;;
        degree|degrees)                              to="deg" ;;
        radian|radians)                              to="rad" ;;
        gradian|gradians|gon)                        to="grad" ;;
        arcminute|arcminutes)                        to="arcmin" ;;
        arcsecond|arcseconds)                        to="arcsec" ;;
    esac

    [[ "$from" == "$to" ]] && echo "$value" && return 0


    local key="${from}:${to}"
    local expr

    case "$key" in

    # --- Temperature ---
    celsius:fahrenheit  | c:f)    expr="$value * 9/5 + 32" ;;
    fahrenheit:celsius  | f:c)    expr="($value - 32) * 5/9" ;;
    celsius:kelvin      | c:k)    expr="$value + 273.15" ;;
    kelvin:celsius      | k:c)    expr="$value - 273.15" ;;
    fahrenheit:kelvin   | f:k)    expr="($value - 32) * 5/9 + 273.15" ;;
    kelvin:fahrenheit   | k:f)    expr="($value - 273.15) * 9/5 + 32" ;;

    # --- Length ---
    km:mi)              expr="$value * 0.621371" ;;
    mi:km)              expr="$value * 1.609344" ;;
    m:ft)               expr="$value * 3.28084" ;;
    ft:m)               expr="$value * 0.3048" ;;
    cm:in)              expr="$value * 0.393701" ;;
    in:cm)              expr="$value * 2.54" ;;
    m:yd)               expr="$value * 1.09361" ;;
    yd:m)               expr="$value * 0.9144" ;;
    mm:in)              expr="$value * 0.0393701" ;;
    in:mm)              expr="$value * 25.4" ;;
    m:km)               expr="$value / 1000" ;;
    km:m)               expr="$value * 1000" ;;
    cm:m)               expr="$value / 100" ;;
    m:cm)               expr="$value * 100" ;;
    mm:m)               expr="$value / 1000" ;;
    m:mm)               expr="$value * 1000" ;;
    cm:mm)              expr="$value * 10" ;;
    mm:cm)              expr="$value / 10" ;;
    nm_si:m)            expr="$value / 1000000000" ;;
    m:nm_si)            expr="$value * 1000000000" ;;
    pm:m)               expr="$value / 1000000000000" ;;
    m:pm)               expr="$value * 1000000000000" ;;
    fm:m)               expr="$value / 1000000000000000" ;;
    m:fm)               expr="$value * 1000000000000000" ;;
    fm:pm)              expr="$value / 1000" ;;
    pm:fm)              expr="$value * 1000" ;;
    nm_si:pm)           expr="$value * 1000" ;;
    pm:nm_si)           expr="$value / 1000" ;;
    nm_si:fm)           expr="$value * 1000000" ;;
    fm:nm_si)           expr="$value / 1000000" ;;
    nm:km)              expr="$value * 1.852" ;;
    km:nm)              expr="$value / 1.852" ;;
    ly:km)              expr="$value * 9460730472580.8" ;;
    km:ly)              expr="$value / 9460730472580.8" ;;
    lh:km)              expr="$value * 1079251200" ;;
    km:lh)              expr="$value / 1079251200" ;;
    ld:km)              expr="$value * 25902068371.2" ;;
    km:ld)              expr="$value / 25902068371.2" ;;
    lh:ly)              expr="$value / 8765.81" ;;
    ly:lh)              expr="$value * 8765.81" ;;
    ld:ly)              expr="$value / 365.25" ;;
    ly:ld)              expr="$value * 365.25" ;;
    ld:lh)              expr="$value * 24" ;;
    lh:ld)              expr="$value / 24" ;;
    au:km)              expr="$value * 149597870.7" ;;
    km:au)              expr="$value / 149597870.7" ;;
    pc:ly)              expr="$value * 3.26156" ;;
    ly:pc)              expr="$value / 3.26156" ;;
    pc:km)              expr="$value * 30856775814913.7" ;;
    km:pc)              expr="$value / 30856775814913.7" ;;

    # --- Mass ---
    kg:lb)              expr="$value * 2.20462" ;;
    lb:kg)              expr="$value * 0.453592" ;;
    g:oz)               expr="$value * 0.035274" ;;
    oz:g)               expr="$value * 28.3495" ;;
    g:kg)               expr="$value / 1000" ;;
    kg:g)               expr="$value * 1000" ;;
    mg:g)               expr="$value / 1000" ;;
    g:mg)               expr="$value * 1000" ;;
    t:kg)               expr="$value * 1000" ;;
    kg:t)               expr="$value / 1000" ;;
    t:lb)               expr="$value * 2204.62" ;;
    lb:t)               expr="$value / 2204.62" ;;
    st:kg)              expr="$value * 6.35029" ;;
    kg:st)              expr="$value / 6.35029" ;;

    # --- Volume ---
    l:gal)              expr="$value * 0.264172" ;;
    gal:l)              expr="$value * 3.78541" ;;
    ml:floz)            expr="$value * 0.033814" ;;
    floz:ml)            expr="$value * 29.5735" ;;
    l:pt)               expr="$value * 2.11338" ;;
    pt:l)               expr="$value / 2.11338" ;;
    ml:l)               expr="$value / 1000" ;;
    l:ml)               expr="$value * 1000" ;;
    l:qt)               expr="$value * 1.05669" ;;
    qt:l)               expr="$value / 1.05669" ;;
    m3:l)               expr="$value * 1000" ;;
    l:m3)               expr="$value / 1000" ;;
    tsp:ml)             expr="$value * 4.92892" ;;
    ml:tsp)             expr="$value / 4.92892" ;;
    tbsp:ml)            expr="$value * 14.7868" ;;
    ml:tbsp)            expr="$value / 14.7868" ;;

    # --- Speed ---
    kmh:mph)            expr="$value * 0.621371" ;;
    mph:kmh)            expr="$value * 1.609344" ;;
    ms:kmh)             expr="$value * 3.6" ;;
    kmh:ms)             expr="$value / 3.6" ;;
    ms:mph)             expr="$value * 2.23694" ;;
    mph:ms)             expr="$value / 2.23694" ;;
    knot:kmh)           expr="$value * 1.852" ;;
    kmh:knot)           expr="$value / 1.852" ;;
    knot:mph)           expr="$value * 1.15078" ;;
    mph:knot)           expr="$value / 1.15078" ;;
    mach:ms)            expr="$value * 343" ;;
    ms:mach)            expr="$value / 343" ;;
    c:ms)               expr="299792458" ;;

    # --- Pressure ---
    pa:psi)             expr="$value * 0.000145038" ;;
    psi:pa)             expr="$value * 6894.76" ;;
    atm:pa)             expr="$value * 101325" ;;
    pa:atm)             expr="$value / 101325" ;;
    bar:pa)             expr="$value * 100000" ;;
    pa:bar)             expr="$value / 100000" ;;
    atm:bar)            expr="$value * 1.01325" ;;
    bar:atm)            expr="$value / 1.01325" ;;
    mmhg:pa)            expr="$value * 133.322" ;;
    pa:mmhg)            expr="$value / 133.322" ;;

    # --- Energy ---
    j:cal)              expr="$value * 0.239006" ;;
    cal:j)              expr="$value * 4.18400" ;;
    j:kwh)              expr="$value / 3600000" ;;
    kwh:j)              expr="$value * 3600000" ;;
    j:btu)              expr="$value * 0.000947817" ;;
    btu:j)              expr="$value / 0.000947817" ;;
    ev:j)               expr="$value * 0.0000000000000000001602176634" ;;
    j:ev)               expr="$value / 0.0000000000000000001602176634" ;;
    kcal:j)             expr="$value * 4184" ;;
    j:kcal)             expr="$value / 4184" ;;

    # --- Power ---
    w:hp)               expr="$value * 0.00134102" ;;
    hp:w)               expr="$value / 0.00134102" ;;
    w:kw)               expr="$value / 1000" ;;
    kw:w)               expr="$value * 1000" ;;
    kw:hp)              expr="$value * 1.34102" ;;
    hp:kw)              expr="$value / 1.34102" ;;

    # --- Digital storage ---
    b:kb)               expr="$value / 1000" ;;
    kb:b)               expr="$value * 1000" ;;
    b:mb)               expr="$value / 1000000" ;;
    mb:b)               expr="$value * 1000000" ;;
    b:gb)               expr="$value / 1000000000" ;;
    gb:b)               expr="$value * 1000000000" ;;
    b:tb)               expr="$value / 1000000000000" ;;
    tb:b)               expr="$value * 1000000000000" ;;
    kb:mb)              expr="$value / 1000" ;;
    mb:kb)              expr="$value * 1000" ;;
    mb:gb)              expr="$value / 1000" ;;
    gb:mb)              expr="$value * 1000" ;;
    gb:tb)              expr="$value / 1000" ;;
    tb:gb)              expr="$value * 1000" ;;
    tb:pb)              expr="$value / 1000" ;;
    pb:tb)              expr="$value * 1000" ;;
    b:kib)              expr="$value / 1024" ;;
    kib:b)              expr="$value * 1024" ;;
    b:mib)              expr="$value / 1048576" ;;
    mib:b)              expr="$value * 1048576" ;;
    b:gib)              expr="$value / 1073741824" ;;
    gib:b)              expr="$value * 1073741824" ;;
    b:tib)              expr="$value / 1099511627776" ;;
    tib:b)              expr="$value * 1099511627776" ;;
    kib:mib)            expr="$value / 1024" ;;
    mib:kib)            expr="$value * 1024" ;;
    mib:gib)            expr="$value / 1024" ;;
    gib:mib)            expr="$value * 1024" ;;
    gib:tib)            expr="$value / 1024" ;;
    tib:gib)            expr="$value * 1024" ;;
    tib:pib)            expr="$value / 1024" ;;
    pib:tib)            expr="$value * 1024" ;;
    sector:b)           expr="$value * 512" ;;
    b:sector)           expr="$value / 512" ;;
    sector:kb)          expr="$value / 2" ;;
    kb:sector)          expr="$value * 2" ;;
    sector:mb)          expr="$value / 2000" ;;
    mb:sector)          expr="$value * 2000" ;;
    sector:gb)          expr="$value / 2000000" ;;
    gb:sector)          expr="$value * 2000000" ;;
    sector:kib)         expr="$value / 2" ;;
    kib:sector)         expr="$value * 2" ;;
    sector:mib)         expr="$value / 2048" ;;
    mib:sector)         expr="$value * 2048" ;;
    sector:gib)         expr="$value / 2097152" ;;
    gib:sector)         expr="$value * 2097152" ;;
    sector4k:b)         expr="$value * 4096" ;;
    b:sector4k)         expr="$value / 4096" ;;
    sector4k:kib)       expr="$value * 4" ;;
    kib:sector4k)       expr="$value / 4" ;;
    sector4k:mib)       expr="$value / 256" ;;
    mib:sector4k)       expr="$value * 256" ;;
    sector4k:gib)       expr="$value / 262144" ;;
    gib:sector4k)       expr="$value * 262144" ;;
    sector:sector4k)    expr="$value / 8" ;;
    sector4k:sector)    expr="$value * 8" ;;

    # --- Time ---
    s:ms)               expr="$value * 1000" ;;
    ms:s)               expr="$value / 1000" ;;
    s:us)               expr="$value * 1000000" ;;
    us:s)               expr="$value / 1000000" ;;
    s:ns)               expr="$value * 1000000000" ;;
    ns:s)               expr="$value / 1000000000" ;;
    s:ps)               expr="$value * 1000000000000" ;;
    ps:s)               expr="$value / 1000000000000" ;;
    s:fs)               expr="$value * 1000000000000000" ;;
    fs:s)               expr="$value / 1000000000000000" ;;
    ms:us)              expr="$value * 1000" ;;
    us:ms)              expr="$value / 1000" ;;
    us:ns)              expr="$value * 1000" ;;
    ns:us)              expr="$value / 1000" ;;
    ns:ps)              expr="$value * 1000" ;;
    ps:ns)              expr="$value / 1000" ;;
    ps:fs)              expr="$value * 1000" ;;
    fs:ps)              expr="$value / 1000" ;;
    fs:ns)              expr="$value / 1000000" ;;
    ns:fs)              expr="$value * 1000000" ;;
    fs:us)              expr="$value / 1000000000" ;;
    us:fs)              expr="$value * 1000000000" ;;
    fs:ms)              expr="$value / 1000000000000" ;;
    ms:fs)              expr="$value * 1000000000000" ;;
    s:min)              expr="$value / 60" ;;
    min:s)              expr="$value * 60" ;;
    min:ms)             expr="$value * 60000" ;;
    ms:min)             expr="$value / 60000" ;;
    min:h)              expr="$value / 60" ;;
    h:min)              expr="$value * 60" ;;
    h:s)                expr="$value * 3600" ;;
    s:h)                expr="$value / 3600" ;;
    h:d)                expr="$value / 24" ;;
    d:h)                expr="$value * 24" ;;
    d:s)                expr="$value * 86400" ;;
    s:d)                expr="$value / 86400" ;;
    d:week)             expr="$value / 7" ;;
    week:d)             expr="$value * 7" ;;
    d:year)             expr="$value / 365.25" ;;
    year:d)             expr="$value * 365.25" ;;

    # --- Angle ---
    deg:rad)            expr="$value * 3.141592653589793238462643383279502884197169 / 180" ;;
    rad:deg)            expr="$value * 180 / 3.141592653589793238462643383279502884197169" ;;
    deg:grad)           expr="$value * 400 / 360" ;;
    grad:deg)           expr="$value * 360 / 400" ;;
    rad:grad)           expr="$value * 200 / 3.141592653589793238462643383279502884197169" ;;
    grad:rad)           expr="$value * 3.141592653589793238462643383279502884197169 / 200" ;;
    deg:arcmin)         expr="$value * 60" ;;
    arcmin:deg)         expr="$value / 60" ;;
    deg:arcsec)         expr="$value * 3600" ;;
    arcsec:deg)         expr="$value / 3600" ;;
    arcmin:arcsec)      expr="$value * 60" ;;
    arcsec:arcmin)      expr="$value / 60" ;;

    *)
        echo "math::unitconvert: unknown conversion '${from}' → '${to}'" >&2
        return 1
        ;;
    esac

    math::bc "$expr" "$scale"
}
