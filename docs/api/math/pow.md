# `math::pow`

**Signature:** `math::pow(base, exponent)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Integer exponentiation

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `base` | string | Yes | |
| `exponent` | string | Yes | |

## Source

```bash
math::pow() {
		local base="$1" exp="$2" result=1
		_math::is_float "$base" || _math::is_float "$exp" && { echo "math::pow: float input — use math::powf" >&2; return 1; }
		while (( exp > 0 )); do
				(( exp % 2 == 1 )) && result=$(( result * base ))
				base=$(( base * base ))
				exp=$(( exp / 2 ))
		done
		echo "$result"
}
```

