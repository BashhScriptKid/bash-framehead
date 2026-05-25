# `math::choose`

**Signature:** `math::choose(n, k)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

--- NUMBER THEORY / COMBINATORICS ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `n` | integer | Yes | |
| `k` | string | Yes | |

## Source

```bash
math::choose() {
		local n="$1" k="$2"
		_math::is_float "$n" || _math::is_float "$k" && { echo "math::choose: float input — choose is integer-only" >&2; return 1; }
		(( k > n )) && echo 0 && return
		(( k == 0 || k == n )) && echo 1 && return
		# Use the smaller of k and n-k for efficiency
		(( k > n - k )) && k=$(( n - k ))
		local result=1 i
		for (( i=0; i<k; i++ )); do
				result=$(( result * (n - i) / (i + 1) ))
		done
		echo "$result"
}
```

