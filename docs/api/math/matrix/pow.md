# `math::matrix::pow`

**Signature:** `math::matrix::pow(NxN, exponent, a)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Raise a square matrix to an integer power via repeated multiplication

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `NxN` | string | Yes | |
| `exponent` | string | Yes | |
| `a` | string | Yes | |

## Source

```bash
math::matrix::pow() {
    local dim=$1 exp=$2
    local rows cols
    _math::matrix::dim "$dim" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"

    if (( exp == 0 )); then
        math::matrix::identity "$dim"
        return
    fi

    local -a _result=("${_a[@]}")
    local i
    for (( i = 1; i < exp; i++ )); do
        read -ra _result <<< "$(math::matrix::mul "$dim" "$dim" "${_result[@]}" "${_a[@]}")"
    done
    echo "${_result[@]}"
}
```

