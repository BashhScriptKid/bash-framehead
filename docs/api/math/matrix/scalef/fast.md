# `math::matrix::scalef::fast`

**Signature:** `math::matrix::scalef::fast(result, scale, RxC, scalar, a)`

**Module:** [`math`](../../../math.md) — [Guide](../../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Multiply every element of a matrix by a scalar with floating point precision, writing into output array

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result` | string | Yes | |
| `scale` | string | Yes | |
| `RxC` | string | Yes | |
| `scalar` | string | Yes | |
| `a` | string | Yes | |

## Source

```bash
math::matrix::scalef::fast() {
    local -n _out="$1"; shift
    local scale=$1 scalar=$3 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:4}"
    _out=()
    local i
    for (( i = 0; i < size; i++ )); do
        _out+=("$(math::bc "${_a[$i]} * $scalar" "$scale")")
    done
}
```

