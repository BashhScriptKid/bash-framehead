# `pfloat::ieee754::add`

**Signature:** `pfloat::ieee754::add(bits_a, bits_b)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

IEEE 754: Addition

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `bits_a` | string | Yes | |
| `bits_b` | string | Yes | |

## Source

```bash
pfloat::ieee754::add() {
  local a="$1" b="$2"
  
  # Extract components
  local sign_a=$(_ieee754::get_sign "$a")
  local sign_b=$(_ieee754::get_sign "$b")
  local exp_a=$(_ieee754::get_exp "$a")
  local exp_b=$(_ieee754::get_exp "$b")
  local mant_a=$(_ieee754::get_mant "$a")
  local mant_b=$(_ieee754::get_mant "$b")
  
  # Add implicit leading 1 for normalized numbers
  if ((exp_a > 0)); then mant_a=$((mant_a | 4503599627370496)); fi
  if ((exp_b > 0)); then mant_b=$((mant_b | 4503599627370496)); fi
  
  # Handle special cases
  if ((exp_a == 2047 || exp_b == 2047)); then
    # NaN or Inf
    echo "$a"  # Simplified - should handle NaN propagation
    return
  fi
  
  # Align exponents (shift smaller mantissa)
  if ((exp_a > exp_b)); then
    local diff=$((exp_a - exp_b))
    ((diff > 52)) && diff=53
    mant_b=$((mant_b >> diff))
    exp_b=$exp_a
  elif ((exp_b > exp_a)); then
    local diff=$((exp_b - exp_a))
    ((diff > 52)) && diff=53
    mant_a=$((mant_a >> diff))
    exp_a=$exp_b
  fi
  
  # Add or subtract mantissas based on signs
  local result_mant result_sign
  if ((sign_a == sign_b)); then
    result_mant=$((mant_a + mant_b))
    result_sign=$sign_a
  else
    if ((mant_a >= mant_b)); then
      result_mant=$((mant_a - mant_b))
      result_sign=$sign_a
    else
      result_mant=$((mant_b - mant_a))
      result_sign=$sign_b
    fi
  fi
  
  # Normalize result
  local result_exp=$exp_a
  if ((result_mant > 0)); then
    while ((result_mant < 4503599627370496 && result_exp > 0)); do
      result_mant=$((result_mant << 1))
      ((result_exp--))
    done
    while ((result_mant >= 9007199254740992)); do
      result_mant=$((result_mant >> 1))
      ((result_exp++))
    done
  fi
  
  # Check for overflow
  if ((result_exp >= 2047)); then
    echo $((result_sign << 63 | 2047 << 52))  # Infinity
    return
  fi

  # Handle zero result (before masking)
  if ((result_mant == 0)); then
    echo 0
    return
  fi

  # Remove implicit leading 1 and pack
  result_mant=$((result_mant & 4503599627370495))

  _ieee754::pack "$result_sign" "$result_exp" "$result_mant"
}
```

