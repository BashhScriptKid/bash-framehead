# `array::rotate::fast`

**Signature:** `array::rotate::fast(result_arr, n, el1, el2, ...)`

**Module:** [`array`](../../array.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_arr` | variable | Yes | |
| `n` | integer | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::rotate::fast() {
    local -n _array_rotate_result="$1"
    local n="$2"; shift 2
    local -a _arr=("$@")
    local len="${#_arr[@]}"
    n=$(( n % len ))
    _array_rotate_result=("${_arr[@]:$n}" "${_arr[@]:0:$n}")
}
```

