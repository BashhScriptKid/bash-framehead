# `math::matrix::cofactor`

**Signature:** `math::matrix::cofactor(scale, NxN, a)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

--- math::matrix::cofactor ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `scale` | string | Yes | |
| `NxN` | string | Yes | |
| `a` | string | Yes | |

## Source

```bash
math::matrix::cofactor() {
		local scale=$1 rows cols
		_math::matrix::dim "$2" rows cols
		local size=$(( rows * cols ))
		local -a _a
		_math::matrix::unpack _a "$size" "${@:3}"
		local n=$rows
		local -a _result=()
		local i j sign minor_list det

		for (( i = 0; i < n; i++ )); do
				for (( j = 0; j < n; j++ )); do
						read -ra minor_list <<< "$(math::matrix::minor "${n}x${n}" "$i" "$j" "${_a[@]}")"
						local sub_dim="$(( n - 1 ))x$(( n - 1 ))"
						det=$(math::matrix::determinant "$scale" "$sub_dim" "${minor_list[@]}")
						sign=$(( (i + j) % 2 == 0 ? 1 : -1 ))
						_result+=("$(math::bc "$sign * $det" "$scale")")
				done
		done
		echo "${_result[@]}"
}
```

