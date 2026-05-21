# `array::get::fast`

**Signature:** `array::get::fast(result_var, index, el1, el2, ...)`

**Module:** [`array`](../../array.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `index` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::get::fast() {
    local -n _array_get_result="$1"
    local idx="$2"; shift 2
    local -a _arr=("$@")
    _array_get_result="${_arr[$idx]}"
}
```

