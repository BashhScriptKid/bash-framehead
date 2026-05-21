# `math::fibonacci`

**Signature:** `math::fibonacci(n)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Fibonacci (nth term, 0-indexed)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `n` | integer | Yes | |

## Source

```bash
math::fibonacci() {
  local n
  if [[ ! -t 0 ]]; then n=$(cat); else n="$1"; fi
    local a=0 b=1 i
    _math::is_float "$n" && { echo "math::fibonacci: float input — fibonacci is integer-only" >&2; return 1; }
    (( n == 0 )) && echo 0 && return
    for (( i=1; i<n; i++ )); do
        local t=$(( a + b ))
        a=$b
        b=$t
    done
    echo "$b"
}
```

