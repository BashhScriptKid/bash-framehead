# `math::percent_change`

**Signature:** `math::percent_change(old, new, [scale])`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Percentage change from old to new

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `old` | string | Yes | |
| `new` | string | Yes | |
| `scale` | string | No | |

## Source

```bash
math::percent_change() {
    local old="$1" new="$2" scale="${3:-2}"
    math::bc "(($new - $old) / $old) * 100" "$scale"
}
```

