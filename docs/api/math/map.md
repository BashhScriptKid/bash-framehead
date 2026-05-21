# `math::map`

**Signature:** `math::map(value, in_min, in_max, out_min, out_max, [scale])`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Map a value from one range to another

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `value` | string | Yes | |
| `in_min` | string | Yes | |
| `in_max` | string | Yes | |
| `out_min` | string | Yes | |
| `out_max` | string | Yes | |
| `scale` | string | No | |

## Source

```bash
math::map() {
    local v="$1" imin="$2" imax="$3" omin="$4" omax="$5" scale="${6:-$MATH_SCALE}"
    math::bc "($v - $imin) * ($omax - $omin) / ($imax - $imin) + $omin" "$scale"
}
```

