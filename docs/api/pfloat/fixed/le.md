# `pfloat::fixed::le`

**Signature:** `pfloat::fixed::le(arg1, arg2)`

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
pfloat::fixed::le() {
  local a b
  a=$(_pfloat::_to_scaled "$1")
  b=$(_pfloat::_to_scaled "$2")
  ((a <= b))
}
```

