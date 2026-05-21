# `array::pop`

**Signature:** `array::pop(el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Remove last element

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::pop() {
    local -a arr=("$@")
    unset 'arr[-1]'
    printf '%s\n' "${arr[@]}"
}
```

