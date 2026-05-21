# `math::exp`

**Signature:** `math::exp(arg1)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Exponential e^n

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
math::exp() {
    math::bc "e($1)"
}
```

