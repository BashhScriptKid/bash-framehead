# `math::matrix::minor`

**Signature:** `math::matrix::minor(NxN, row, col, a)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Compute the minor of a matrix — submatrix with row i and col j removed

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `NxN` | string | Yes | |
| `row` | string | Yes | |
| `col` | string | Yes | |
| `a` | string | Yes | |

## Source

```bash
math::matrix::minor() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local skip_row=$2 skip_col=$3
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:4}"
    local -a _result=()
    local i j
    for (( i = 0; i < rows; i++ )); do
        (( i == skip_row )) && continue
        for (( j = 0; j < cols; j++ )); do
            (( j == skip_col )) && continue
            _result+=("${_a[$i * $cols + $j]}")
        done
    done
    echo "${_result[@]}"
}
```

