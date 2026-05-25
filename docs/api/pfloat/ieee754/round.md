# `pfloat::ieee754::round`

**Signature:** `pfloat::ieee754::round(<bits>)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

IEEE 754: Round float to nearest integer, ties to even

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<bits>` | string | Yes | |

## Source

```bash
pfloat::ieee754::round() {
	local bits="$1"
	_ieee754::is_nan "$bits" && { echo "0"; return 1; }
	_ieee754::is_inf "$bits" && { echo "$bits"; return 0; }
	_ieee754::is_zero "$bits" && { echo "$bits"; return 0; }

	local sign; sign=$(_ieee754::get_sign "$bits")
	local exp;   exp=$(_ieee754::get_exp "$bits")
	local mant;  mant=$(_ieee754::get_mant "$bits")

	local unbiased=$(( exp - 1023 ))
	if (( unbiased < 0 )); then
		# |value| < 1
		if (( unbiased == -1 && mant > 0 )); then
			# 0.5 < |value| < 1 → round to ±1
			_ieee754::pack "$sign" 1023 0
		else
			# |value| ≤ 0.5 → round to 0 (ties-to-even: 0.5 → 0)
			_ieee754::pack "$sign" 0 0
		fi
		return 0
	fi
	if (( unbiased >= 52 )); then
		# Already an integer
		echo "$bits"
		return 0
	fi

	# Round to nearest, ties to even
	local frac_bits=$(( 52 - unbiased ))
	local half_bit=$(( 1 << (frac_bits - 1) ))
	local frac_mask=$(( (1 << frac_bits) - 1 ))
	local frac=$(( mant & frac_mask ))

	if (( frac > half_bit )); then
		# Round up: add 1 << frac_bits, then zero fraction
		mant=$(( mant + (1 << frac_bits) ))
	elif (( frac == half_bit )); then
		# Ties to even: round up if the integer LSB is 1
		if (( (mant >> frac_bits) & 1 )); then
			mant=$(( mant + (1 << frac_bits) ))
		fi
	fi
	# Zero out fractional bits
	_ieee754::pack "$sign" "$exp" $(( mant & ~frac_mask ))
}
```

