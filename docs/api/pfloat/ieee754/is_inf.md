# `pfloat::ieee754::is_inf`

**Signature:** `pfloat::ieee754::is_inf(arg1)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

IEEE 754: Check if value is Infinity

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
pfloat::ieee754::is_inf() {
	_ieee754::is_inf "$1"
}
```

