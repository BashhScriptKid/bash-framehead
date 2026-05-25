# `math::matrix::scale::fast`

**Signature:** `math::matrix::scale::fast(result, RxC, scalar, a)`

**Module:** [`math`](../../../math.md) — [Guide](../../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Multiply every element of a matrix by a scalar, writing into output array

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result` | string | Yes | |
| `RxC` | string | Yes | |
| `scalar` | string | Yes | |
| `a` | string | Yes | |

## Source

```bash
math::matrix::scale::fast() {
		local -n _out="$1"; shift
		local scalar=$2 rows cols
		_math::matrix::dim "$1" rows cols
		local size=$(( rows * cols ))
		local -a _a
		_math::matrix::unpack _a "$size" "${@:3}"
		_out=()
		local i
		for (( i = 0; i < size; i++ )); do
				_out+=("$(( _a[$i] * scalar ))")
		done
}
```

