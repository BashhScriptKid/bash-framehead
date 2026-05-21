# `pfloat::fixed::floor`

**Signature:** `pfloat::fixed::floor(arg1)`

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
pfloat::fixed::floor() {
  local a="$1" sign="" int_part frac_part

  if [[ "$a" == -* ]]; then
    sign="-"
    a="${a#-}"
  fi

  if [[ "$a" == *.* ]]; then
    int_part="${a%%.*}"
    frac_part="${a#*.}"
  else
    echo "$a"
    return
  fi

  [[ -z "$int_part" ]] && int_part="0"

  if [[ "$sign" == "-" ]] && [[ "$frac_part" != "0" ]] && [[ "$frac_part" != "" ]]; then
    int_part=$((int_part + 1))
    echo "-${int_part}"
  else
    echo "${sign}${int_part}"
  fi
}
```

