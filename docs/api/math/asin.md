# `math::asin`

**Signature:** `math::asin(arg1)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
math::asin() {
		math::bc "a($1 / sqrt(1 - $1^2))"
}
```

