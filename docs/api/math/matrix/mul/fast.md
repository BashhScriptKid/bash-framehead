# `math::matrix::mul::fast`

**Signature:** `math::matrix::mul::fast(result, RxC, RxC, a, b)`

**Module:** [`math`](../../../math.md) — [Guide](../../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Multiply two matrices, writing result into output array

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result` | string | Yes | |
| `RxC` | string | Yes | |
| `RxC` | string | Yes | |
| `a` | string | Yes | |
| `b` | string | Yes | |

## Source

```bash
math::matrix::mul::fast() {
		local -n _out="$1"; shift
		local rows_a cols_a rows_b cols_b
		_math::matrix::dim "$1" rows_a cols_a
		_math::matrix::dim "$2" rows_b cols_b
		if (( cols_a != rows_b )); then
				echo "Error: math::matrix::mul::fast: incompatible dimensions $1 * $2" >&2
				return 1
		fi
		local size_a=$(( rows_a * cols_a )) size_b=$(( rows_b * cols_b ))
		local -a _a _b
		_math::matrix::unpack2 _a _b "$size_a" "$size_b" "${@:3}"
		_out=()
		local i j k sum
		for (( i = 0; i < rows_a; i++ )); do
				for (( j = 0; j < cols_b; j++ )); do
						sum=0
						for (( k = 0; k < cols_a; k++ )); do
								sum=$(( sum + _a[$i * $cols_a + $k] * _b[$k * $cols_b + $j] ))
						done
						_out+=("$sum")
				done
		done
}
```

