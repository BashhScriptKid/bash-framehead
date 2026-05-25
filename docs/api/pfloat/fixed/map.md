# `pfloat::fixed::map`

**Signature:** `pfloat::fixed::map(arg1, arg2, arg3, arg4, arg5)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |
| `arg3` | string | Yes | |
| `arg4` | string | Yes | |
| `arg5` | string | Yes | |

## Source

```bash
pfloat::fixed::map() {
	local v="$1" imin="$2" imax="$3" omin="$4" omax="$5"
	local t
	t=$(pfloat::fixed::inv_lerp "$v" "$imin" "$imax")
	pfloat::fixed::lerp "$omin" "$omax" "$t"
}
```

