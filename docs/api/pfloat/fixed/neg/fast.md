# `pfloat::fixed::neg::fast`

**Signature:** `pfloat::fixed::neg::fast(result_var, arg1)`

**Module:** [`pfloat`](../../../pfloat.md) — [Guide](../../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `arg1` | string | Yes | |

## Source

```bash
pfloat::fixed::neg::fast() {
	local -n _out=${@: -1}
	local _a
	_pfloat::_to_scaled::fast "$1" _a
	_pfloat::_from_scaled::fast $((- _a)) _out
}
```

