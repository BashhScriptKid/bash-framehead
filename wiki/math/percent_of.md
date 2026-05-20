# `math::percent_of`

Calculate what value is p% of total

## Usage

```bash
math::percent_of percent total [scale]
```

## Source

```bash
math::percent_of() {
    local pct="$1" total="$2" scale="${3:-2}"
    math::bc "($pct / 100) * $total" "$scale"
}
```

## Module

[`math`](../math.md)
