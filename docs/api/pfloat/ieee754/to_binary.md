# `pfloat::ieee754::to_binary`

**Signature:** `pfloat::ieee754::to_binary(bits, [separator])`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

IEEE 754: Convert to binary string

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `bits` | integer | Yes | |
| `separator` | string | No | |

## Source

```bash
pfloat::ieee754::to_binary() {
  local bits="$1"
  local sep
  if [[ $# -ge 2 ]]; then sep="$2"; else sep=" "; fi
  local sign=$(_ieee754::get_sign "$bits")
  local exp=$(_ieee754::get_exp "$bits")
  local mant=$(_ieee754::get_mant "$bits")

  # Convert to binary strings
  local exp_bin="" mant_bin="" i temp
  temp=$exp
  for ((i=0; i<11; i++)); do
    exp_bin="$((temp & 1))$exp_bin"
    temp=$((temp >> 1))
  done
  temp=$mant
  for ((i=0; i<52; i++)); do
    mant_bin="$((temp & 1))$mant_bin"
    temp=$((temp >> 1))
  done

  printf "%s%s%s%s%s\n" "$sign" "$sep" "$exp_bin" "$sep" "$mant_bin"
}
```

