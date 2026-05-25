# `math::abs`

**Signature:** `math::abs(n)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

BASIC INTEGER ARITHMETIC

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `n` | integer | Yes | |

## Source

```bash
math::abs() {
	local n
	if [[ $# -ge 1 ]]; then n="$1"; else n=$(cat); fi
		_math::is_float "$n" && { echo "math::abs: float input — use math::absf" >&2; return 1; }
		echo $(( $n < 0 ? -$n : $n ))
}
```

