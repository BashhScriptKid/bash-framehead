# `math::matrix::subf::fast`

**Signature:** `math::matrix::subf::fast(result, scale, RxC, a, b)`

**Module:** [`math`](../../../math.md) — [Guide](../../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Subtract matrix b from matrix a element-wise with floating point precision, writing into output array

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result` | string | Yes | |
| `scale` | string | Yes | |
| `RxC` | string | Yes | |
| `a` | string | Yes | |
| `b` | string | Yes | |

## Source

```bash
math::matrix::subf::fast() {
		local -n _out="$1"; shift
		local scale=$1 rows cols
		_math::matrix::dim "$2" rows cols
		local size=$(( rows * cols ))
		local -a _a _b
		_math::matrix::unpack2 _a _b "$size" "$size" "${@:3}"
		_out=()
		local i
		for (( i = 0; i < size; i++ )); do
				_out+=("$(math::bc "${_a[$i]} - ${_b[$i]}" "$scale")")
		done
}
```

