# `pfloat::fixed::neg`

**Signature:** `pfloat::fixed::neg(arg1)`

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
pfloat::fixed::neg() {
  local a_scaled
  a_scaled=$(_pfloat::_to_scaled "$1")
  _pfloat::_from_scaled "$((-a_scaled))"
}
```

