# `pfloat::fixed::ceil::fast`

**Signature:** `pfloat::fixed::ceil::fast(result_var, arg1)`

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
pfloat::fixed::ceil::fast() {
	local -n _out=${@: -1}
	local a=$1 sgn="" intp fracp
	if [[ "$a" == -* ]]; then
		sgn="-"; a="${a#-}"
	fi
	if [[ "$a" == *.* ]]; then
		intp="${a%%.*}"; fracp="${a#*.}"
	else
		_out="$1"; return
	fi
	[[ -z "$intp" ]] && intp="0"
	if [[ "$fracp" =~ [1-9] ]]; then
		if [[ "$sgn" == "-" ]]; then
			_out="-${intp}"
		else
			_out="$((intp + 1))"
		fi
	else
		_out="${sgn}${intp}"
	fi
}
```

