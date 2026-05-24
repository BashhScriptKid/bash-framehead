#!/usr/bin/env bash
# random.sh — bash-frameheader PRNG museum lib
#
# A collection of pseudorandom number generator algorithms, from historical
# curiosities to modern high-quality generators. Each is self-contained and
# educational. All operate on caller-supplied state — no hidden globals.
#
# IMPORTANT: None of these are cryptographically secure. For security-sensitive
# use, read from /dev/urandom directly.
#
# NOTE ON BASH ARITHMETIC:
# Bash uses signed 64-bit integers. 32-bit algorithms mask results to
# 0xFFFFFFFF to simulate unsigned 32-bit overflow correctly. 64-bit algorithms
# are subject to signed overflow on very large values — results may differ
# from reference C implementations.

# ==============================================================================
# HELPERS
# ==============================================================================

# Mask a value to unsigned 32-bit range
_random::mask32() {
    echo $(( $1 & 0xFFFFFFFF ))
}

# Rotate left (32-bit)
_random::rotl32() {
    local x="$1" n="$2"
    echo $(( ((x << n) | (x >> (32 - n))) & 0xFFFFFFFF ))
}

# Rotate left (64-bit, best-effort under signed 64-bit bash arithmetic)
_random::rotl64() {
    local x="$1" n="$2"
    echo $(( (x << n) | (x >> (64 - n)) ))
}

# Seed from /dev/urandom — returns a 32-bit unsigned integer
random::seed32() {
    od -An -N4 -tu4 /dev/urandom 2>/dev/null | tr -d ' \n' || echo "$RANDOM"
}

# Seed from /dev/urandom — returns a 64-bit value (may be negative in bash)
random::seed64() {
    od -An -N8 -tu8 /dev/urandom 2>/dev/null | tr -d ' \n' \
        || echo "$(( RANDOM * 32768 + RANDOM ))"
}

# ==============================================================================
# NATIVE
# Period: 2^15. Quality: poor. Use: quick throwaway needs only.
# Bash's built-in $RANDOM — 15-bit LCG, reseeds from PID+time on subshell.
# ==============================================================================

random::native() {
    echo "$RANDOM"
}

# Returns a value in [min, max] inclusive
# Usage: random::native::range min max
random::native::range() {
    local min="$1" max="$2"
    echo $(( (RANDOM % (max - min + 1)) + min ))
}

# ==============================================================================
# SECURE
# Quality: cryptographic. Use: security-sensitive.
# Bash 5.1+ $SRANDOM — 32-bit CSRNG via getrandom()/getentropy().
# Unlike $RANDOM (15-bit LCG), this is suitable for tokens, keys, and nonces.
# ==============================================================================

# Echo a 32-bit cryptographically secure random integer.
# Usage: random::secure
random::secure() {
    if [[ -z "${SRANDOM:-}" ]]; then
        echo "random::secure: requires Bash 5.1+ (SRANDOM not available)" >&2; return 1
    fi
    echo "$SRANDOM"
}

# Secure random in [min, max] inclusive.
# Usage: random::secure::range min max
random::secure::range() {
    if [[ -z "${SRANDOM:-}" ]]; then
        echo "random::secure::range: requires Bash 5.1+" >&2; return 1
    fi
    local min="$1" max="$2"
    echo $(( (SRANDOM % (max - min + 1)) + min ))
}

# ==============================================================================
# MIDDLE SQUARE
# Period: variable, often very short. Quality: very poor. Use: historical demo.
# John von Neumann, 1946. The original PRNG. Notorious for degenerating to
# zero for many seeds. Use only for educational purposes.
# ==============================================================================

# Usage: random::middle_square seed
# Returns: next value (4-digit middle square extract)
# WARNING: Degenerates to 0 for many seeds. Short cycles are common.
random::middle_square() {
    local x="$1"
    local squared=$(( x * x ))
    echo $(( (squared / 100) % 10000 ))
}

# ==============================================================================
# LINEAR CONGRUENTIAL GENERATOR (LCG)
# Period: 2^32. Quality: poor-moderate. Use: simple simulations, not security.
# Classic algorithm, used in early C stdlib rand() implementations.
# Numerical Recipes parameters (Press et al.)
# ==============================================================================

# Usage: random::lcg state
# Returns: next state (also the output value)
random::lcg() {
    _random::mask32 $(( $1 * 1664525 + 1013904223 ))
}

# Glibc rand() parameters
random::lcg::glibc() {
    _random::mask32 $(( $1 * 1103515245 + 12345 ))
}

# ==============================================================================
# XORSHIFT32
# Period: 2^32-1. Quality: moderate. Use: fast non-secure generation.
# George Marsaglia, 2003. Simple bitwise operations only.
# ==============================================================================

# Usage: random::xorshift32 state
# Returns: next state (also the output value)
random::xorshift32() {
    local x
    x=$(_random::mask32 "$1")
    x=$(( x ^ (x << 13) )); x=$(_random::mask32 $x)
    x=$(( x ^ (x >> 17) ))
    x=$(( x ^ (x << 5)  )); x=$(_random::mask32 $x)
    echo "$x"
}

# ==============================================================================
# XORSHIFT64
# Period: 2^64-1. Quality: moderate. Use: fast non-secure generation.
# George Marsaglia, 2003. 64-bit variant.
# ==============================================================================

# Usage: random::xorshift64 state
# Returns: next state (also the output value)
random::xorshift64() {
    local x="$1"
    x=$(( x ^ (x << 13) ))
    x=$(( x ^ (x >> 7)  ))
    x=$(( x ^ (x << 17) ))
    echo "$x"
}

# ==============================================================================
# XORSHIFT128+
# Period: 2^128-1. Quality: good (passes most BigCrush tests). Use: general purpose.
# Sebastiano Vigna, 2014. Used in V8, SpiderMonkey, and WebKit Math.random().
# State: two 64-bit values (s0, s1).
# ==============================================================================

# Usage: random::xorshiftr128plus s0 s1
# Returns: "result s0_new s1_new"
# Caller must unpack and pass s0_new/s1_new on the next call:
#   read -r val s0 s1 <<< "$(random::xorshiftr128plus $s0 $s1)"
random::xorshiftr128plus() {
    local s0="$1" s1="$2"

    local result=$(( s0 + s1 ))
    s1=$(( s1 ^ s0 ))
    s0=$(( $(_random::rotl64 $s0 23) ^ s1 ^ (s1 << 17) ))
    s1=$(_random::rotl64 $s1 26)

    echo "$result $s0 $s1"
}

# ==============================================================================
# XOSHIRO256** (star-star)
# Period: 2^256-1. Quality: excellent. Use: general purpose, floating point.
# Blackman & Vigna, 2018. Successor to xorshift128+. State: four 64-bit values.
# ==============================================================================

# Usage: random::xoshiro256ss s0 s1 s2 s3
# Returns: "result s0_new s1_new s2_new s3_new"
#   read -r val s0 s1 s2 s3 <<< "$(random::xoshiro256ss $s0 $s1 $s2 $s3)"
random::xoshiro256ss() {
    local s0="$1" s1="$2" s2="$3" s3="$4"

    local result
    result=$(_random::rotl64 $(( s1 * 5 )) 7)
    result=$(( result * 9 ))
    local t=$(( s1 << 17 ))

    s2=$(( s2 ^ s0 ))
    s3=$(( s3 ^ s1 ))
    s1=$(( s1 ^ s2 ))
    s0=$(( s0 ^ s3 ))
    s2=$(( s2 ^ t ))
    s3=$(_random::rotl64 $s3 45)

    echo "$result $s0 $s1 $s2 $s3"
}

# Xoshiro256+ — faster output, slightly weaker low bits
# Usage: same as xoshiro256ss
random::xoshiro256p() {
    local s0="$1" s1="$2" s2="$3" s3="$4"

    local result=$(( s0 + s3 ))
    local t=$(( s1 << 17 ))

    s2=$(( s2 ^ s0 ))
    s3=$(( s3 ^ s1 ))
    s1=$(( s1 ^ s2 ))
    s0=$(( s0 ^ s3 ))
    s2=$(( s2 ^ t ))
    s3=$(_random::rotl64 $s3 45)

    echo "$result $s0 $s1 $s2 $s3"
}

# ==============================================================================
# PCG32 (Permuted Congruential Generator)
# Period: 2^64. Quality: excellent. Use: general purpose, simulation.
# Melissa O'Neill, 2014. LCG base with permutation output function.
# Passes all known statistical tests. inc must be odd (enforced internally).
# ==============================================================================

# Usage: random::pcg32 state inc
# Returns: "result new_state"
#   read -r val state <<< "$(random::pcg32 $state $inc)"
random::pcg32() {
    local state="$1" inc="$2"

    local oldstate="$state"
    state=$(( oldstate * 6364136223846793005 + (inc | 1) ))

    local xorshifted=$(( ((oldstate >> 18) ^ oldstate) >> 27 ))
    local rot=$(( oldstate >> 59 ))
    local result
    result=$(_random::mask32 $(( (xorshifted >> rot) | (xorshifted << ((-rot) & 31)) )))

    echo "$result $state"
}

# PCG32 fast — hardcoded increment, same quality
# Usage: random::pcg32::fast state
# Returns: "result new_state"
random::pcg32::fast() {
    local state="$1"

    local oldstate="$state"
    state=$(( oldstate * 6364136223846793005 + 1442695040888963407 ))

    local xorshifted=$(( ((oldstate >> 18) ^ oldstate) >> 27 ))
    local rot=$(( oldstate >> 59 ))
    local result
    result=$(_random::mask32 $(( (xorshifted >> rot) | (xorshifted << ((-rot) & 31)) )))

    echo "$result $state"
}

# ==============================================================================
# SPLITMIX64
# Period: 2^64. Quality: good. Use: seeding other PRNGs, fast generation.
# Guy Steele, Doug Lea, Christine Flood — Java 8, 2014.
# Particularly useful for expanding a single seed into multi-word PRNG state.
# ==============================================================================

# Usage: random::splitmix64 state
# Returns: "result new_state"
#   read -r val state <<< "$(random::splitmix64 $state)"
random::splitmix64() {
    local state=$(( $1 + 0x9e3779b97f4a7c15 ))
    local z="$state"
    z=$(( (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9 ))
    z=$(( (z ^ (z >> 27)) * 0x94d049bb133111eb ))
    z=$(( z ^ (z >> 31) ))
    echo "$z $state"
}

# Expand a single 64-bit seed into four words for xoshiro256 initialisation
# Usage: random::splitmix64::seed_xoshiro seed
# Returns: "s0 s1 s2 s3"
random::splitmix64::seed_xoshiro() {
    local seed="$1" val state s0 s1 s2 s3
    state="$seed"
    read -r val state <<< "$(random::splitmix64 $state)"; s0="$val"
    read -r val state <<< "$(random::splitmix64 $state)"; s1="$val"
    read -r val state <<< "$(random::splitmix64 $state)"; s2="$val"
    read -r val state <<< "$(random::splitmix64 $state)"; s3="$val"
    echo "$s0 $s1 $s2 $s3"
}

# ==============================================================================
# MULBERRY32
# Period: 2^32. Quality: good for 32-bit. Use: simple fast 32-bit generation.
# Tommy Ettinger. Single 32-bit state, excellent avalanche properties.
# ==============================================================================

# Usage: random::mulberry32 state
# Returns: "result new_state"
random::mulberry32() {
    local state
    state=$(_random::mask32 $(( $1 + 0x6D2B79F5 )))
    local z="$state"
    z=$(_random::mask32 $(( (z ^ (z >> 15)) * (1 | (z << 1)) )))
    z=$(_random::mask32 $(( z ^ (z >> 7) ^ ( (z ^ (z >> 7)) * (61 | (z << 3)) ) )))
    echo "$(( z ^ (z >> 14) )) $state"
}

# ==============================================================================
# WYRAND
# Period: 2^64. Quality: excellent. Use: hashing, fast generation.
# Wang Yi, 2019. Passes BigCrush. The output function of the wyhash family.
# ==============================================================================

# Usage: random::wyrand state
# Returns: "result new_state"
random::wyrand() {
    local state=$(( $1 + 0xa0761d6478bd642f ))
    local a=$(( state ^ 0xe7037ed1a0b428db ))
    # Approximate 128-bit multiply via two halves (best-effort in bash)
    local hi=$(( (state >> 32) * (a >> 32) ))
    local lo=$(( (state & 0xFFFFFFFF) * (a & 0xFFFFFFFF) ))
    local result=$(( hi ^ lo ))
    echo "$result $state"
}

# ==============================================================================
# WELL512 (Well Equidistributed Long-period Linear)
# Period: 2^512-1. Quality: excellent. Use: simulation, games.
# Panneton, L'Ecuyer & Matsumoto, 2006. Better equidistribution than Mersenne
# Twister at similar speed. State: 16 x 32-bit words + index.
# ==============================================================================

# Initialise WELL512 state from a single seed via splitmix64
# Usage: random::well512::init seed
# Returns: "0 s0 s1 ... s15"
random::well512::init() {
    local seed="$1" val state
    state="$seed"
    local -a words=()
    for (( i=0; i<16; i++ )); do
        read -r val state <<< "$(random::splitmix64 $state)"
        words+=( "$(_random::mask32 $val)" )
    done
    echo "0 ${words[*]}"
}

# Usage: random::well512 index s0 s1 ... s15
# Returns: "result new_index s0 ... s15"
# Example:
#   read -r val idx s0 s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13 s14 s15 \
#       <<< "$(random::well512 $idx $s0 ... $s15)"
random::well512() {
    local index="$1"; shift
    local -a s=("$@")

    local a="${s[$index]}"
    local c="${s[$(( (index + 13) & 15 ))]}"
    local b
    b=$(_random::mask32 $(( (a ^ (a << 16)) ^ (c ^ (c << 15)) )))
    local d="${s[$(( (index + 9) & 15 ))]}"
    d=$(( d ^ (d >> 11) ))
    s[$index]=$(_random::mask32 $(( b ^ d )))
    local e="${s[$index]}"
    local result
    result=$(_random::mask32 $(( e ^ ((e << 5) & 0xDA442D24) )))
    index=$(( (index + 15) & 15 ))
    a="${s[$index]}"
    s[$index]=$(_random::mask32 $(( a ^ b ^ d ^ (a << 2) ^ (b << 18) ^ (c << 28) )))
    result=$(_random::mask32 $(( result ^ s[$index] )))

    echo "$result $index ${s[*]}"
}

# ==============================================================================
# ISAAC (Indirection, Shift, Accumulate, Add, Count)
# Period: 2^8295. Quality: cryptographic-adjacent. Use: security-adjacent tasks.
# Robert Jenkins, 1996. Not considered cryptographically secure by modern
# standards but far stronger than the other algorithms here.
# NOTE: Full ISAAC requires 256-word state — this is a simplified single-round
# demonstration using a 8-word state for educational purposes.
# ==============================================================================

# Initialise simplified ISAAC state
# Usage: random::isaac::init seed
# Returns: "a b c s0 s1 s2 s3 s4 s5 s6 s7"
random::isaac::init() {
    local seed="$1" val state
    state="$seed"
    local -a words=()
    for (( i=0; i<8; i++ )); do
        read -r val state <<< "$(random::splitmix64 $state)"
        words+=( "$(_random::mask32 $val)" )
    done
    echo "0 0 0 ${words[*]}"
}

# Usage: random::isaac a b c s0..s7
# Returns: "result new_a new_b new_c s0..s7"
random::isaac() {
    local a="$1" b="$2" c="$3"; shift 3
    local -a s=("$@")

    c=$(( c + 1 ))
    b=$(( b + c ))
    a=$(( (a ^ (a << 13)) & 0xFFFFFFFF ))
    local x="${s[0]}"
    a=$(( (a + s[4]) & 0xFFFFFFFF ))
    local y=$(( (x + a + b) & 0xFFFFFFFF ))
    s[0]=$(( (y ^ (y >> 13)) & 0xFFFFFFFF ))
    b=$(( (s[0] + x) & 0xFFFFFFFF ))
    local result="$b"

    # Rotate state
    local tmp="${s[0]}"
    for (( i=0; i<7; i++ )); do s[$i]="${s[$((i+1))]}"; done
    s[7]="$tmp"

    echo "$result $a $b $c ${s[*]}"
}
