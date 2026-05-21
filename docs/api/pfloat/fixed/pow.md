# `pfloat::fixed::pow`

**Signature:** `pfloat::fixed::pow(arg1, arg2)`

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
pfloat::fixed::pow() {
  local base="$1" exp="$2"
  local result="1"
  local neg_exp=0

  if ((exp < 0)); then
    neg_exp=1
    exp=$((-exp))
  fi

  while ((exp > 0)); do
    if ((exp % 2 == 1)); then
      result=$(pfloat::fixed::mul "$result" "$base")
    fi
    base=$(pfloat::fixed::mul "$base" "$base")
    exp=$((exp / 2))
  done

  if ((neg_exp)); then
    pfloat::fixed::div "1" "$result"
  else
    echo "$result"
  fi
}
```

