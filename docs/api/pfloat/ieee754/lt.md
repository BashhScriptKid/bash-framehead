# `pfloat::ieee754::lt`

**Signature:** `pfloat::ieee754::lt(arg1, arg2)`

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
pfloat::ieee754::lt() {
  local a="$1" b="$2"
  local sign_a=$(_ieee754::get_sign "$a")
  local sign_b=$(_ieee754::get_sign "$b")

  if ((sign_a && ! sign_b)); then return 0; fi  # Negative < Positive
  if ((! sign_a && sign_b)); then return 1; fi  # Positive >= Negative

  # Same sign - compare as integers (reverse for negative)
  if ((sign_a)); then
    ((a > b))
  else
    ((a < b))
  fi
}
```

