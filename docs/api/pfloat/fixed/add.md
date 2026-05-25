# `pfloat::fixed::add`

**Signature:** `pfloat::fixed::add(arg1, arg2)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
pfloat::fixed::add() {
	local a_scaled b_scaled result
	a_scaled=$(_pfloat::_to_scaled "$1")
	b_scaled=$(_pfloat::_to_scaled "$2")
	result=$((a_scaled + b_scaled))
	_pfloat::_from_scaled "$result"
}
```

