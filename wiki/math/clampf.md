# `math::clampf`

_No description available._

## Source

```bash
math::clampf() {
    local n="$1" lo="$2" hi="$3"
    local scale=${4:-$MATH_SCALE}
    local result
    result=$(math::bc "if ($n < $lo) $lo else if ($n > $hi) $hi else $n" "$scale")
    # Format with consistent decimal places (bc is being inconsistent for some reason)
    printf "%.${scale}f\n" "$result"
}
```

## Module

[`math`](../math.md)
