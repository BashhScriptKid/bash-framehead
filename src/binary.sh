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
