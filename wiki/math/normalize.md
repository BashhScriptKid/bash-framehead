# `math::normalize`

Normalise a value to 0.0-1.0 range

## Usage

```bash
math::normalize value min max [scale]
```

## Source

```bash
math::normalize() {
    local v="$1" lo="$2" hi="$3" scale="${4:-$MATH_SCALE}"
    math::bc "($v - $lo) / ($hi - $lo)" "$scale"
}
```

## Module

[`math`](../math.md)
