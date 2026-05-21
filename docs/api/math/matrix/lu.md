# `math::matrix::lu`

**Signature:** `math::matrix::lu(scale, NxN, L_out, U_out, a)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

LU decomposition of a square matrix — requires bc

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
    local -n _L="$3" _U="$4"
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:5}"

    local n=$rows
    local -a _lu=("${_a[@]}")
    local i j k

    for (( k = 0; k < n; k++ )); do
        local pivot_val="${_lu[$k * $n + $k]}"
        for (( i = k + 1; i < n; i++ )); do
            local factor
            factor=$(math::bc "${_lu[$i * $n + $k]} / $pivot_val" "$scale")
            _lu[$i * $n + $k]="$factor"
            for (( j = k + 1; j < n; j++ )); do
                _lu[$i * $n + $j]=$(math::bc "${_lu[$i * $n + $j]} - $factor * ${_lu[$k * $n + $j]}" "$scale")
            done
        done
    done

    # Extract L and U
    _L=()
    _U=()
    for (( i = 0; i < n; i++ )); do
        for (( j = 0; j < n; j++ )); do
            if (( i > j )); then
                _L+=("${_lu[$i * $n + $j]}")
                _U+=(0)
            elif (( i == j )); then
                _L+=(1)
                _U+=("${_lu[$i * $n + $j]}")
            else
                _L+=(0)
                _U+=("${_lu[$i * $n + $j]}")
            fi
        done
    done
}
```

