# `pfloat::ieee754::le`

**Signature:** `pfloat::ieee754::le(arg1, arg2)`

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
pfloat::ieee754::le() {
  local a="$1" b="$2"
  pfloat::ieee754::lt "$a" "$b" || pfloat::ieee754::eq "$a" "$b"
}
```

