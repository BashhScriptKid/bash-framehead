# `pfloat::fixed::inv_lerp`

**Signature:** `pfloat::fixed::inv_lerp(arg1, arg2, arg3)`

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
pfloat::fixed::inv_lerp() {
  local v="$1" a="$2" b="$3"
  local num den
  num=$(pfloat::fixed::sub "$v" "$a")
  den=$(pfloat::fixed::sub "$b" "$a")
  pfloat::fixed::div "$num" "$den"
}
```

