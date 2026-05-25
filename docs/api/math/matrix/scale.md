# `math::matrix::scale`

**Signature:** `math::matrix::scale(RxC, scalar, a)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

--- math::matrix::scale — Scalar multiplication ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `RxC` | string | Yes | |
| `scalar` | string | Yes | |
| `a` | string | Yes | |

## Source

```bash
math::matrix::scale() {
		local scalar=$2 rows cols
		_math::matrix::dim "$1" rows cols
		local size=$(( rows * cols ))
		local -a _a
		_math::matrix::unpack _a "$size" "${@:3}"
		local -a _result=()
		local i
		for (( i = 0; i < size; i++ )); do
				_result+=("$(( _a[$i] * scalar ))")
		done
		echo "${_result[@]}"
}
```

