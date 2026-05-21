# `math::logn`

**Signature:** `math::logn(value, base)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Log with arbitrary base

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `value` | string | Yes | |
| `base` | string | Yes | |

## Source

```bash
math::logn() {
    math::bc "l($1) / l($2)"
}
```

