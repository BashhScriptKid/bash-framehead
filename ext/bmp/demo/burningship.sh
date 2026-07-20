#!/usr/bin/env bash
# demo/mandelbrot.sh — Mandelbrot set renderer
#
# Pure-Bash escape-time fractal using Q16.16 fixed-point arithmetic (no
# bc, no floats) — fixed-point keeps every multiply/compare a plain
# 64-bit integer op, which is what makes per-pixel iteration fast enough
# in Bash. Colored by iteration count via bmp::hsv2rgb, rendered to BMP
# via bmp::header/bmp::rgb/bmp::pad.
#
# Usage: bash ext/bmp/demo/mandelbrot.sh [-w width] [-h height] [-x cx]
#        [-y cy] [-z zoom] [-max max_iter] [-out file.bmp]
#   -w   image width in pixels      (default: 120)
#   -h   image height in pixels     (default: 90)
#   -x   real-axis center           (default: -0.5)
#   -y   imaginary-axis center      (default: 0)
#   -z   zoom factor (>1 = closer)  (default: 1)
#   -max escape-time iteration cap  (default: 30)
#   -out output BMP path            (default: /tmp/mandelbrot.bmp)

cd "$(dirname "${BASH_SOURCE[0]}")/../../.."

source ./bash-framehead.sh
source ./ext/bmp/bmp.sh

SCALE=65536

# Convert a decimal string (e.g. "-0.5", "2", "1.25") to a Q16.16
# fixed-point integer. 10# forces base-10 so leading zeros never get
# misread as octal.
_parse_fixed() {
		local s=$1 sign=1
		[[ "$s" == -* ]] && { sign=-1; s=${s#-}; }
		local int_part=${s%%.*} frac_part=""
		[[ "$s" == *.* ]] && frac_part=${s#*.}
		[[ -z "$int_part" ]] && int_part=0
		local frac_len=${#frac_part} frac_val=0
		((frac_len > 0)) && frac_val=$((10#$frac_part))
		local denom=1 i
		for ((i = 0; i < frac_len; i++)); do denom=$((denom * 10)); done
		local fixed=$(( (10#$int_part) * SCALE + frac_val * SCALE / denom ))
		((sign < 0)) && fixed=$((-fixed))
		echo "$fixed"
}

WIDTH=120
HEIGHT=90
CX=-0.5
CY=0
ZOOM=1
MAX_ITER=30
OUT=/tmp/mandelbrot.bmp

while (($#)); do
		case $1 in
				-w) WIDTH=$2; shift 2 ;;
				-h) HEIGHT=$2; shift 2 ;;
				-x) CX=$2; shift 2 ;;
				-y) CY=$2; shift 2 ;;
				-z) ZOOM=$2; shift 2 ;;
				-max) MAX_ITER=$2; shift 2 ;;
				-out) OUT=$2; shift 2 ;;
				*) echo "unknown argument: $1" >&2; exit 1 ;;
		esac
done

CX_FIXED=$(_parse_fixed "$CX")
CY_FIXED=$(_parse_fixed "$CY")
ZOOM_FIXED=$(_parse_fixed "$ZOOM")

# Base half-span of the view at zoom=1; actual span shrinks as zoom grows.
BASE_SPAN_FIXED=$(( 2 * SCALE ))
SPAN_X=$(( BASE_SPAN_FIXED * SCALE / ZOOM_FIXED ))
SPAN_Y=$(( SPAN_X * HEIGHT / WIDTH ))  # keep pixels square, no stretching

RE_MIN=$((CX_FIXED - SPAN_X))
RE_MAX=$((CX_FIXED + SPAN_X))
IM_MIN=$((CY_FIXED - SPAN_Y))
IM_MAX=$((CY_FIXED + SPAN_Y))

echo "Rendering ${WIDTH}x${HEIGHT}, center=($CX,$CY), zoom=$ZOOM, max_iter=$MAX_ITER -> $OUT" >&2
_start=$SECONDS

{
		bmp::header "$WIDTH" "$HEIGHT"
		padding=$REPLY

		for ((py = HEIGHT - 1; py >= 0; py--)); do  # BMP stores rows bottom-up
				cy=$(( IM_MIN + (IM_MAX - IM_MIN) * py / (HEIGHT - 1) ))
				for ((px = 0; px < WIDTH; px++)); do
						cx=$(( RE_MIN + (RE_MAX - RE_MIN) * px / (WIDTH - 1) ))

						x=0 y=0 iter=0
						while ((iter < MAX_ITER)); do
								x2=$(( (x * x) >> 16 ))
								y2=$(( (y * y) >> 16 ))
								((x2 + y2 > 4 * SCALE)) && break
								xy=$(( (x * y) >> 16 ))
								x=$(( x2 - y2 + cx ))
								y=$(( 2 * xy + cy ))
								((iter += 1))
						done

						if ((iter == MAX_ITER)); then
								bmp::rgb 0 0 0
						else
								# Inlined full-saturation/value HSV->RGB (s=v=100 collapses
								# bmp::hsv2rgb's p term to 0). Done by hand instead of
								# calling bmp::hsv2rgb to avoid a $(...) subshell fork per
								# pixel — this is the hottest loop in the script.
								hue=$(( (iter * 360 / MAX_ITER) % 360 ))
								hi=$((hue / 60)); rem=$((hue % 60))
								f256=$(( (rem * 256 + 30) / 60 ))
								((f256 > 255)) && f256=255
								q=$(( (255 * (255 - f256) + 127) / 255 ))
								t=$(( (255 * f256 + 127) / 255 ))
								case $hi in
										0) bmp::rgb 255 "$t" 0 ;;
										1) bmp::rgb "$q" 255 0 ;;
										2) bmp::rgb 0 255 "$t" ;;
										3) bmp::rgb 0 "$q" 255 ;;
										4) bmp::rgb "$t" 0 255 ;;
										*) bmp::rgb 255 0 "$q" ;;
								esac
						fi
				done
				bmp::pad "$padding"
		done
} > "$OUT"

echo "Done in $((SECONDS - _start))s" >&2
