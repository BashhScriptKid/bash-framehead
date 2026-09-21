# `pfloat::fixed::sub::fast`

**Signature:** `pfloat::fixed::sub::fast(result_var, arg1, arg2)`

**Module:** [`pfloat`](../../../pfloat.md) — [Guide](../../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
pfloat::fixed::sub::fast() {
	local -n _out=${@: -1}
	local _a _b
	_pfloat::_to_scaled::fast "$1" _a
	_pfloat::_to_scaled::fast "$2" _b
	_pfloat::_from_scaled::fast $((_a - _b)) _out
}
```

