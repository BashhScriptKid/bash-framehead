# `math::matrix::determinant`

**Signature:** `math::matrix::determinant(scale, NxN, a)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** exit code

## Description

Compute determinant of a square matrix — requires bc

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `scale` | string | Yes | |
| `NxN` | string | Yes | |
| `a` | string | Yes | |

## Source

```bash
math::matrix::determinant() {
    local scale=$1 rows cols
    local work_scale=$(( scale + 4 ))
    _math::matrix::dim "$2" rows cols
    if (( rows != cols )); then
        echo "Error: math::matrix::determinant: matrix must be square" >&2
        return 1
    fi
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"

    # LU decomposition — Doolittle method
    # U stored in upper triangle, L in lower (diagonal of L is 1)
    local n=$rows
    local -a _lu=("${_a[@]}")
    local sign=1
    local i j k pivot tmp

    for (( k = 0; k < n; k++ )); do
        # Partial pivoting
        local max_val="${_lu[$k * $n + $k]}"
        local max_row=$k
        for (( i = k + 1; i < n; i++ )); do
            local val="${_lu[$i * $n + $k]}"
            local abs_val abs_max
            abs_val=$(math::bc "if ($val < 0) { -($val) } else { ($val) }" "$work_scale")
            abs_max=$(math::bc "if ($max_val < 0) { -($max_val) } else { ($max_val) }" "$work_scale")
            if [[ $(math::bc "$abs_val > $abs_max" "$work_scale") -eq 1 ]]; then
                max_val="$val"
                max_row=$i
            fi
        done

        # Swap rows if needed
        if (( max_row != k )); then
            for (( j = 0; j < n; j++ )); do
                tmp="${_lu[$k * $n + $j]}"
                _lu[$k * $n + $j]="${_lu[$max_row * $n + $j]}"
                _lu[$max_row * $n + $j]="$tmp"
            done
            sign=$(( sign * -1 ))
        fi

        local pivot_val="${_lu[$k * $n + $k]}"
        if [[ $(math::bc "$pivot_val == 0" "$work_scale") -eq 1 ]]; then
            echo "0"
            return 0
        fi

        for (( i = k + 1; i < n; i++ )); do
            local factor
            factor=$(math::bc "${_lu[$i * $n + $k]} / $pivot_val" "$work_scale")
            _lu[$i * $n + $k]="$factor"
            for (( j = k + 1; j < n; j++ )); do
                _lu[$i * $n + $j]=$(math::bc "${_lu[$i * $n + $j]} - $factor * ${_lu[$k * $n + $j]}" "$work_scale")
            done
        done
    done

    # Determinant = sign * product of U diagonal, rounded to requested scale
    local det="$sign"
    for (( i = 0; i < n; i++ )); do
        det=$(math::bc "$det * ${_lu[$i * $n + $i]}" "$work_scale")
    done
    math::bc "$det" "$scale"
}
```

