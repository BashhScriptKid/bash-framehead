# `math::matrix::flatten`

**Signature:** `math::matrix::flatten(RxC, a)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Flatten a matrix to a newline-separated list (one element per line)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `RxC` | string | Yes | |
| `a` | string | Yes | |

## Source

```bash
math::matrix::flatten() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:2}"
    printf '%s\n' "${_a[@]}"
}
```

