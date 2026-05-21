# `math::matrix::print`

**Signature:** `math::matrix::print(RxC, a)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Print a matrix in row-major human-readable format

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `RxC` | string | Yes | |
| `a` | string | Yes | |

## Source

```bash
math::matrix::print() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:2}"
    local i j
    for (( i = 0; i < rows; i++ )); do
        for (( j = 0; j < cols; j++ )); do
            printf '%s ' "${_a[$i * $cols + $j]}"
        done
        echo
    done
}
```

