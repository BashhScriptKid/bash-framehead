# `pfloat::ieee754::mul`

**Signature:** `pfloat::ieee754::mul(arg1, arg2, ...)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

IEEE 754: Multiplication

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
pfloat::ieee754::mul() {
  local a="$1" b="$2"

  # Extract components
  local sign_a=$(_ieee754::get_sign "$a")
  local sign_b=$(_ieee754::get_sign "$b")
  local exp_a=$(_ieee754::get_exp "$a")
  local exp_b=$(_ieee754::get_exp "$b")
  local mant_a=$(_ieee754::get_mant "$a")
  local mant_b=$(_ieee754::get_mant "$b")

  # Handle special cases
  if ((exp_a == 2047 || exp_b == 2047)); then
    echo $(( (sign_a ^ sign_b) << 63 | 2047 << 52 ))  # Inf or NaN
    return
  fi

  # Result sign
  local result_sign=$((sign_a ^ sign_b))

  # Result exponent (subtract bias)
  local result_exp=$((exp_a + exp_b - 1023))

  # Add implicit leading 1
  if ((exp_a > 0)); then mant_a=$((mant_a | 4503599627370496)); fi
  if ((exp_b > 0)); then mant_b=$((mant_b | 4503599627370496)); fi

  # Multiply mantissas using shift-and-add (pure Bash)
  # Split 53-bit numbers into 26-bit chunks to avoid 64-bit overflow
  local a_lo=$((mant_a & 0x3FFFFFF))
  local a_hi=$((mant_a >> 26))
  local b_lo=$((mant_b & 0x3FFFFFF))
  local b_hi=$((mant_b >> 26))

  # Partial products
  local p0=$((a_lo * b_lo))
  local p1=$((a_hi * b_lo + a_lo * b_hi))
  local p2=$((a_hi * b_hi))

  # Combine: result = p2 + (p1 >> 26) + carry_from_lower_bits
  local p1_lo=$((p1 & 0x3FFFFFF))
  local carry=$(( ((p1_lo << 26) + p0) >> 52 ))
  local result_mant=$((p2 + (p1 >> 26) + carry))

  # Normalize
  while ((result_mant >= 9007199254740992)); do
    result_mant=$((result_mant >> 1))
    ((result_exp++))
  done

  # Check for overflow/underflow
  if ((result_exp >= 2047)); then
    echo $((result_sign << 63 | 2047 << 52))  # Infinity
    return
  fi
  if ((result_exp <= 0)); then
    # Subnormal or zero
    echo $((result_sign << 63))
    return
  fi

  # Remove implicit leading 1 and pack
  result_mant=$((result_mant & 4503599627370495))
  _ieee754::pack "$result_sign" "$result_exp" "$result_mant"
}
```

