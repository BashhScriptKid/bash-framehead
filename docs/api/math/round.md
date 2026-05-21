# `math::round`

**Signature:** `math::round(n, [decimal_places])`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Round to nearest integer (or to d decimal places)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `n` | integer | Yes | |
| `decimal_places` | string | No | |

## Source

```bash
math::round() {
  local n
  if [[ ! -t 0 ]]; then n=$(cat); else n="$1"; fi
    local d="${2:-0}"
    math::bc "scale=${d}; (${n} + 0.5 * (${n} > 0) - 0.5 * (${n} < 0)) / 1" "$d"
}
```

