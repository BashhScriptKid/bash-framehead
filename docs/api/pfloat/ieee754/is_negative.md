# `pfloat::ieee754::is_negative`

**Signature:** `pfloat::ieee754::is_negative(arg1)`

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
pfloat::ieee754::is_negative() {
  local sign=$(_ieee754::get_sign "$1")
  ((sign == 1))
}
```

