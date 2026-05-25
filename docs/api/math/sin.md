# `math::sin`

**Signature:** `math::sin(arg1)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

TRIGONOMETRY (requires bc)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
math::sin() {
		math::bc "s($1)"
}
```

