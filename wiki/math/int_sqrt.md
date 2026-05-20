# `math::int_sqrt`

Integer square root (floor)

## Usage

```bash
math::isqrt n
```

## Source

```bash
math::int_sqrt() {
    local n="$1" x
    (( n < 0 )) && { echo "math::isqrt: negative input" >&2; return 1; }
    (( n == 0 )) && echo 0 && return
    x=$(( n / 2 + 1 ))
    local y=$(( (x + n / x) / 2 ))
    while (( y < x )); do
        x=$y
        y=$(( (x + n / x) / 2 ))
    done
    echo "$x"
}
```

## Module

[`math`](../math.md)
