# `math::minf`

**Signature:** `math::minf(arg1, arg2)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Minimum of two values (float) — Usage: math::minf a b [scale]

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
math::minf() {
		local scale="${3:-$MATH_SCALE}"
		math::bc "if ($1 < $2) { $1 } else { $2 }" "$scale"
}
```

