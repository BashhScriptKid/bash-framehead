# `pfloat::fixed::normalize`

**Signature:** `pfloat::fixed::normalize(arg1, arg2, arg3)`

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

## Source

```bash
pfloat::fixed::normalize() {
	local v="$1" lo="$2" hi="$3"
	pfloat::fixed::inv_lerp "$v" "$lo" "$hi"
}
```

