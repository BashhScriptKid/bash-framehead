# `math::permute`

**Signature:** `math::permute(n, k)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Number of permutations P(n, k)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `n` | integer | Yes | |
| `k` | string | Yes | |

## Source

```bash
math::permute() {
		local n="$1" k="$2" result=1 i
		_math::is_float "$n" || _math::is_float "$k" && { echo "math::permute: float input — permute is integer-only" >&2; return 1; }
		for (( i=0; i<k; i++ )); do
				result=$(( result * (n - i) ))
		done
		echo "$result"
}
```

