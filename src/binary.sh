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

# --- INTERNAL ---

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

# --- LITTLE-ENDIAN (LSB first) ---

# Emit a 16-bit unsigned integer in little-endian byte order.
# Usage: binary::u16le <value>
binary::u16le() { _binary::pack 2 "$1" le; }

# Emit a 32-bit unsigned integer in little-endian byte order.
# Usage: binary::u32le <value>
binary::u32le() { _binary::pack 4 "$1" le; }

# Emit a 64-bit unsigned integer in little-endian byte order.
# Usage: binary::u64le <value>
binary::u64le() { _binary::pack 8 "$1" le; }

# --- BIG-ENDIAN (MSB first) ---

# Emit a 16-bit unsigned integer in big-endian byte order.
# Usage: binary::u16be <value>
binary::u16be() { _binary::pack 2 "$1" be; }

# Emit a 32-bit unsigned integer in big-endian byte order.
# Usage: binary::u32be <value>
binary::u32be() { _binary::pack 4 "$1" be; }

# Emit a 64-bit unsigned integer in big-endian byte order.
# Usage: binary::u64be <value>
binary::u64be() { _binary::pack 8 "$1" be; }

# --- STRING-TO-BINARY ---

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

# --- BUFFER ---

# Hex lookup table (byte 0–255 → '00'–'ff'). Readonly constant.
readonly -a _binary_hex256=(
	00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f
	10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f
	20 21 22 23 24 25 26 27 28 29 2a 2b 2c 2d 2e 2f
	30 31 32 33 34 35 36 37 38 39 3a 3b 3c 3d 3e 3f
	40 41 42 43 44 45 46 47 48 49 4a 4b 4c 4d 4e 4f
	50 51 52 53 54 55 56 57 58 59 5a 5b 5c 5d 5e 5f
	60 61 62 63 64 65 66 67 68 69 6a 6b 6c 6d 6e 6f
	70 71 72 73 74 75 76 77 78 79 7a 7b 7c 7d 7e 7f
	80 81 82 83 84 85 86 87 88 89 8a 8b 8c 8d 8e 8f
	90 91 92 93 94 95 96 97 98 99 9a 9b 9c 9d 9e 9f
	a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 aa ab ac ad ae af
	b0 b1 b2 b3 b4 b5 b6 b7 b8 b9 ba bb bc bd be bf
	c0 c1 c2 c3 c4 c5 c6 c7 c8 c9 ca cb cc cd ce cf
	d0 d1 d2 d3 d4 d5 d6 d7 d8 d9 da db dc dd de df
	e0 e1 e2 e3 e4 e5 e6 e7 e8 e9 ea eb ec ed ee ef
	f0 f1 f2 f3 f4 f5 f6 f7 f8 f9 fa fb fc fd fe ff
)

# Initialise (or clear) a named buffer.
# Usage: binary::buffer::init <name>
binary::buffer::init() {
	local -n _bbuf_ref="_binary_buffer_${1}"
	_bbuf_ref=()
}

# --- INSERT VARIANTS ---

# Append raw byte values.
# Usage: binary::buffer::insert::raw <name> <byte1> <byte2> ...
binary::buffer::insert::raw() {
	local -n _bbuf_ref="_binary_buffer_${1}"
	shift
	_bbuf_ref+=("$@")
}

# Append bytes from a hex string.
# Usage: binary::buffer::insert::hex <name> <hexstring>
#   "414243" → 0x41, 0x42, 0x43
binary::buffer::insert::hex() {
	local -n _bbuf_ref="_binary_buffer_${1}"
	local hex=$2 i pad=0 val
	(( ${#hex} % 2 != 0 )) && hex="0$hex"
	for ((i = 0; i < ${#hex}; i += 2)); do
		_bbuf_ref+=($((16#${hex:i:2})))
	done
}

# Append an unsigned integer (fixed-width, little-endian by default).
# Usage: binary::buffer::insert::uint <name> <value> <width> [endian=le]
binary::buffer::insert::uint() {
	local name=$1 value=$2 width=$3 endian=${4:-le}
	local -n _bbuf_ref="_binary_buffer_${name}"

	local i
	if [[ $endian == le ]]; then
		for ((i = 0; i < width; i++)); do
			_bbuf_ref+=($(( (value >> (8 * i)) & 0xFF )))
		done
	else
		local idx
		for ((idx = width - 1; idx >= 0; idx--)); do
			_bbuf_ref+=($(( (value >> (8 * idx)) & 0xFF )))
		done
	fi
}

# Append a signed integer (two's complement, fixed-width).
# Usage: binary::buffer::insert::int <name> <value> <width> [endian=le]
binary::buffer::insert::int() {
	binary::buffer::insert::uint "$@"
}

# Compatibility alias.
# Usage: binary::buffer::insert <name> <value> <width> [endian=le]
binary::buffer::insert() {
	binary::buffer::insert::uint "$@"
}

# --- WRITE / READ / LENGTH ---

# Internal: emit array of decimal byte values as raw binary to stdout.
# Usage: _binary::_emit_raw <array_nameref>
_binary::_emit_raw() {
	local -n _ber_arr="$1"
	local _ber_len=${#_ber_arr[@]}
	(( _ber_len == 0 )) && return
	local _ber_fmt="" i
	for ((i = 0; i < _ber_len; i++)); do
		_ber_fmt+="\\x${_binary_hex256[_ber_arr[i]]}"
	done
	printf '%b' "$_ber_fmt"
}

# Flush buffer contents to stdout and clear.
# Usage: binary::buffer::write <name>
binary::buffer::write() {
	local -n _bbuf_ref="_binary_buffer_${1}"
	_binary::_emit_raw _bbuf_ref
	_bbuf_ref=()
}

# Echo buffer contents without clearing (space-separated decimal values).
# Usage: binary::buffer::read <name>
binary::buffer::read() {
	local -n _bbuf_ref="_binary_buffer_${1}"
	printf '%s' "${_bbuf_ref[*]}"
}

# Echo current buffer length in bytes.
# Usage: binary::buffer::length <name>
binary::buffer::length() {
	local -n _bbuf_ref="_binary_buffer_${1}"
	echo "${#_bbuf_ref[@]}"
}

# --- CONCAT ---

# Append all bytes from <src> buffer to <dst> buffer.
# Usage: binary::buffer::concat <dst> <src>
binary::buffer::concat() {
	local -n _bbuf_dst="_binary_buffer_${1}"
	local -n _bbuf_src="_binary_buffer_${2}"
	_bbuf_dst+=("${_bbuf_src[@]}")
}

# --- PEEK ---

# Read a byte slice without clearing.
# Usage: binary::buffer::peek <name> <offset> <length> [mode=dec]
#   mode: dec — space-separated decimal values (default)
#         hex — unspaced lowercase hex string
#         raw — raw bytes written to stdout
binary::buffer::peek() {
	local -n _bbuf_ref="_binary_buffer_${1}"
	local offset=$2 length=$3 mode=${4:-dec}
	local slice=("${_bbuf_ref[@]:offset:length}")

	case $mode in
		raw)
			_binary::_emit_raw slice
			;;
		hex)
			local _bpo_b
			for _bpo_b in "${slice[@]}"; do
				printf '%02x' "$_bpo_b"
			done
			;;
		dec|*)
			printf '%s' "${slice[*]}"
			;;
	esac
}

# --- SHIFT ---

# Remove <count> bytes from the front of the buffer.
# Usage: binary::buffer::shift::l <name> <count>
binary::buffer::shift::l() {
	local -n _bbuf_ref="_binary_buffer_${1}"
	local count=$2
	_bbuf_ref=("${_bbuf_ref[@]:count}")
}

# Remove <count> bytes from the end of the buffer.
# Usage: binary::buffer::shift::r <name> <count>
binary::buffer::shift::r() {
	local -n _bbuf_ref="_binary_buffer_${1}"
	local count=$2 len=${#_bbuf_ref[@]}
	(( count > len )) && count=$len
	_bbuf_ref=("${_bbuf_ref[@]:0:len-count}")
}

# --- SERIALISATION ---

# Write raw buffer bytes to a file.
# Usage: binary::buffer::serialised::save <name> <filepath>
binary::buffer::serialised::save() {
	local -n _bbuf_ref="_binary_buffer_${1}"
	local file=$2
	if (( ${#_bbuf_ref[@]} > 0 )); then
		_binary::_emit_raw _bbuf_ref > "$file"
	fi
}

# Load raw bytes from a file into the buffer (replaces contents).
# Usage: binary::buffer::serialised::load <name> <filepath>
binary::buffer::serialised::load() {
	local -n _bbuf_ref="_binary_buffer_${1}"
	local file=$2
	_bbuf_ref=()
	if [[ -f "$file" && -r "$file" ]]; then
		local byte_data; byte_data=$(LC_ALL=C od -An -tu1 -v "$file")
		read -r -a _bbuf_ref <<< "$byte_data"
	fi
}
