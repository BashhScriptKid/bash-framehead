# `pfloat::fixed::dist2`

**Signature:** `pfloat::fixed::dist2(arg1, arg2, arg3, arg4)`

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

## Source

```bash
pfloat::fixed::dist2() {
	local x1="$1" y1="$2" x2="$3" y2="$4"
	local dx dy dx2 dy2 sum
	dx=$(pfloat::fixed::sub "$x1" "$x2")
	dy=$(pfloat::fixed::sub "$y1" "$y2")
	dx2=$(pfloat::fixed::mul "$dx" "$dx")
	dy2=$(pfloat::fixed::mul "$dy" "$dy")
	sum=$(pfloat::fixed::add "$dx2" "$dy2")
	pfloat::fixed::sqrt "$sum"
}
```

