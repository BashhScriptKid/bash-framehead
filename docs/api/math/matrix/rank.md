# `math::matrix::rank`

**Signature:** `math::matrix::rank(scale, RxC, a)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Compute the rank of a matrix via Gaussian elimination — requires bc

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `scale` | string | Yes | |
| `RxC` | string | Yes | |
| `a` | string | Yes | |

## Source

```bash
math::matrix::rank() {
    local scale=$1 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"

    local -a _m=("${_a[@]}")
    local rank=0 row=0 i j k factor pivot

    for (( j = 0; j < cols && row < rows; j++ )); do
        # Find pivot in column j from row onwards
        local pivot_row=-1
        for (( i = row; i < rows; i++ )); do
            if [[ $(math::bc "${_m[$i * $cols + $j]} != 0" "$scale") -eq 1 ]]; then
                pivot_row=$i
                break
            fi
        done
        (( pivot_row == -1 )) && continue

        # Swap pivot row into position
        if (( pivot_row != row )); then
            local tmp
            for (( k = 0; k < cols; k++ )); do
                tmp="${_m[$row * $cols + $k]}"
                _m[$row * $cols + $k]="${_m[$pivot_row * $cols + $k]}"
                _m[$pivot_row * $cols + $k]="$tmp"
            done
        fi

        pivot="${_m[$row * $cols + $j]}"
        for (( i = row + 1; i < rows; i++ )); do
            factor=$(math::bc "${_m[$i * $cols + $j]} / $pivot" "$scale")
            for (( k = j; k < cols; k++ )); do
                _m[$i * $cols + $k]=$(math::bc "${_m[$i * $cols + $k]} - $factor * ${_m[$row * $cols + $k]}" "$scale")
            done
        done

        (( rank++ ))
        (( row++ ))
    done

    echo "$rank"
}
```

