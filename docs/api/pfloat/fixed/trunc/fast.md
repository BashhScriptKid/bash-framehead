# `pfloat::fixed::trunc::fast`

**Signature:** `pfloat::fixed::trunc::fast(result_var, arg1, arg2)`

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
pfloat::fixed::trunc::fast() {
	local -n _out=$2
	local a=$1
	if [[ "$a" == *.* ]]; then
		a="${a%%.*}"
	fi
	[[ -z "$a" ]] && a="0"
	_out="$a"
}
```

