# `math::powf`

**Signature:** `math::powf(base, exponent)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Power (floating point)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `base` | string | Yes | |
| `exponent` | string | Yes | |

## Source

```bash
math::powf() {
    math::bc "e($2 * l($1))"
}
```

