# `math::clamp`

Clamp n between min and max inclusive

## Usage

```bash
math::clamp n min max
```

## Source

```bash
math::clamp() {
    local n="$1" lo="$2" hi="$3"
    echo $(( n < lo ? lo : (n > hi ? hi : n) ))
}
```

## Module

[`math`](../math.md)
