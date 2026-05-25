# `math::is_prime`

**Signature:** `math::is_prime(arg1)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code

## Description

Check if integer is prime

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
math::is_prime() {
	local n scale
	if [[ $# -ge 1 ]]; then n="$1"; scale="${2:-$MATH_SCALE}"
	else n=$(cat); scale="${1:-$MATH_SCALE}"; fi
		_math::is_float "$n" && { echo "math::is_prime: float input — is_prime is integer-only" >&2; return 1; }
		(( n < 2 )) && return 1
		(( n == 2 )) && return 0
		(( n % 2 == 0 )) && return 1
		local i=3
		while (( i * i <= n )); do
				(( n % i == 0 )) && return 1
				(( i += 2 ))
		done
		return 0
}
```

