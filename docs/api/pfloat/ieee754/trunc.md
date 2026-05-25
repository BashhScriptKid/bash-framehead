# `pfloat::ieee754::trunc`

**Signature:** `pfloat::ieee754::trunc(<bits>)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

IEEE 754: Truncate float toward zero, return as integer bits

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<bits>` | string | Yes | |

## Source

```bash
pfloat::ieee754::trunc() {
	local bits="$1"
	_ieee754::is_nan "$bits" && { echo "0"; return 1; }
	_ieee754::is_inf "$bits" && { echo "$bits"; return 0; }
	_ieee754::is_zero "$bits" && { echo "$bits"; return 0; }

	local sign; sign=$(_ieee754::get_sign "$bits")
	local exp;   exp=$(_ieee754::get_exp "$bits")
	local mant;  mant=$(_ieee754::get_mant "$bits")

	local unbiased=$(( exp - 1023 ))
	if (( unbiased < 0 )); then
		# |value| < 1 → truncates to 0 (or -0)
		_ieee754::pack "$sign" 0 0
		return 0
	fi
	if (( unbiased >= 52 )); then
		# Already an integer
		echo "$bits"
		return 0
	fi

	# Zero out fractional bits in mantissa
	local frac_bits=$(( 52 - unbiased ))
	local frac_mask=$(( (1 << frac_bits) - 1 ))
	_ieee754::pack "$sign" "$exp" $(( mant & ~frac_mask ))
}
```

