# `math::lerp_unclamped`

_No description available._

## Source

```bash
math::lerp_unclamped() {
    local a="$1" b="$2" t="$3" scale="${4:-$MATH_SCALE}"
    math::bc "$a + $t * ($b - $a)" "$scale"
}
```

## Module

[`math`](../math.md)
