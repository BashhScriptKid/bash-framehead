# `math::normalize`

**Signature:** `math::normalize(value, min, max, [scale])`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Normalise a value to 0.0-1.0 range

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `value` | string | Yes | |
| `min` | string | Yes | |
| `max` | string | Yes | |
| `scale` | string | No | |

## Source

```bash
math::normalize() {
    local v="$1" lo="$2" hi="$3" scale="${4:-$MATH_SCALE}"
    math::bc "($v - $lo) / ($hi - $lo)" "$scale"
}
```

