# `math::map`

Map a value from one range to another

## Usage

```bash
math::map value in_min in_max out_min out_max [scale]
```

## Source

```bash
math::map() {
    local v="$1" imin="$2" imax="$3" omin="$4" omax="$5" scale="${6:-$MATH_SCALE}"
    math::bc "($v - $imin) * ($omax - $omin) / ($imax - $imin) + $omin" "$scale"
}
```

## Module

[`math`](../math.md)
