# `math::matrix::sub`

**Signature:** `math::matrix::sub(RxC, a, b)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

--- math::matrix::sub — Element-wise subtraction ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `RxC` | string | Yes | |
| `a` | string | Yes | |
| `b` | string | Yes | |

## Source

```bash
math::matrix::sub() {
		local rows cols
		_math::matrix::dim "$1" rows cols
		local size=$(( rows * cols ))
		local -a _a _b
		_math::matrix::unpack2 _a _b "$size" "$size" "${@:2}"
		local -a _result=()
		local i
		for (( i = 0; i < size; i++ )); do
				_result+=("$(( _a[$i] - _b[$i] ))")
		done
		echo "${_result[@]}"
}
```

