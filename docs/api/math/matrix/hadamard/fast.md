# `math::matrix::hadamard::fast`

**Signature:** `math::matrix::hadamard::fast(result, RxC, a, b)`

**Module:** [`math`](../../../math.md) — [Guide](../../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Hadamard product, writing into output array

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result` | string | Yes | |
| `RxC` | string | Yes | |
| `a` | string | Yes | |
| `b` | string | Yes | |

## Source

```bash
math::matrix::hadamard::fast() {
    local -n _out="$1"; shift
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:2}"
    _out=()
    local i
    for (( i = 0; i < size; i++ )); do
        _out+=("$(( _a[$i] * _b[$i] ))")
    done
}
```

