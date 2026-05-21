# `pfloat::fixed::clamp`

**Signature:** `pfloat::fixed::clamp(arg1, arg2, arg3)`

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
pfloat::fixed::clamp() {
  local val lo hi val_s lo_s hi_s
  val_s=$(_pfloat::_to_scaled "$1")
  lo_s=$(_pfloat::_to_scaled "$2")
  hi_s=$(_pfloat::_to_scaled "$3")

  if ((val_s < lo_s)); then
    _pfloat::_from_scaled "$lo_s"
  elif ((val_s > hi_s)); then
    _pfloat::_from_scaled "$hi_s"
  else
    _pfloat::_from_scaled "$val_s"
  fi
}
```

