# `math::sqrt`

**Signature:** `math::sqrt(arg1)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Square root

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
math::sqrt() {
  local n
  if [[ ! -t 0 ]]; then n=$(cat); else n="$1"; fi
    local scale="${2:-$MATH_SCALE}"
    math::bc "sqrt($n)" "$scale"
}
```

