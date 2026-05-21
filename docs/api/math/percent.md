# `math::percent`

**Signature:** `math::percent(part, total, [scale])`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Calculate percentage: (part / total) * 100

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `part` | string | Yes | |
| `total` | string | Yes | |
| `scale` | string | No | |

## Source

```bash
math::percent() {
    local part="$1" total="$2" scale="${3:-2}"
    math::bc "($part / $total) * 100" "$scale"
}
```

