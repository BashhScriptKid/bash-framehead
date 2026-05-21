# `math::matrix::eq`

**Signature:** `math::matrix::eq(RxC, a, b)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if two matrices are equal element-wise

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `RxC` | string | Yes | |
| `a` | string | Yes | |
| `b` | string | Yes | |

## Source

```bash
math::matrix::eq() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:2}"
    local i
    for (( i = 0; i < size; i++ )); do
        [[ "${_a[$i]}" != "${_b[$i]}" ]] && return 1
    done
    return 0
}
```

