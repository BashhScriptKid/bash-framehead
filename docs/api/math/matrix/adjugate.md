# `math::matrix::adjugate`

**Signature:** `math::matrix::adjugate(scale, NxN, a)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Compute the adjugate (transpose of cofactor matrix) — requires bc

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `scale` | string | Yes | |
| `NxN` | string | Yes | |
| `a` | string | Yes | |

## Source

```bash
math::matrix::adjugate() {
    local scale=$1 dim=$2
    local rows cols
    _math::matrix::dim "$dim" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"
    local -a cof
    read -ra cof <<< "$(math::matrix::cofactor "$scale" "$dim" "${_a[@]}")"
    math::matrix::transpose "$dim" "${cof[@]}"
}
```

