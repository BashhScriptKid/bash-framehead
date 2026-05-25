# `math::matrix::transpose::fast`

**Signature:** `math::matrix::transpose::fast(result, RxC, a)`

**Module:** [`math`](../../../math.md) — [Guide](../../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Transpose a matrix, writing into output array

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result` | string | Yes | |
| `RxC` | string | Yes | |
| `a` | string | Yes | |

## Source

```bash
math::matrix::transpose::fast() {
		local -n _out="$1"; shift
		local rows cols
		_math::matrix::dim "$1" rows cols
		local size=$(( rows * cols ))
		local -a _a
		_math::matrix::unpack _a "$size" "${@:2}"
		_out=()
		local i j
		for (( j = 0; j < cols; j++ )); do
				for (( i = 0; i < rows; i++ )); do
						_out+=("${_a[$i * $cols + $j]}")
				done
		done
}
```

