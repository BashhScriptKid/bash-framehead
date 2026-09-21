# `pfloat::fixed::div::fast`

**Signature:** `pfloat::fixed::div::fast(result_var, arg1, arg2)`

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
pfloat::fixed::div::fast() {
	local -n _out=${@: -1}
	local _a _b _sf i
	_pfloat::_to_scaled::fast "$1" _a
	_pfloat::_to_scaled::fast "$2" _b
	if ((_b == 0)); then _out="0"; return 1; fi
	_sf=1; for ((i=0; i<pfloat_SCALE; i++)); do _sf+=0; done
	_pfloat::_from_scaled::fast $((_a * _sf / _b)) _out
}
```

