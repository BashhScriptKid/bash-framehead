# `pfloat::fixed::round`

**Signature:** `pfloat::fixed::round(arg1)`

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
pfloat::fixed::round() {
  local a="$1" sign="" int_part frac_part first_digit

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
  first_digit="${frac_part:0:1}"

  if ((first_digit >= 5)); then
    if [[ "$sign" == "-" ]]; then
      echo "-$((int_part + 1))"
    else
      echo "$((int_part + 1))"
    fi
  else
    echo "${sign}${int_part}"
  fi
}
```

