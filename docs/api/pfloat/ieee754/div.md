# `pfloat::ieee754::div`

**Signature:** `pfloat::ieee754::div(arg1, arg2, ...)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

IEEE 754: Division

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
pfloat::ieee754::div() {
  local a="$1" b="$2"

  # Extract components
  local sign_a=$(_ieee754::get_sign "$a")
  local sign_b=$(_ieee754::get_sign "$b")
  local exp_a=$(_ieee754::get_exp "$a")
  local exp_b=$(_ieee754::get_exp "$b")
  local mant_a=$(_ieee754::get_mant "$a")
  local mant_b=$(_ieee754::get_mant "$b")

  # Handle division by zero
  if _ieee754::is_zero "$b"; then
    if _ieee754::is_zero "$a"; then
      echo "NaN" >&2
      echo $((2047 << 52 | 1))  # NaN
      return
    fi
    echo $(( (sign_a ^ sign_b) << 63 | 2047 << 52 ))  # Infinity
    return
  fi

  # Handle special cases
  if ((exp_a == 2047 || exp_b == 2047)); then
    echo $(( (sign_a ^ sign_b) << 63 | 2047 << 52 ))
    return
  fi

  # Result sign
  local result_sign=$((sign_a ^ sign_b))

  # Result exponent (add bias)
  local result_exp=$((exp_a - exp_b + 1023))

  # Add implicit leading 1
  if ((exp_a > 0)); then mant_a=$((mant_a | 4503599627370496)); fi
  if ((exp_b > 0)); then mant_b=$((mant_b | 4503599627370496)); fi

  # Divide mantissas using bc for arbitrary precision
  # Compute 53-bit quotient directly
  local q
  q=$(echo "($mant_a * 4503599627370496) / $mant_b" | bc)  # 2^52

  # Normalize q to [2^52, 2^53) range
  local shift=0
  while ((q >= 9007199254740992)); do
    q=$((q >> 1))
    ((shift++))
  done
  while ((q < 4503599627370496 && q > 0)); do
    q=$((q << 1))
    ((shift--))
  done

  ((result_exp += shift))
  local result_mant=$((q & 4503599627370495))

  # Check for overflow/underflow
  if ((result_exp >= 2047)); then
    echo $((result_sign << 63 | 2047 << 52))
    return
  fi

  # Remove implicit leading 1 and pack
  result_mant=$((result_mant & 4503599627370495))
  _ieee754::pack "$result_sign" "$result_exp" "$result_mant"
}
```

