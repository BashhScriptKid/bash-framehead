# `math::sigmoid::singleton`

**Signature:** `math::sigmoid::singleton(value, [scale])`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Sigmoid — single value escape hatch

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `value` | string | Yes | |
| `scale` | string | No | |

## Source

```bash
math::sigmoid::singleton() {
    local scale="${2:-$MATH_SCALE}"
    math::bc "1 / (1 + e(-($1)))" "$scale"
}
```

