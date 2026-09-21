# `pfloat::fixed::round::fast`

**Signature:** `pfloat::fixed::round::fast(result_var, arg1)`

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
pfloat::fixed::round::fast() {
	local -n _out=${@: -1}
	local a=$1 sgn="" intp fracp first
	if [[ "$a" == -* ]]; then
		sgn="-"; a="${a#-}"
	fi
	if [[ "$a" == *.* ]]; then
		intp="${a%%.*}"; fracp="${a#*.}"
	else
		_out="$1"; return
	fi
	[[ -z "$intp" ]] && intp="0"
	first="${fracp:0:1}"
	if ((first >= 5)); then
		_out="${sgn}$((intp + 1))"
	else
		_out="${sgn}${intp}"
	fi
}
```

