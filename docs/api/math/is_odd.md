# `math::is_odd`

**Signature:** `math::is_odd(arg1)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if integer is odd

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
math::is_odd() {
  local n
  if [[ ! -t 0 ]]; then n=$(cat); else n="$1"; fi
    _math::is_float "$n" && { echo "math::is_odd: float input — is_odd is integer-only" >&2; return 1; }
    (( $n % 2 != 0 ))
}
```

