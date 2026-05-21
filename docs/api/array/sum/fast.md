# `array::sum::fast`

**Signature:** `array::sum::fast(result_var, el1, el2, ...)`

**Module:** [`array`](../../array.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::sum::fast() {
    local -n _array_sum_result="$1"
    shift
    local total=0
    for el in "$@"; do
        total=$(( total + el ))
    done
    _array_sum_result=$total
}
```

