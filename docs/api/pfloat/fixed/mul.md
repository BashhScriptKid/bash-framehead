# `pfloat::fixed::mul`

**Signature:** `pfloat::fixed::mul(arg1, arg2)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
pfloat::fixed::mul() {
	local a="$1" b="$2"

	# Fast path for integers - avoid overflow from scaling
	if _pfloat::_is_integer "$a" && _pfloat::_is_integer "$b"; then
		echo "$((a * b))"
		return
	fi

	local a_scaled b_scaled result scale_factor
	a_scaled=$(_pfloat::_to_scaled "$a")
	b_scaled=$(_pfloat::_to_scaled "$b")
	scale_factor=$(_pfloat::_scale_factor)
	result=$(((a_scaled * b_scaled) / scale_factor))
	_pfloat::_from_scaled "$result"
}
```

