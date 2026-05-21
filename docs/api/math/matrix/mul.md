# `math::matrix::mul`

**Signature:** `math::matrix::mul(RxC, RxC, a, b)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Multiply two matrices — cols of a must equal rows of b

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `RxC` | string | Yes | |
| `RxC` | string | Yes | |
| `a` | string | Yes | |
| `b` | string | Yes | |

## Source

```bash
math::matrix::mul() {
    local rows_a cols_a rows_b cols_b
    _math::matrix::dim "$1" rows_a cols_a
    _math::matrix::dim "$2" rows_b cols_b
    if (( cols_a != rows_b )); then
        echo "Error: math::matrix::mul: incompatible dimensions $1 * $2" >&2
        return 1
    fi
    local size_a=$(( rows_a * cols_a )) size_b=$(( rows_b * cols_b ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size_a" "$size_b" "${@:3}"
    local -a _result=()
    local i j k sum
    for (( i = 0; i < rows_a; i++ )); do
        for (( j = 0; j < cols_b; j++ )); do
            sum=0
            for (( k = 0; k < cols_a; k++ )); do
                sum=$(( sum + _a[$i * $cols_a + $k] * _b[$k * $cols_b + $j] ))
            done
            _result+=("$sum")
        done
    done
    echo "${_result[@]}"
}
```

