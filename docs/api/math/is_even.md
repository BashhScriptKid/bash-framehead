# `math::is_even`

**Signature:** `math::is_even(arg1)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if integer is even

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
math::is_even() {
  local n
  if [[ ! -t 0 ]]; then n=$(cat); else n="$1"; fi
    _math::is_float "$n" && { echo "math::is_even: float input — is_even is integer-only" >&2; return 1; }
    (( $n % 2 == 0 ))
}
```

