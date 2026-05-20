# `math::sqrt`

Square root

## Source

```bash
math::sqrt() {
    local scale="${2:-$MATH_SCALE}"
    math::bc "sqrt($1)" "$scale"
}
```

## Module

[`math`](../math.md)
