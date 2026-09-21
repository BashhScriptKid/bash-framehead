# `pfloat::fixed::min::fast`

**Signature:** `pfloat::fixed::min::fast(result_var, arg1, arg2)`

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
pfloat::fixed::min::fast() {
	local -n _out=${@: -1}
	local _a _b
	_pfloat::_to_scaled::fast "$1" _a
	_pfloat::_to_scaled::fast "$2" _b
	if ((_a < _b)); then
		_pfloat::_from_scaled::fast $_a _out
	else
		_pfloat::_from_scaled::fast $_b _out
	fi
}
```

