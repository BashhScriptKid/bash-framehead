# `pfloat::fixed::is_zero`

**Signature:** `pfloat::fixed::is_zero(arg1)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
pfloat::fixed::is_zero() {
  local a
  a=$(_pfloat::_to_scaled "$1")
  ((a == 0))
}
```

