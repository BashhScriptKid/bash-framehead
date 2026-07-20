#!/usr/bin/env bash
# ext/bmp/bmp.sh — BMP image generation
#
# Pure-Bash 24-bit BMP file generation. Adapted from Dave Eddy's bash-bmp
# (github.com/bahamas10/bash-bmp, MIT license).
#
# Dependencies:
#   core: runtime binary

# --- guard ---

declare -f 'runtime::bash_version' &>/dev/null || {
		echo "${BASH_SOURCE[0]}: runtime not found -- source bash-framehead.sh first" >&2
		return 1
}

_guard_core_deps=(binary::u16le binary::u32le binary::buffer::init binary::buffer::insert::raw binary::buffer::insert::uint binary::buffer::write)
_guard_ext_deps=()

for _guard_dep in "${_guard_core_deps[@]}"; do
		declare -f "$_guard_dep" &>/dev/null || {
				echo "${BASH_SOURCE[0]}: missing core function '$_guard_dep'" >&2
				return 1
		}
done

for _guard_dep in "${_guard_ext_deps[@]}"; do
		command -v "$_guard_dep" &>/dev/null || {
				echo "${BASH_SOURCE[0]}: missing external tool '$_guard_dep'" >&2
				return 1
		}
done

unset _guard_core_deps _guard_ext_deps _guard_dep
# --- end guard ---

# ==============================================================================
# PIXELS
# ==============================================================================

# Emit a single pixel as BGR byte triplet (BMP pixel order is B,G,R).
# Usage: bmp::rgb <red> <green> <blue>
bmp::rgb() {
		local r=$1 g=$2 b=$3
		local out
		printf -v out '\\x%02x\\x%02x\\x%02x' "$b" "$g" "$r"
		printf '%b' "$out"
}

# Emit N null bytes for 4-byte row alignment.
# Usage: bmp::pad <count>
bmp::pad() {
		local n=$1 i
		for ((i = 0; i < n; i++)); do
				printf '\0'
		done
}

# ==============================================================================
# HEADER
# ==============================================================================

# Emit a 54-byte BMP file header + DIB info header for a 24-bit image.
# Returns row padding count via REPLY (aligned to 4-byte boundary).
# Usage: bmp::header <width> <height>
bmp::header() {
		local width=$1 height=$2
		local bits_per_px=24
		local bytes_per_px=$((bits_per_px / 8))
		local row_size=$((width * bytes_per_px))
		local padding=0

		while ((row_size % 4 != 0)); do
				((padding++))
				((row_size++))
		done

		local pixel_data_size=$((row_size * height))
		local pixel_data_offset=$((14 + 40))
		local file_size=$((pixel_data_size + pixel_data_offset))

		# File header (14 bytes)
		printf 'BM'                         # Signature
		binary::u32le "$file_size"          # FileSize
		binary::u32le 0                     # Reserved
		binary::u32le "$pixel_data_offset"  # DataOffset

		# DIB info header (40 bytes)
		binary::u32le 40                    # Size
		binary::u32le "$width"              # Width
		binary::u32le "$height"             # Height
		binary::u16le 1                     # Planes
		binary::u16le "$bits_per_px"        # BitCount
		binary::u32le 0                     # Compression
		binary::u32le 0                     # ImageSize (0 = can be zero for BI_RGB)
		binary::u32le 0                     # XPixelsPerM
		binary::u32le 0                     # YPixelsPerM
		binary::u32le 0                     # ColorsUsed
		binary::u32le 0                     # ColorsImportant

		REPLY=$padding
}

# ==============================================================================
# READING
# ==============================================================================

# Internal: read N little-endian bytes from a decimal byte array starting
# at the given offset, combined into a single unsigned integer.
# Usage: _bmp::le <array_name> <offset> <count>
_bmp::le() {
		local -n _bmp_le_arr=$1
		local _bmp_le_off=$2 _bmp_le_n=$3
		local _bmp_le_val=0 _bmp_le_i
		for ((_bmp_le_i = _bmp_le_n - 1; _bmp_le_i >= 0; _bmp_le_i--)); do
				((_bmp_le_val = (_bmp_le_val << 8) | _bmp_le_arr[_bmp_le_off + _bmp_le_i]))
		done
		echo "$_bmp_le_val"
}

# Parse a BMP file's header and print its fields as key=value lines.
# Fields: width, height, top_down, bits_per_px, compression, file_size,
#         data_offset, image_size.
# Usage: bmp::info <file>
bmp::info() {
		local file=$1
		[[ -f "$file" ]] || {
				echo "bmp::info: file not found: $file" >&2
				return 1
		}

		local raw
		raw=$(od -An -v -tu1 -N 54 -- "$file" | tr -s '\n' ' ')
		local -a b
		read -r -a b <<< "$raw"

		((${#b[@]} >= 54)) || {
				echo "bmp::info: file too short to be a valid BMP" >&2
				return 1
		}

		(( b[0] == 66 && b[1] == 77 )) || {
				echo "bmp::info: bad signature (not a BMP file)" >&2
				return 1
		}

		local file_size data_offset width height planes bits_per_px compression image_size
		file_size=$(_bmp::le b 2 4)
		data_offset=$(_bmp::le b 10 4)
		width=$(_bmp::le b 18 4)
		height=$(_bmp::le b 22 4)
		planes=$(_bmp::le b 26 2)
		bits_per_px=$(_bmp::le b 28 2)
		compression=$(_bmp::le b 30 4)
		image_size=$(_bmp::le b 34 4)

		# height is a signed 32-bit field; negative means top-down row order
		local top_down=0
		if ((height >= 2147483648)); then
				((height = height - 4294967296))
		fi
		if ((height < 0)); then
				top_down=1
				((height = -height))
		fi

		printf 'width=%d\nheight=%d\ntop_down=%d\nplanes=%d\nbits_per_px=%d\ncompression=%d\nfile_size=%d\ndata_offset=%d\nimage_size=%d\n' \
				"$width" "$height" "$top_down" "$planes" "$bits_per_px" "$compression" "$file_size" "$data_offset" "$image_size"
}

# Read a 24-bit uncompressed BMP and emit pixel rows as decimal RGB triplets,
# one pixel per line ("r g b"), in natural top-to-bottom, left-to-right order
# regardless of the file's on-disk row order.
# Usage: bmp::read <file>
bmp::read() {
		local file=$1
		[[ -f "$file" ]] || {
				echo "bmp::read: file not found: $file" >&2
				return 1
		}

		local info
		info=$(bmp::info "$file") || return 1
		local width height top_down bits_per_px compression data_offset
		eval "local $(echo "$info" | grep -E '^(width|height|top_down|bits_per_px|compression|data_offset)=')"

		((bits_per_px == 24)) || {
				echo "bmp::read: unsupported bit depth '$bits_per_px' (only 24-bit supported)" >&2
				return 1
		}
		((compression == 0)) || {
				echo "bmp::read: unsupported compression '$compression' (only BI_RGB supported)" >&2
				return 1
		}

		local row_size=$((width * 3))
		local padding=0
		while ((row_size % 4 != 0)); do
				((padding++))
				((row_size++))
		done

		local raw
		raw=$(od -An -v -tu1 -j "$data_offset" -- "$file" | tr -s '\n' ' ')
		local -a px
		read -r -a px <<< "$raw"

		local y x off r g b row
		for ((y = 0; y < height; y++)); do
				row=$((top_down ? y : height - y - 1))
				for ((x = 0; x < width; x++)); do
						off=$((row * row_size + x * 3))
						b=${px[off]} g=${px[off + 1]} r=${px[off + 2]}
						echo "$r $g $b"
				done
		done
}

# ==============================================================================
# UTILITIES
# ==============================================================================

# Convert a hex color string to space-separated decimal RGB.
# Usage: bmp::hex2rgb "#ff0000"  →  "255 0 0"
bmp::hex2rgb() {
		local hex=${1#\#}
		[[ "$hex" =~ ^[0-9a-fA-F]{6}$ ]] || {
				echo "bmp::hex2rgb: expected 6 hex digits (e.g. #ff0000), got '$1'" >&2
				return 1
		}
		local r=$((16#${hex:0:2}))
		local g=$((16#${hex:2:2}))
		local b=$((16#${hex:4:2}))
		echo "$r $g $b"
}

# Convert decimal RGB (0-255 each) to a lowercase hex color string.
# Usage: bmp::rgb2hex <r> <g> <b>  →  "#ff0000"
bmp::rgb2hex() {
		local r=$1 g=$2 b=$3 v
		for v in "$r" "$g" "$b"; do
				[[ "$v" =~ ^[0-9]+$ ]] && ((v >= 0 && v <= 255)) || {
						echo "bmp::rgb2hex: expected r/g/b in 0-255, got '$r $g $b'" >&2
						return 1
				}
		done
		printf '#%02x%02x%02x\n' "$r" "$g" "$b"
}

# Convert HSV (h:0-359 degrees, s/v:0-100 percent) to space-separated
# decimal RGB (0-255 each). Pure-integer fixed-point conversion.
# Usage: bmp::hsv2rgb <h> <s> <v>  →  "0 255 0"
bmp::hsv2rgb() {
		local h=$1 s=$2 v=$3
		[[ "$h" =~ ^[0-9]+$ ]] && ((h >= 0 && h <= 359)) || {
				echo "bmp::hsv2rgb: expected h in 0-359, got '$h'" >&2
				return 1
		}
		local _hv
		for _hv in "$s" "$v"; do
				[[ "$_hv" =~ ^[0-9]+$ ]] && ((_hv >= 0 && _hv <= 100)) || {
						echo "bmp::hsv2rgb: expected s/v in 0-100, got '$s $v'" >&2
						return 1
				}
		done

		local v255=$(( (v * 255 + 50) / 100 ))
		if ((s == 0)); then
				echo "$v255 $v255 $v255"
				return
		fi
		local s255=$(( (s * 255 + 50) / 100 ))

		local i=$((h / 60)) rem=$((h % 60))
		local f256=$(( (rem * 256 + 30) / 60 ))
		((f256 > 255)) && f256=255

		local fs=$(( (f256 * s255 + 127) / 255 ))
		local nfs=$(( ((255 - f256) * s255 + 127) / 255 ))

		local p=$(( (v255 * (255 - s255) + 127) / 255 ))
		local q=$(( (v255 * (255 - fs) + 127) / 255 ))
		local t=$(( (v255 * (255 - nfs) + 127) / 255 ))

		local r g b
		case $i in
				0) r=$v255 g=$t   b=$p   ;;
				1) r=$q   g=$v255 b=$p   ;;
				2) r=$p   g=$v255 b=$t   ;;
				3) r=$p   g=$q   b=$v255 ;;
				4) r=$t   g=$p   b=$v255 ;;
				*) r=$v255 g=$p   b=$q   ;;
		esac
		echo "$r $g $b"
}

# Convert decimal RGB (0-255 each) to HSV (h:0-359 degrees, s/v:0-100
# percent), space-separated. Pure-integer fixed-point conversion.
# Usage: bmp::rgb2hsv <r> <g> <b>  →  "120 100 100"
bmp::rgb2hsv() {
		local r=$1 g=$2 b=$3 _rv
		for _rv in "$r" "$g" "$b"; do
				[[ "$_rv" =~ ^[0-9]+$ ]] && ((_rv >= 0 && _rv <= 255)) || {
						echo "bmp::rgb2hsv: expected r/g/b in 0-255, got '$r $g $b'" >&2
						return 1
				}
		done

		local max=$r min=$r
		((g > max)) && max=$g
		((b > max)) && max=$b
		((g < min)) && min=$g
		((b < min)) && min=$b
		local delta=$((max - min))

		local v=$(( (max * 100 + 127) / 255 ))
		local s=0
		((max > 0)) && s=$(( (delta * 100 + max / 2) / max ))

		local h=0
		if ((delta > 0)); then
				if ((max == r)); then
						h=$(( ((g - b) * 1000) / delta ))
						((h < 0)) && ((h += 6000))
				elif ((max == g)); then
						h=$(( (((b - r) * 1000) / delta) + 2000 ))
				else
						h=$(( (((r - g) * 1000) / delta) + 4000 ))
				fi
				h=$(( (60 * h / 1000) % 360 ))
		fi
		echo "$h $s $v"
}

# ==============================================================================
# GENERATORS
# ==============================================================================

# Emit a complete BMP gradient image to stdout.
# Usage: bmp::gradient <width> <height> [type]
#   type: "linear" (default) — R on X axis, B on Y axis
#         "radial"          — distance from center mapped to R/B
bmp::gradient() {
		local width=$1 height=$2 type=${3:-linear}
		local r g b x y cx cy d2 max_d2 t

		bmp::header "$width" "$height"
		local padding=$REPLY

		case "$type" in
				linear)
						for ((y = 0; y < height; y++)); do
								for ((x = 0; x < width; x++)); do
										((r = x * 255 / width))
										((b = y * 255 / height))
										bmp::rgb "$r" 0 "$b"
								done
								bmp::pad "$padding"
						done
						;;
				radial)
						cx=$((width / 2))
						cy=$((height / 2))
						# max squared distance from center to any corner
						local dx_max dy_max
						dx_max=$((cx > width - cx ? cx : width - cx))
						dy_max=$((cy > height - cy ? cy : height - cy))
						max_d2=$((dx_max * dx_max + dy_max * dy_max))
						[[ $max_d2 -eq 0 ]] && max_d2=1

						for ((y = 0; y < height; y++)); do
								for ((x = 0; x < width; x++)); do
										d2=$(((x - cx) * (x - cx) + (y - cy) * (y - cy)))
										t=$((d2 * 255 / max_d2))
										((t > 255)) && t=255
										bmp::rgb "$t" 0 $((255 - t))
								done
								bmp::pad "$padding"
						done
						;;
				*)
						echo "bmp::gradient: unknown type '$type' (expected linear or radial)" >&2
						return 1
						;;
		esac
}

# Read a text sprite from stdin and emit a BMP to stdout.
# Palette file format: one entry per line: <char> <#rrggbb>
# Usage: bmp::sprite <palette_file>
bmp::sprite() {
		local palette_file=$1
		local -A PALETTE

		if [[ ! -f "$palette_file" ]]; then
				echo "bmp::sprite: palette file not found: $palette_file" >&2
				return 1
		fi

		local lines line char hex
		mapfile -t lines < "$palette_file"
		for line in "${lines[@]}"; do
				[[ -z "$line" ]] && continue
				char=${line:0:1}
				hex=${line:2}
				PALETTE[$char]=$(bmp::hex2rgb "$hex")
		done

		local SPRITE
		mapfile -t SPRITE  # read sprite from stdin

		local width=${#SPRITE[0]}
		local height=${#SPRITE[@]}

		if ((width == 0 || height == 0)); then
				echo "bmp::sprite: empty sprite input" >&2
				return 1
		fi

		local _row_i
		for ((_row_i = 0; _row_i < height; _row_i++)); do
				if ((${#SPRITE[_row_i]} != width)); then
						echo "bmp::sprite: ragged sprite — row $_row_i has length ${#SPRITE[_row_i]}, expected $width" >&2
						return 1
				fi
		done

		bmp::header "$width" "$height"
		local padding=$REPLY

		local r g b y x c row
		for ((y = 0; y < height; y++)); do
				row=${SPRITE[height - y - 1]}  # BMP bottom-up
				for ((x = 0; x < width; x++)); do
						c=${row:x:1}
						read -r r g b <<< "${PALETTE[$c]:-0 0 0}"
						bmp::rgb "$r" "$g" "$b"
				done
				bmp::pad "$padding"
		done
}

# Build a 24-bit BMP from an array of pixels and emit it to stdout.
# <array_name> must hold width*height elements, each "r g b" decimal
# (0-255), in natural top-to-bottom / left-to-right order — the same
# layout produced by bmp::read. Uses binary::buffer to assemble the whole
# file (header + bottom-up pixel data) before a single write.
# Usage: bmp::from_array <width> <height> <array_name>
bmp::from_array() {
		local width=$1 height=$2 arrname=$3
		local -n _bmp_fa_arr=$arrname

		((${#_bmp_fa_arr[@]} == width * height)) || {
				echo "bmp::from_array: array has ${#_bmp_fa_arr[@]} elements, expected $((width * height)) ($width x $height)" >&2
				return 1
		}

		local row_size=$((width * 3)) padding=0
		while ((row_size % 4 != 0)); do
				((padding++))
				((row_size++))
		done
		local pixel_data_size=$((row_size * height))
		local pixel_data_offset=$((14 + 40))
		local file_size=$((pixel_data_size + pixel_data_offset))

		binary::buffer::init bmp_fa
		binary::buffer::insert::raw bmp_fa 66 77       # "BM"
		binary::buffer::insert::uint bmp_fa "$file_size" 4
		binary::buffer::insert::uint bmp_fa 0 4
		binary::buffer::insert::uint bmp_fa "$pixel_data_offset" 4
		binary::buffer::insert::uint bmp_fa 40 4       # DIB header size
		binary::buffer::insert::uint bmp_fa "$width" 4
		binary::buffer::insert::uint bmp_fa "$height" 4
		binary::buffer::insert::uint bmp_fa 1 2        # planes
		binary::buffer::insert::uint bmp_fa 24 2       # bits per pixel
		binary::buffer::insert::uint bmp_fa 0 4        # compression
		binary::buffer::insert::uint bmp_fa 0 4        # image size
		binary::buffer::insert::uint bmp_fa 0 4        # x pixels/m
		binary::buffer::insert::uint bmp_fa 0 4        # y pixels/m
		binary::buffer::insert::uint bmp_fa 0 4        # colors used
		binary::buffer::insert::uint bmp_fa 0 4        # colors important

		local by ty x idx r g b _pad_i
		for ((by = 0; by < height; by++)); do
				ty=$((height - by - 1))  # invert: BMP stores rows bottom-up
				for ((x = 0; x < width; x++)); do
						idx=$((ty * width + x))
						read -r r g b <<< "${_bmp_fa_arr[idx]}"
						binary::buffer::insert::raw bmp_fa "$b" "$g" "$r"
				done
				for ((_pad_i = 0; _pad_i < padding; _pad_i++)); do
						binary::buffer::insert::raw bmp_fa 0
				done
		done

		binary::buffer::write bmp_fa
}
