# `array::unique::fast`

**Signature:** `array::unique::fast(result_arr, el1, el2, ...)`

**Module:** [`array`](../../array.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref (Bash 5+)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_arr` | variable | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::unique::fast() {
    local -n _array_unique_result="$1"
    shift
    local -A _seen=()
    _array_unique_result=()
    for el in "$@"; do
        if [[ -z "${_seen[$el]+x}" ]]; then
            _seen["$el"]=1
            _array_unique_result+=("$el")
        fi
    done
}
```

