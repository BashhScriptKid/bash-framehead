# `pfloat::ieee754::to_string`

**Signature:** `pfloat::ieee754::to_string(arg1)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

IEEE 754: Convert to decimal string

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
pfloat::ieee754::to_string() {
	_ieee754::to_string "$1"
}
```

