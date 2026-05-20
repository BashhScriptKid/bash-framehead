# `math::percent_change`

Percentage change from old to new

## Usage

```bash
math::percent_change old new [scale]
```

## Source

```bash
math::percent_change() {
    local old="$1" new="$2" scale="${3:-2}"
    math::bc "(($new - $old) / $old) * 100" "$scale"
}
```

## Module

[`math`](../math.md)
