# `pfloat::ieee754::sqrt`

**Signature:** `pfloat::ieee754::sqrt(bits)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

IEEE 754: Square root (Newton-Raphson iteration)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `bits` | integer | Yes | |

## Source

```bash
pfloat::ieee754::sqrt() {
	local a="$1"

	# Handle negative input
	if [[ $(_ieee754::get_sign "$a") -eq 1 ]]; then
		echo "NaN" >&2
		echo $((2047 << 52 | 1))  # NaN
		return
	fi

	# Handle special cases
	local exp=$(_ieee754::get_exp "$a")
	if ((exp == 2047)); then
		echo "$a"  # sqrt(Inf) = Inf, sqrt(NaN) = NaN
		return
	fi

	if _ieee754::is_zero "$a"; then
		echo 0
		return
	fi

	# Initial guess: exp/2
	local guess_exp=$((exp / 2 + 512))  # 512 = bias/2
	local guess=$((guess_exp << 52))

	# Newton-Raphson: x = (x + a/x) / 2
	local i
	for ((i = 0; i < 10; i++)); do
		local a_div_guess=$(pfloat::ieee754::div "$a" "$guess")
		local sum=$(pfloat::ieee754::add "$guess" "$a_div_guess")
		# Divide by 2 (just decrement exponent)
		guess=$((sum - (1 << 52)))
	done

	echo "$guess"
}
```

