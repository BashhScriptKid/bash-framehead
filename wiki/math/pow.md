# `math::pow`

Integer exponentiation

## Usage

```bash
math::pow base exponent
```

## Source

```bash
math::pow() {
    local base="$1" exp="$2" result=1
    while (( exp > 0 )); do
        (( exp % 2 == 1 )) && result=$(( result * base ))
        base=$(( base * base ))
        exp=$(( exp / 2 ))
    done
    echo "$result"
}
```

## Module

[`math`](../math.md)
