# `math::lcm`

Least common multiple

## Usage

```bash
math::lcm a b
```

## Source

```bash
math::lcm() {
    local a="$1" b="$2"
    local gcd
    gcd=$(math::gcd "$a" "$b")
    echo $(( (a / gcd) * b ))
}
```

## Module

[`math`](../math.md)
