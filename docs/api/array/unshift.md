# `array::unshift`

**Signature:** `array::unshift(new_el, el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Prepend an element

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `new_el` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::unshift() {
    local new="$1"; shift
    printf '%s\n' "$new" "$@"
}
```

