# `math::matrix::lu`

**Signature:** `math::matrix::lu(scale, NxN, L_out, U_out, a)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- math::matrix::lu — LU decomposition (requires bc) ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `scale` | string | Yes | |
| `NxN` | string | Yes | |
| `L_out` | string | Yes | |
| `U_out` | string | Yes | |
| `a` | string | Yes | |

## Source

```bash
math::matrix::lu() {
		local scale=$1 rows cols
		_math::matrix::dim "$2" rows cols
		if (( rows != cols )); then
				echo "Error: math::matrix::lu: matrix must be square" >&2
				return 1
		fi
		local -n _lower="$3" _upper="$4"
		local size=$(( rows * cols ))
		local -a _arr
		_math::matrix::unpack _arr "$size" "${@:5}"

		local _n=$rows
		local -a _lu=("${_arr[@]}")
		local i j k

		for (( k = 0; k < _n; k++ )); do
				local pivot_val="${_lu[$k * $_n + $k]}"
				for (( i = k + 1; i < _n; i++ )); do
						local factor
						factor=$(math::bc "${_lu[$i * $_n + $k]} / $pivot_val" "$scale")
						_lu[$i * $_n + $k]="$factor"
						for (( j = k + 1; j < _n; j++ )); do
								_lu[$i * $_n + $j]=$(math::bc "${_lu[$i * $_n + $j]} - $factor * ${_lu[$k * $_n + $j]}" "$scale")
						done
				done
		done

		# Extract L and U
		_lower=()
		_upper=()
		for (( i = 0; i < _n; i++ )); do
				for (( j = 0; j < _n; j++ )); do
						if (( i > j )); then
								_lower+=("${_lu[$i * $_n + $j]}")
								_upper+=(0)
						elif (( i == j )); then
								_lower+=(1)
								_upper+=("${_lu[$i * $_n + $j]}")
						else
								_lower+=(0)
								_upper+=("${_lu[$i * $_n + $j]}")
						fi
				done
		done
}
```

