#!/usr/bin/env bash
# hash.sh — bash-frameheader hashing lib
# Hashing of strings and data. For file checksums see fs::checksum::*.
#
# CRYPTOGRAPHIC NOTE: md5 and sha1 are included for completeness and
# non-security uses (checksums, caching keys, deduplication). Do not
# use them for password hashing or security-sensitive applications.
# Use sha256 or sha512 for anything security-adjacent.

# ==============================================================================
# INTERNAL HELPERS
# ==============================================================================

# Feed a string to a hash command portably
# Usage: _hash::pipe string command [args...]
_hash::pipe() {
    local s="$1"; shift
    printf '%s' "$s" | "$@"
}

# ==============================================================================
# CRYPTOGRAPHIC
# ==============================================================================

# MD5 hash of a string
# Usage: hash::md5 string
hash::md5() {
    if runtime::has_command md5sum; then
        _hash::pipe "$1" md5sum | awk '{print $1}'
    elif runtime::has_command md5; then
        _hash::pipe "$1" md5 -q 2>/dev/null || \
        _hash::pipe "$1" md5 | awk '{print $NF}'
    else
        echo "hash::md5: requires md5sum or md5" >&2
        return 1
    fi
}

# SHA1 hash of a string
hash::sha1() {
    if runtime::has_command sha1sum; then
        _hash::pipe "$1" sha1sum | awk '{print $1}'
    elif runtime::has_command shasum; then
        _hash::pipe "$1" shasum -a 1 | awk '{print $1}'
    elif runtime::has_command openssl; then
        _hash::pipe "$1" openssl dgst -sha1 | awk '{print $NF}'
    else
        echo "hash::sha1: requires sha1sum, shasum, or openssl" >&2
        return 1
    fi
}

# SHA256 hash of a string
hash::sha256() {
    if runtime::has_command sha256sum; then
        _hash::pipe "$1" sha256sum | awk '{print $1}'
    elif runtime::has_command shasum; then
        _hash::pipe "$1" shasum -a 256 | awk '{print $1}'
    elif runtime::has_command openssl; then
        _hash::pipe "$1" openssl dgst -sha256 | awk '{print $NF}'
    else
        echo "hash::sha256: requires sha256sum, shasum, or openssl" >&2
        return 1
    fi
}

# SHA512 hash of a string
hash::sha512() {
    if runtime::has_command sha512sum; then
        _hash::pipe "$1" sha512sum | awk '{print $1}'
    elif runtime::has_command shasum; then
        _hash::pipe "$1" shasum -a 512 | awk '{print $1}'
    elif runtime::has_command openssl; then
        _hash::pipe "$1" openssl dgst -sha512 | awk '{print $NF}'
    else
        echo "hash::sha512: requires sha512sum, shasum, or openssl" >&2
        return 1
    fi
}

# SHA3-256 hash of a string
hash::sha3_256() {
    if runtime::has_command openssl; then
        _hash::pipe "$1" openssl dgst -sha3-256 2>/dev/null | awk '{print $NF}'
    else
        echo "hash::sha3_256: requires openssl with sha3 support" >&2
        return 1
    fi
}

# BLAKE2b hash of a string
hash::blake2b() {
    if runtime::has_command b2sum; then
        _hash::pipe "$1" b2sum | awk '{print $1}'
    elif runtime::has_command openssl; then
        _hash::pipe "$1" openssl dgst -blake2b512 2>/dev/null | awk '{print $NF}'
    else
        echo "hash::blake2b: requires b2sum or openssl" >&2
        return 1
    fi
}

# ==============================================================================
# HMAC
# ==============================================================================

# HMAC-SHA256
# Usage: hash::hmac::sha256 key message
hash::hmac::sha256() {
    local key="$1" msg="$2"
    if runtime::has_command openssl; then
        printf '%s' "$msg" | \
            openssl dgst -sha256 -hmac "$key" 2>/dev/null | awk '{print $NF}'
    else
        echo "hash::hmac::sha256: requires openssl" >&2
        return 1
    fi
}

# HMAC-SHA512
# Usage: hash::hmac::sha512 key message
hash::hmac::sha512() {
    local key="$1" msg="$2"
    if runtime::has_command openssl; then
        printf '%s' "$msg" | \
            openssl dgst -sha512 -hmac "$key" 2>/dev/null | awk '{print $NF}'
    else
        echo "hash::hmac::sha512: requires openssl" >&2
        return 1
    fi
}

# HMAC-MD5
# Usage: hash::hmac::md5 key message
hash::hmac::md5() {
    local key="$1" msg="$2"
    if runtime::has_command openssl; then
        printf '%s' "$msg" | \
            openssl dgst -md5 -hmac "$key" 2>/dev/null | awk '{print $NF}'
    else
        echo "hash::hmac::md5: requires openssl" >&2
        return 1
    fi
}

# ==============================================================================
# NON-CRYPTOGRAPHIC — pure bash implementations
# Fast, portable, suitable for hash tables, caching keys, bloom filters.
# NOT suitable for security use.
# ==============================================================================

# DJB2 — Daniel J. Bernstein's hash, classic and fast
# Returns unsigned 32-bit integer
# Usage: hash::djb2 string
hash::djb2() {
    local s="$1" hash=5381 i char
    for (( i=0; i<${#s}; i++ )); do
        char=$(printf '%d' "'${s:$i:1}")
        hash=$(( ((hash << 5) + hash + char) & 0xFFFFFFFF ))
    done
    echo "$hash"
}

# DJB2a (xor variant) — slightly better distribution than djb2
hash::djb2a() {
    local s="$1" hash=5381 i char
    for (( i=0; i<${#s}; i++ )); do
        char=$(printf '%d' "'${s:$i:1}")
        hash=$(( ((hash << 5) + hash ^ char) & 0xFFFFFFFF ))
    done
    echo "$hash"
}

# SDBM hash — used in the SDBM database library
# Often outperforms DJB2 for database keys
hash::sdbm() {
    local s="$1" hash=0 i char
    for (( i=0; i<${#s}; i++ )); do
        char=$(printf '%d' "'${s:$i:1}")
        hash=$(( (char + (hash << 6) + (hash << 16) - hash) & 0xFFFFFFFF ))
    done
    echo "$hash"
}

# FNV-1a 32-bit — Fowler-Noll-Vo, excellent avalanche, widely used
# Period: 2^32
hash::fnv1a32() {
    local s="$1" hash=2166136261 i char
    for (( i=0; i<${#s}; i++ )); do
        char=$(printf '%d' "'${s:$i:1}")
        hash=$(( (hash ^ char) * 16777619 & 0xFFFFFFFF ))
    done
    echo "$hash"
}

# FNV-1a 64-bit — larger state, better for longer strings
# Note: bash uses signed 64-bit integers; result may be negative for large hashes
hash::fnv1a64() {
    local s="$1"
    local hash_lo=2166136261 hash_hi=0
    local fnv_prime_lo=16777619 i char

    for (( i=0; i<${#s}; i++ )); do
        char=$(printf '%d' "'${s:$i:1}")
        # XOR low 32 bits with byte
        hash_lo=$(( (hash_lo ^ char) & 0xFFFFFFFF ))
        # Multiply: (hi:lo) * prime — simplified since prime fits in 32 bits
        local new_lo=$(( (hash_lo * fnv_prime_lo) & 0xFFFFFFFF ))
        local carry=$(( hash_lo * fnv_prime_lo >> 32 ))
        hash_hi=$(( (hash_hi * fnv_prime_lo + carry) & 0xFFFFFFFF ))
        hash_lo=$new_lo
    done

    printf '%08x%08x\n' "$hash_hi" "$hash_lo"
}

# Adler-32 — fast checksum used in zlib/PNG
# Not a hash in the traditional sense but useful for data integrity
hash::adler32() {
    local s="$1"
    local a=1 b=0 i char MOD=65521

    for (( i=0; i<${#s}; i++ )); do
        char=$(printf '%d' "'${s:$i:1}")
        a=$(( (a + char) % MOD ))
        b=$(( (b + a) % MOD ))
    done

    echo $(( (b << 16) | a ))
}

# CRC32 — delegates to system tools, pure bash fallback is too slow for real use
# Usage: hash::crc32 string
hash::crc32() {
    local s="$1"
    if runtime::has_command crc32; then
        printf '%s' "$s" | crc32 /dev/stdin 2>/dev/null
    elif runtime::has_command python3; then
        python3 -c "import binascii,sys; print('%08x' % (binascii.crc32(sys.argv[1].encode()) & 0xffffffff))" "$s"
    elif runtime::has_command cksum; then
        # cksum uses CRC but with a different algorithm — close but not standard CRC32
        printf '%s' "$s" | cksum | awk '{print $1}'
    else
        echo "hash::crc32: requires crc32, python3, or cksum" >&2
        return 1
    fi
}

# MurmurHash2 — pure bash, good distribution, faster than cryptographic hashes
# Austin Appleby, 2008
hash::murmur2() {
    local s="$1" seed="${2:-0}"
    local len="${#s}"
    local m=2246822519 r=13
    local h=$(( seed ^ len ))
    local i=0 k

    while (( i + 4 <= len )); do
        local c0=$(printf '%d' "'${s:$i:1}")
        local c1=$(printf '%d' "'${s:$((i+1)):1}")
        local c2=$(printf '%d' "'${s:$((i+2)):1}")
        local c3=$(printf '%d' "'${s:$((i+3)):1}")
        k=$(( c0 | (c1 << 8) | (c2 << 16) | (c3 << 24) ))
        k=$(( (k * m) & 0xFFFFFFFF ))
        k=$(( k ^ (k >> r) ))
        k=$(( (k * m) & 0xFFFFFFFF ))
        h=$(( (h * m) & 0xFFFFFFFF ))
        h=$(( (h ^ k) & 0xFFFFFFFF ))
        (( i += 4 ))
    done

    # Handle remaining bytes
    local remaining=$(( len - i ))
    case "$remaining" in
    3) h=$(( h ^ ($(printf '%d' "'${s:$((i+2)):1}") << 16) )) ;&
    2) h=$(( h ^ ($(printf '%d' "'${s:$((i+1)):1}") << 8)  )) ;&
    1) h=$(( h ^ $(printf '%d' "'${s:$i:1}") ))
       h=$(( (h * m) & 0xFFFFFFFF ))
       ;;
    esac

    h=$(( h ^ (h >> 13) ))
    h=$(( (h * m) & 0xFFFFFFFF ))
    h=$(( h ^ (h >> 15) ))

    echo "$h"
}

# ==============================================================================
# UTILITY
# ==============================================================================

# Verify a string against a known hash
# Usage: hash::verify string expected_hash algorithm
# Example: hash::verify "hello" "2cf24dba..." sha256
hash::verify() {
    local s="$1" expected="$2" algo="${3:-sha256}"
    local actual
    actual=$(hash::"$algo" "$s" 2>/dev/null) || return 1
    [[ "$actual" == "$expected" ]]
}

# Consistent hashing — map a value to a bucket (0 to n-1)
# Useful for load balancing, sharding, cache partitioning
# Usage: hash::slot n_buckets value
hash::slot() {
    local n="$1" value="$2"
    local h
    h=$(hash::fnv1a32 "$value")
    echo $(( h % n ))
}

# Generate a short hash — first n chars of sha256
# Usage: hash::short string [length]
hash::short() {
    local s="$1" len="${2:-8}"
    local full
    full=$(hash::sha256 "$s") || return 1
    echo "${full:0:$len}"
}

# Hash multiple values into one — useful for cache keys from multiple inputs
# Usage: hash::combine val1 val2 val3 ...
hash::combine() {
    local combined
    combined=$(printf '%s\0' "$@" | hash::sha256 /dev/stdin 2>/dev/null) || \
    combined=$(printf '%s:' "$@" | hash::sha256)
    echo "$combined"
}

# Check if two strings have the same hash (constant-time safe via hash comparison)
# Usage: hash::equal string1 string2 [algorithm]
hash::equal() {
    local h1 h2 algo="${3:-sha256}"
    h1=$(hash::"$algo" "$1" 2>/dev/null) || return 1
    h2=$(hash::"$algo" "$2" 2>/dev/null) || return 1
    [[ "$h1" == "$h2" ]]
}

# Generate a hash-based UUID v5 (name-based, SHA1)
# Usage: hash::uuid5 namespace name
# Namespace can be a UUID or a well-known string
hash::uuid5() {
    # uuidgen doesn't support v5 on all platforms — fall back to sha1-based manual construction
    local raw
    raw=$(hash::sha1 "${1}:${2}")
    printf '%s-%s-%s-%s-%s\n' \
        "${raw:0:8}" "${raw:8:4}" "5${raw:13:3}" \
        "$(printf '%x' $(( (16#${raw:16:2} & 0x3f) | 0x80 )))${raw:18:2}" \
        "${raw:20:12}"
}
