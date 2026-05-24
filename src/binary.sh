#!/usr/bin/env bash

# binary.sh — bash::framehead binary data primitives
#
# Integer-to-binary packing via pure Bash printf %b. Adapted from Dave Eddy's
# bash-bmp (github.com/bahamas10/bash-bmp, MIT license).
#
# EXAMPLE:
#   source bash-framehead.sh
#   binary::u32le 0x12345678 | xxd -p    # 78563412
#   binary::u32be 0x12345678 | xxd -p    # 12345678
#   binary::u16le 256 | od -An -tx1       # 00 01

# ==============================================================================
# INTERNAL
# ==============================================================================

# Emit an integer as raw bytes to stdout.
# Usage: _binary::pack <width> <value> <endian>
#   width  — number of bytes (2, 4, or 8)
#   value  — integer to pack
#   endian — "le" (little-endian, LSB first) or "be" (big-endian, MSB first)
_binary::pack() {
    local width=$1 value=$2 endian=$3
    local octets=() i

    for ((i = 0; i < width; i++)); do
        octets+=($(( (value >> (8 * i)) & 0xFF )))
    done

    if [[ $endian == be ]]; then
        local tmp=() idx
        for ((idx = width - 1; idx >= 0; idx--)); do
            tmp+=("${octets[idx]}")
        done
        octets=("${tmp[@]}")
    fi

    local fmt
    printf -v fmt '\\x%02x' "${octets[@]}"
    printf '%b' "$fmt"
}

# ==============================================================================
# LITTLE-ENDIAN (LSB first)
# ==============================================================================

# Emit a 16-bit unsigned integer in little-endian byte order.
# Usage: binary::u16le <value>
binary::u16le() { _binary::pack 2 "$1" le; }

# Emit a 32-bit unsigned integer in little-endian byte order.
# Usage: binary::u32le <value>
binary::u32le() { _binary::pack 4 "$1" le; }

# Emit a 64-bit unsigned integer in little-endian byte order.
# Usage: binary::u64le <value>
binary::u64le() { _binary::pack 8 "$1" le; }

# ==============================================================================
# BIG-ENDIAN (MSB first)
# ==============================================================================

# Emit a 16-bit unsigned integer in big-endian byte order.
# Usage: binary::u16be <value>
binary::u16be() { _binary::pack 2 "$1" be; }

# Emit a 32-bit unsigned integer in big-endian byte order.
# Usage: binary::u32be <value>
binary::u32be() { _binary::pack 4 "$1" be; }

# Emit a 64-bit unsigned integer in big-endian byte order.
# Usage: binary::u64be <value>
binary::u64be() { _binary::pack 8 "$1" be; }

# ==============================================================================
# STRING-TO-BINARY
# ==============================================================================

# Internal: emit unsigned integer as minimal-width little-endian bytes.
# Usage: _binary::from_uint <value>
_binary::from_uint() {
    local val=$1
    if (( val == 0 )); then
        printf '\x00'
        return
    fi
    local octets=()
    while (( val > 0 )); do
        octets+=($(( val & 0xFF )))
        (( val >>= 8 ))
    done
    local fmt
    printf -v fmt '\\x%02x' "${octets[@]}"
    printf '%b' "$fmt"
}

# Emit raw bytes from a hex string (each pair of hex chars = 1 byte).
# Odd-length input is zero-padded on the left.
# Usage: binary::from_hex <hex>
binary::from_hex() {
    local hex=$1
    (( ${#hex} % 2 != 0 )) && hex="0$hex"
    local i
    for ((i = 0; i < ${#hex}; i += 2)); do
        printf -v _fh_byte '\\x%s' "${hex:i:2}"
        printf '%b' "$_fh_byte"
    done
    unset _fh_byte
}

# Emit raw bytes from an octal number string (minimal-width unsigned LE).
# Usage: binary::from_oct <octal>
binary::from_oct() {
    local val=$((8#$1))
    _binary::from_uint "$val"
}

# Emit raw bytes from an unsigned decimal integer (minimal-width LE).
# Usage: binary::from_uint <n>
binary::from_uint() {
    _binary::from_uint "$1"
}

# Emit raw bytes from a signed decimal integer (minimal-width two's complement LE).
# Usage: binary::from_int <n>
#   -1   → ff
#   -128 → 80
#   -129 → 7fff
#   127  → 7f
#   128  → 8000
binary::from_int() {
    local val=$1
    if (( val == 0 )); then
        printf '\x00'
        return
    fi

    local octets=() neg=0
    if (( val < 0 )); then
        neg=1
        (( val = -val ))
    fi

    # Encode absolute value as minimal unsigned bytes
    while (( val > 0 )); do
        octets+=($(( val & 0xFF )))
        (( val >>= 8 ))
    done

    if (( neg )); then
        # Two's complement: flip bits and add 1
        local carry=1 i
        for ((i = 0; i < ${#octets[@]}; i++)); do
            (( octets[i] = (~octets[i] & 0xFF) + carry ))
            (( carry = octets[i] >> 8 ? 1 : 0 ))
            (( octets[i] &= 0xFF ))
        done
        if (( carry )); then
            octets+=(1)
        fi
        # Ensure sign bit is set in the high byte
        if (( (octets[-1] & 0x80) == 0 )); then
            octets+=(0xFF)
        fi
    else
        # Positive: ensure sign bit is clear in the high byte
        if (( (octets[-1] & 0x80) != 0 )); then
            octets+=(0)
        fi
    fi

    local fmt
    printf -v fmt '\\x%02x' "${octets[@]}"
    printf '%b' "$fmt"
}
