# `pfloat::fixed::softplus`

**Signature:** `pfloat::fixed::softplus(arg1)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
pfloat::fixed::softplus() {
  local x="$1"
  local exp_val one_plus_exp

  if pfloat::fixed::lt "$x" "-10"; then
    echo "0"
    return
  fi

  exp_val=$(pfloat::fixed::_exp_approx "$x")
  one_plus_exp=$(pfloat::fixed::add "1" "$exp_val")

  pfloat::fixed::_ln_approx "$one_plus_exp"
}
```

