# `math::percent`


**Calculate percentage:** (part / total) * 100


## Usage

```bash
math::percent part total [scale]
```

## Source

```bash
math::percent() {
    local part="$1" total="$2" scale="${3:-2}"
    math::bc "($part / $total) * 100" "$scale"
}
```

## Module

[`math`](../math.md)
