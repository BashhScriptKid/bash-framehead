# `pfloat::fixed::percent_change`

**Signature:** `pfloat::fixed::percent_change(arg1, arg2)`

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
pfloat::fixed::percent_change() {
	local old="$1" new="$2"
	local diff
	diff=$(pfloat::fixed::sub "$new" "$old")
	pfloat::fixed::mul $(pfloat::fixed::div "$diff" "$old") "100"
}
```

