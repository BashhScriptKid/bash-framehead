# `math::gcd`

Greatest common divisor (Euclidean algorithm)

## Usage

```bash
math::gcd a b
```

## Source

```bash
math::gcd() {
    local a=$(( $1 < 0 ? -$1 : $1 ))
    local b=$(( $2 < 0 ? -$2 : $2 ))
    while (( b != 0 )); do
        local t=$b
        b=$(( a % b ))
        a=$t
    done
    echo "$a"
}
```

## Module

[`math`](../math.md)
