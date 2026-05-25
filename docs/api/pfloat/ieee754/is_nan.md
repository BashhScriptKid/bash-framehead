# `pfloat::ieee754::is_nan`

**Signature:** `pfloat::ieee754::is_nan(arg1)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

IEEE 754: Check if value is NaN

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
pfloat::ieee754::is_nan() {
	_ieee754::is_nan "$1"
}
```

