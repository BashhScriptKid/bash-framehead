# `math::matrix::diagonal`

**Signature:** `math::matrix::diagonal(NxN, a)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Extract diagonal elements as a flat list

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `NxN` | string | Yes | |
| `a` | string | Yes | |

## Source

```bash
math::matrix::diagonal() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:2}"
    local -a _result=()
    local i
    for (( i = 0; i < rows; i++ )); do
        _result+=("${_a[$i * $cols + $i]}")
    done
    echo "${_result[@]}"
}
```

