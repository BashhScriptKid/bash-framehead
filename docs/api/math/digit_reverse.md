# `math::digit_reverse`

**Signature:** `math::digit_reverse(arg1)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Reverse digits of an integer

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
math::digit_reverse() {
		local n="${1#-}" sign="" result=0
		[[ "$1" == -* ]] && sign="-"
		while (( n > 0 )); do
				result=$(( result * 10 + n % 10 ))
				(( n /= 10 ))
		done
		echo "${sign}${result}"
}
```

