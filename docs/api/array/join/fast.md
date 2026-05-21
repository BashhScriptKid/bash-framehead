# `array::join::fast`

**Signature:** `array::join::fast(result_var, delimiter, el1, el2, ...)`

**Module:** [`array`](../../array.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `delimiter` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::join::fast() {
    local -n _array_join_result="$1"
    local delim="$2"; shift 2
    local result="" first=true
    for el in "$@"; do
        if $first; then result="$el"; first=false
        else result+="${delim}${el}"; fi
    done
    _array_join_result="$result"
}
```

