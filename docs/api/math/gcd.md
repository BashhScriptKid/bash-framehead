# `math::gcd`

**Signature:** `math::gcd(a, b)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Greatest common divisor (Euclidean algorithm)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `a` | string | Yes | |
| `b` | string | Yes | |

## Source

```bash
math::gcd() {
    _math::is_float "$1" || _math::is_float "$2" && { echo "math::gcd: float input — gcd is integer-only" >&2; return 1; }
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

