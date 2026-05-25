# `pfloat::ieee754::is_zero`

**Signature:** `pfloat::ieee754::is_zero(arg1)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

IEEE 754: Check if value is zero (+0 or -0)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
pfloat::ieee754::is_zero() {
	_ieee754::is_zero "$1"
}
```

