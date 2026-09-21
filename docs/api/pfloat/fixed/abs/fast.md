# `pfloat::fixed::abs::fast`

**Signature:** `pfloat::fixed::abs::fast(result_var, arg1)`

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
pfloat::fixed::abs::fast() {
	local -n _out=${@: -1}
	local _a=$1
	[[ "$_a" == -* ]] && _a="${_a#-}"
	_out=$_a
}
```

