# `math::lerp`

Linear interpolation between a and b by factor t (0.0 - 1.0)

## Usage

```bash
math::lerp a b t [scale]
```

## Source

```bash
math::lerp() {
    local a="$1" b="$2" t="$3" scale="${4:-$MATH_SCALE}"
    math::bc "$a + ($b - $a) * $(math::clampf "$t" 0 1)" "$scale"
}
```

## Module

[`math`](../math.md)
