# `math::matrix::powf`

**Signature:** `math::matrix::powf(scale, NxN, exponent, a)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Raise a square matrix to an integer power with floating point precision

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `scale` | string | Yes | |
| `NxN` | string | Yes | |
| `exponent` | string | Yes | |
| `a` | string | Yes | |

## Source

```bash
math::matrix::powf() {
    local scale=$1 dim=$2 exp=$3
    local rows cols
    _math::matrix::dim "$dim" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:4}"

    if (( exp == 0 )); then
        math::matrix::identity "$dim"
        return
    fi

    local -a _result=("${_a[@]}")
    local i
    for (( i = 1; i < exp; i++ )); do
        read -ra _result <<< "$(math::matrix::mulf "$scale" "$dim" "$dim" "${_result[@]}" "${_a[@]}")"
    done
    echo "${_result[@]}"
}
```

