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

_guard_core_deps=(binary::u16le binary::u32le)
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
# UTILITIES
# ==============================================================================

# Convert a hex color string to space-separated decimal RGB.
# Usage: bmp::hex2rgb "#ff0000"  →  "255 0 0"
bmp::hex2rgb() {
		local hex=${1#\#}
		local r=$((16#${hex:0:2}))
		local g=$((16#${hex:2:2}))
		local b=$((16#${hex:4:2}))
		echo "$r $g $b"
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
