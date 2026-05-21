# `math::matrix::identity::fast`

**Signature:** `math::matrix::identity::fast(result, NxN)`

**Module:** [`math`](../../../math.md) — [Guide](../../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Generate an identity matrix, writing into output array

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result` | string | Yes | |
| `NxN` | string | Yes | |

## Source

```bash
math::matrix::identity::fast() {
    local -n _out="$1"; shift
    local rows cols
    _math::matrix::dim "$1" rows cols
    _out=()
    local i j
    for (( i = 0; i < rows; i++ )); do
        for (( j = 0; j < cols; j++ )); do
            (( i == j )) && _out+=(1) || _out+=(0)
        done
    done
}
```

