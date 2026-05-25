# `pfloat::fixed::dist3`

**Signature:** `pfloat::fixed::dist3(arg1, arg2, arg3, arg4, arg5)`

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
pfloat::fixed::dist3() {
	local x1="$1" y1="$2" z1="$3" x2="$4" y2="$5" z2="$6"
	local dx dy dz dx2 dy2 dz2 sum
	dx=$(pfloat::fixed::sub "$x1" "$x2")
	dy=$(pfloat::fixed::sub "$y1" "$y2")
	dz=$(pfloat::fixed::sub "$z1" "$z2")
	dx2=$(pfloat::fixed::mul "$dx" "$dx")
	dy2=$(pfloat::fixed::mul "$dy" "$dy")
	dz2=$(pfloat::fixed::mul "$dz" "$dz")
	sum=$(pfloat::fixed::add "$dx2" "$dy2" "$dz2")
	pfloat::fixed::sqrt "$sum"
}
```

