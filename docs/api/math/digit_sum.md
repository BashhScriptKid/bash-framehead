# `math::digit_sum`

**Signature:** `math::digit_sum()`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Sum of digits of an integer


## Source

```bash
math::digit_sum() {
		local n="${1#-}" sum=0  # strip sign
		while (( n > 0 )); do
				(( sum += n % 10 ))
				(( n /= 10 ))
		done
		echo "$sum"
}
```

