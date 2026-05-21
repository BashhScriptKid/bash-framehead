# `array::insert_at::fast`

**Signature:** `array::insert_at::fast(result_arr, index, value, el1, el2, ...)`

**Module:** [`array`](../../array.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_arr` | variable | Yes | |
| `index` | string | Yes | |
| `value` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::insert_at::fast() {
    local -n _array_insert_at_result="$1"
    local idx="$2" val="$3"; shift 3
    local i=0
    _array_insert_at_result=()
    for el in "$@"; do
        [[ "$i" -eq "$idx" ]] && _array_insert_at_result+=("$val")
        _array_insert_at_result+=("$el")
        (( i++ ))
    done
    [[ "$i" -le "$idx" ]] && _array_insert_at_result+=("$val")
}
```

