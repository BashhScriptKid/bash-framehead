# `math::matrix::subf`

**Signature:** `math::matrix::subf(scale, RxC, a, b)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Subtract matrix b from matrix a element-wise with floating point precision

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `scale` | string | Yes | |
| `RxC` | string | Yes | |
| `a` | string | Yes | |
| `b` | string | Yes | |

## Source

```bash
math::matrix::subf() {
		local scale=$1 rows cols
		_math::matrix::dim "$2" rows cols
		local size=$(( rows * cols ))
		local -a _a _b
		_math::matrix::unpack2 _a _b "$size" "$size" "${@:3}"
		local -a _result=()
		local i
		for (( i = 0; i < size; i++ )); do
				_result+=("$(math::bc "${_a[$i]} - ${_b[$i]}" "$scale")")
		done
		echo "${_result[@]}"
}
```

