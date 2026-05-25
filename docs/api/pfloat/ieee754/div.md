# `pfloat::ieee754::div`

**Signature:** `pfloat::ieee754::div(bits_a, bits_b)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

IEEE 754: Division

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `bits_a` | string | Yes | |
| `bits_b` | string | Yes | |

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

	# Divide mantissas: compute (mant_a * 2^52) // mant_b
	# Use 10-bit chunks to keep intermediate values under 2^63
	local result_mant=0
	local rem=$mant_a
	local bits_done=0
	local chunk
	while ((bits_done < 52)); do
		chunk=10
		((bits_done + chunk > 52)) && chunk=$((52 - bits_done))
		rem=$((rem << chunk))
		local q_chunk=$((rem / mant_b))
		rem=$((rem - q_chunk * mant_b))
		result_mant=$(((result_mant << chunk) | q_chunk))
		bits_done=$((bits_done + chunk))
	done

	# Normalize
	if ((result_mant >= 9007199254740992)); then
		result_mant=$((result_mant >> 1))
		((result_exp++))
	elif ((result_mant < 4503599627370496 && result_exp > 1)); then
		result_mant=$((result_mant << 1))
		((result_exp--))
	fi

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

