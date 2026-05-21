# `math::matrix::scalef`

**Signature:** `math::matrix::scalef(scale, RxC, scalar, a)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Multiply every element of a matrix by a scalar with floating point precision

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `scale` | string | Yes | |
| `RxC` | string | Yes | |
| `scalar` | string | Yes | |
| `a` | string | Yes | |

## Source

```bash
math::matrix::scalef() {
    local scale=$1 scalar=$3 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:4}"
    local -a _result=()
    local i
    for (( i = 0; i < size; i++ )); do
        _result+=("$(math::bc "${_a[$i]} * $scalar" "$scale")")
    done
    echo "${_result[@]}"
}
```

