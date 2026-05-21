# `array::max`

**Signature:** `array::max(el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Maximum value (numeric)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::max() {
    local max="$1"; shift
    for el in "$@"; do
        (( el > max )) && max="$el"
    done
    echo "$max"
}
```

