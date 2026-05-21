# `math::factorial`

**Signature:** `math::factorial(n)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Factorial (integer)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `n` | integer | Yes | |

## Source

```bash
math::factorial() {
  local n
  if [[ ! -t 0 ]]; then n=$(cat); else n="$1"; fi
    local result=1
    _math::is_float "$n" && { echo "math::factorial: float input — factorial is integer-only" >&2; return 1; }
    (( n < 0 )) && { echo "math::factorial: negative input" >&2; return 1; }
    local i
    for (( i=2; i<=n; i++ )); do result=$(( result * i )); done
    echo "$result"
}
```

