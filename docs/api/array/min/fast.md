# `array::min::fast`

**Signature:** `array::min::fast(result_var, el1, el2, ...)`

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
array::min::fast() {
    local -n _array_min_result="$1"
    shift
    local min="$1"
    for el in "$@"; do
        (( el < min )) && min="$el"
    done
    _array_min_result=$min
}
```

