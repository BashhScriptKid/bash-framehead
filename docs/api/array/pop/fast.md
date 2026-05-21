# `array::pop::fast`

**Signature:** `array::pop::fast(result_arr, el1, el2, ...)`

**Module:** [`array`](../../array.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_arr` | variable | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::pop::fast() {
    local -n _array_pop_result="$1"
    shift
    local -a _arr=("$@")
    unset '_arr[-1]'
    _array_pop_result=("${_arr[@]}")
}
```

