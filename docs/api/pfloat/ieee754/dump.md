# `pfloat::ieee754::dump`

**Signature:** `pfloat::ieee754::dump(bits)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

IEEE 754: Dump bit layout for diagnostics

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `bits` | integer | Yes | |

## Source

```bash
pfloat::ieee754::dump() {
  local bits="$1"
  local sign=$(_ieee754::get_sign "$bits")
  local exp=$(_ieee754::get_exp "$bits")
  local mant=$(_ieee754::get_mant "$bits")
  local value
  value=$(pfloat::ieee754::to_string "$bits")

  # Convert exponent and mantissa to binary strings
  local exp_bin="" mant_bin=""
  local temp=$exp i
  for ((i=0; i<11; i++)); do
    exp_bin="$((temp & 1))$exp_bin"
    temp=$((temp >> 1))
  done
  temp=$mant
  for ((i=0; i<52; i++)); do
    mant_bin="$((temp & 1))$mant_bin"
    temp=$((temp >> 1))
  done

  printf "Value: %s, Int: %s, Sign: %s, Exp: %s (%s), Mant: %s (%s)\n" \
    "$value" "$bits" "$sign" "$exp" "$exp_bin" "$mant" "$mant_bin"
}
```

