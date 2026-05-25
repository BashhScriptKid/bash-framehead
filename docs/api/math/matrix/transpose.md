# `math::matrix::transpose`

**Signature:** `math::matrix::transpose(RxC, a)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

--- math::matrix::transpose ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `RxC` | string | Yes | |
| `a` | string | Yes | |

## Source

```bash
math::matrix::transpose() {
		local rows cols
		_math::matrix::dim "$1" rows cols
		local size=$(( rows * cols ))
		local -a _a
		_math::matrix::unpack _a "$size" "${@:2}"
		local -a _result=()
		local i j
		for (( j = 0; j < cols; j++ )); do
				for (( i = 0; i < rows; i++ )); do
						_result+=("${_a[$i * $cols + $j]}")
				done
		done
		echo "${_result[@]}"
}
```

