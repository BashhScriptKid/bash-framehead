# `math::matrix::tracef`

**Signature:** `math::matrix::tracef(scale, NxN, a)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Sum of diagonal elements with floating point precision

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `scale` | string | Yes | |
| `NxN` | string | Yes | |
| `a` | string | Yes | |

## Source

```bash
math::matrix::tracef() {
		local scale=$1 rows cols
		_math::matrix::dim "$2" rows cols
		local size=$(( rows * cols ))
		local -a _a
		_math::matrix::unpack _a "$size" "${@:3}"
		local sum="0" i
		for (( i = 0; i < rows; i++ )); do
				sum=$(math::bc "$sum + ${_a[$i * $cols + $i]}" "$scale")
		done
		echo "$sum"
}
```

