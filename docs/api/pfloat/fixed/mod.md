# `pfloat::fixed::mod`

**Signature:** `pfloat::fixed::mod(arg1, arg2)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
pfloat::fixed::mod() {
  local a_scaled b_scaled result
  a_scaled=$(_pfloat::_to_scaled "$1")
  b_scaled=$(_pfloat::_to_scaled "$2")

  if ((b_scaled == 0)); then
    echo "pfloat::fixed::mod: division by zero" >&2
    return 1
  fi

  result=$((a_scaled % b_scaled))
  _pfloat::_from_scaled "$result"
}
```

