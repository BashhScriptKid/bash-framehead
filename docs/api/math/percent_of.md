# `math::percent_of`

**Signature:** `math::percent_of(percent, total, [scale])`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Calculate what value is p% of total

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `percent` | string | Yes | |
| `total` | string | Yes | |
| `scale` | string | No | |

## Source

```bash
math::percent_of() {
    local pct="$1" total="$2" scale="${3:-2}"
    math::bc "($pct / 100) * $total" "$scale"
}
```

