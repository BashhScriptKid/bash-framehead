# `pfloat::fixed::add::fast`

**Signature:** `pfloat::fixed::add::fast(pfloat::fixed::op::fast, <a>, [<b>], <result_var>)`

**Module:** [`pfloat`](../../../pfloat.md) — [Guide](../../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

--- ::fast arithmetic (nameref output, zero subshells) ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `pfloat::fixed::op::fast` | string | Yes | |
| `<a>` | string | Yes | |
| `<b>` | string | No | |
| `<result_var>` | variable | Yes | |

## Source

```bash
pfloat::fixed::add::fast() {
	local -n _out=${@: -1}
	local _a _b
	_pfloat::_to_scaled::fast "$1" _a
	_pfloat::_to_scaled::fast "$2" _b
	_pfloat::_from_scaled::fast $((_a + _b)) _out
}
```

