# `math::matrix::inverse`

**Signature:** `math::matrix::inverse(scale, NxN, a)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Compute the inverse of a square matrix — requires bc

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `scale` | string | Yes | |
| `NxN` | string | Yes | |
| `a` | string | Yes | |

## Source

```bash
math::matrix::inverse() {
    local scale=$1 dim=$2
    local rows cols
    _math::matrix::dim "$dim" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"

    local det
    det=$(math::matrix::determinant "$scale" "$dim" "${_a[@]}")
    if [[ $(math::bc "$det == 0" "$scale") -eq 1 ]]; then
        echo "Error: math::matrix::inverse: matrix is singular (determinant = 0)" >&2
        return 1
    fi

    local inv_det
    inv_det=$(math::bc "1 / $det" "$scale")
    local -a adj
    read -ra adj <<< "$(math::matrix::adjugate "$scale" "$dim" "${_a[@]}")"
    math::matrix::scalef "$scale" "$dim" "$inv_det" "${adj[@]}"
}
```

