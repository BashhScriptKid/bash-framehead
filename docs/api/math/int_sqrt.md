# `math::int_sqrt`

**Signature:** `math::int_sqrt(math::isqrt, n)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Integer square root (floor)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `math::isqrt` | string | Yes | |
| `n` | integer | Yes | |

## Source

```bash
math::int_sqrt() {
  local n
  if [[ ! -t 0 ]]; then n=$(cat); else n="$1"; fi
    local x
    _math::is_float "$n" && { echo "math::int_sqrt: float input — use math::sqrt" >&2; return 1; }
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

