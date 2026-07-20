# ext/bmp — BMP Image Generation & Parsing

Pure-Bash 24-bit BMP file generation and parsing. Generation is adapted
from Dave Eddy's [bash-bmp](https://github.com/bahamas10/bash-bmp) (MIT).

## Dependencies

- **bash-framehead core**: `binary::u16le`, `binary::u32le`, `binary::buffer::*`
- **External**: none

## Usage

### One-shot generators

```bash
source ./bash-framehead.sh
source ./ext/bmp/bmp.sh

# Linear gradient (R on X, B on Y)
bmp::gradient 800 600 linear > gradient.bmp

# Radial gradient (sunburst from center)
bmp::gradient 800 600 radial > sunburst.bmp

# Text sprite → BMP
cat <<'SPRITE' | bmp::sprite palette.txt > sprite.bmp
.X.
X.X
.X.
SPRITE
```

Palette file format (one per line: `<char> <#rrggbb>`):
```
X #ff0000
. #ffffff
```

### From an array of pixels

```bash
# pixels: width*height elements, each "r g b" (0-255), top-to-bottom /
# left-to-right order — same layout bmp::read produces
mapfile -t pixels < <(bmp::read source.bmp)
bmp::from_array 4 3 pixels > out.bmp
```

`bmp::from_array` always takes RGB. To build from HSV, convert per pixel
with `bmp::hsv2rgb` first:
```bash
declare -a pixels=()
for ((i = 0; i < 4; i++)); do
    pixels+=("$(bmp::hsv2rgb $((i * 90)) 100 100)")
done
bmp::from_array 4 1 pixels > hue_strip.bmp
```

### Reading

```bash
# Header fields as key=value lines
bmp::info image.bmp
#   width=800
#   height=600
#   top_down=0
#   planes=1
#   bits_per_px=24
#   compression=0
#   file_size=1440054
#   data_offset=54
#   image_size=0

# Pixel data as "r g b" lines, top-to-bottom / left-to-right
bmp::read image.bmp | head -1   # "255 0 0"
```

### Low-level pixel construction

```bash
bmp::header 256 256 > image.bmp
local pad=$REPLY
for ((y = 0; y < 256; y++)); do
    for ((x = 0; x < 256; x++)); do
        bmp::rgb $((x)) $((y)) $((128))
    done
    bmp::pad "$pad"
done >> image.bmp
```

## API Reference

### Pixels

#### `bmp::rgb <r> <g> <b>`
Emit a single pixel as a BGR byte triplet (BMP stores pixels in B,G,R order).
```bash
bmp::rgb 255 0 0    # pure red
bmp::rgb 0 128 0    # green
```

#### `bmp::pad <n>`
Emit N null bytes for 4-byte row alignment. Use the padding value from
`bmp::header` (returned via `$REPLY`).

### Header

#### `bmp::header <width> <height>`
Emit a 54-byte BMP file header + DIB info header for a 24-bit image.
Returns the per-row padding byte count via `$REPLY`.
```bash
bmp::header 800 600 > out.bmp
local padding=$REPLY
```

### Utilities

#### `bmp::hex2rgb <hex>`
Convert a hex color string to space-separated decimal RGB. Requires
exactly 6 hex digits (`#` prefix optional); fails otherwise.
```bash
bmp::hex2rgb "#ff0000"     # "255 0 0"
bmp::hex2rgb "#00ff00"     # "0 255 0"
bmp::hex2rgb "#f00"        # error: expected 6 hex digits
```

#### `bmp::rgb2hex <r> <g> <b>`
Convert decimal RGB (each 0-255) to a lowercase hex color string. Fails
on out-of-range input.
```bash
bmp::rgb2hex 255 0 0       # "#ff0000"
bmp::rgb2hex 256 0 0       # error: expected r/g/b in 0-255
```

#### `bmp::hsv2rgb <h> <s> <v>`
Convert HSV (`h`: 0-359 degrees, `s`/`v`: 0-100 percent) to decimal RGB.
Pure-integer fixed-point conversion — no `bc` dependency.
```bash
bmp::hsv2rgb 0 100 100     # "255 0 0"   (red)
bmp::hsv2rgb 120 100 100   # "0 255 0"   (green)
bmp::hsv2rgb 240 100 100   # "0 0 255"   (blue)
```

#### `bmp::rgb2hsv <r> <g> <b>`
Convert decimal RGB (each 0-255) to HSV (`h`: 0-359, `s`/`v`: 0-100),
the inverse of `bmp::hsv2rgb`.
```bash
bmp::rgb2hsv 255 0 0       # "0 100 100"
```

### Generators

#### `bmp::gradient <width> <height> [type]`
Emit a complete BMP gradient image to stdout.

| Type | Description |
|---|---|
| `linear` (default) | R channel varies with X, B channel varies with Y |
| `radial` | Distance from center mapped to R/B channels (sunburst) |

```bash
bmp::gradient 1920 1080 linear > bg.bmp
bmp::gradient 512 512 radial > sunburst.bmp
```

#### `bmp::sprite <palette_file>`
Read a text sprite from stdin and emit a BMP to stdout. Each character in
the input maps to a palette entry. Rows are rendered bottom-up per BMP spec.
All rows must be the same length — ragged sprite input is rejected.
```bash
cat smile.txt | bmp::sprite palette.txt > smile.bmp
```

### `bmp::from_array <width> <height> <array_name>`
Build a 24-bit BMP from an array of pixels and emit it to stdout.
`array_name` must hold exactly `width*height` elements, each an `"r g b"`
decimal string, in natural top-to-bottom / left-to-right order — the same
layout `bmp::read` produces, so the two compose directly for round-trips
or pixel-level edits. Internally assembles the whole file (header +
bottom-up pixel data) via `binary::buffer` before a single write. Fails
if the array length doesn't match `width*height`.
```bash
mapfile -t pixels < <(bmp::read in.bmp)
bmp::from_array 4 3 pixels > out.bmp   # byte-identical round trip
```

### `bmp::info <file>`
Parse a BMP file header and print its fields (`width`, `height`, `top_down`,
`planes`, `bits_per_px`, `compression`, `file_size`, `data_offset`,
`image_size`) as `key=value` lines. Fails on a missing file or bad
signature.
```bash
bmp::info photo.bmp
```

### `bmp::read <file>`
Read a 24-bit, uncompressed BMP and emit one `r g b` line per pixel, in
natural top-to-bottom / left-to-right order (the on-disk bottom-up row
order is inverted automatically; top-down files with a negative height
are read as-is). Fails on unsupported bit depth or compression.
```bash
bmp::read photo.bmp > pixels.txt
```

## Limitations

- **24-bit color only**: no 1/4/8-bit indexed modes, no alpha channel
- **Uncompressed only**: BMPs are large — 800×600 = ~1.4 MB; `bmp::read`
  rejects compressed (non-BI_RGB) files
- **Bash string capacity**: practical limit ~10 MB pixel data
- **No built-in text rendering**: `bmp::sprite` maps characters to palette
  colors; actual font rendering is out of scope
