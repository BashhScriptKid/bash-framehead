# `pfloat::ieee754::is_finite`

**Signature:** `pfloat::ieee754::is_finite(arg1)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

IEEE 754: Check if value is finite (not NaN, not Inf)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
pfloat::ieee754::is_finite() {
	local exp=$(_ieee754::get_exp "$1")
	((exp < 2047))
}
```

