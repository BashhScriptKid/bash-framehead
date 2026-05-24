# ext/bmp — BMP Image Generation

Pure-Bash 24-bit BMP file generation. Adapted from Dave Eddy's
[bash-bmp](https://github.com/bahamas10/bash-bmp) (MIT).

## Dependencies

- **bash-framehead core**: `binary::u16le`, `binary::u32le`
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
Convert a hex color string to space-separated decimal RGB.
```bash
bmp::hex2rgb "#ff0000"     # "255 0 0"
bmp::hex2rgb "#00ff00"     # "0 255 0"
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
```bash
cat smile.txt | bmp::sprite palette.txt > smile.bmp
```

## Limitations

- **24-bit color only**: no 1/4/8-bit indexed modes, no alpha channel
- **Uncompressed only**: BMPs are large — 800×600 = ~1.4 MB
- **Bash string capacity**: practical limit ~10 MB pixel data
- **No built-in text rendering**: `bmp::sprite` maps characters to palette
  colors; actual font rendering is out of scope
