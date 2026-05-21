# `pfloat::fixed::lerp`

**Signature:** `pfloat::fixed::lerp(arg1, arg2, arg3)`

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
pfloat::fixed::lerp() {
  local a="$1" b="$2" t="$3"
  local diff scaled
  diff=$(pfloat::fixed::sub "$b" "$a")
  scaled=$(pfloat::fixed::mul "$diff" "$t")
  pfloat::fixed::add "$a" "$scaled"
}
```

