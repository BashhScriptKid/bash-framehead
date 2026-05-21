# `array::unshift::fast`

**Signature:** `array::unshift::fast(result_arr, new_el, el1, el2, ...)`

**Module:** [`array`](../../array.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_arr` | variable | Yes | |
| `new_el` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::unshift::fast() {
    local -n _array_unshift_result="$1"
    local new="$2"; shift 2
    _array_unshift_result=("$new" "$@")
}
```

