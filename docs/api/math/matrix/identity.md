# `math::matrix::identity`

**Signature:** `math::matrix::identity(NxN)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

--- math::matrix::identity ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `NxN` | string | Yes | |

## Source

```bash
math::matrix::identity() {
		local rows cols
		_math::matrix::dim "$1" rows cols
		local -a _result=()
		local i j
		for (( i = 0; i < rows; i++ )); do
				for (( j = 0; j < cols; j++ )); do
						(( i == j )) && _result+=(1) || _result+=(0)
				done
		done
		echo "${_result[@]}"
}
```

