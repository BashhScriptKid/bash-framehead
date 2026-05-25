# `math::matrix::trace`

**Signature:** `math::matrix::trace(NxN, a)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

--- math::matrix::trace ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `NxN` | string | Yes | |
| `a` | string | Yes | |

## Source

```bash
math::matrix::trace() {
		local rows cols
		_math::matrix::dim "$1" rows cols
		local size=$(( rows * cols ))
		local -a _a
		_math::matrix::unpack _a "$size" "${@:2}"
		local sum=0 i
		for (( i = 0; i < rows; i++ )); do
				sum=$(( sum + _a[$i * $cols + $i] ))
		done
		echo "$sum"
}
```

