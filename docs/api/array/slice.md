# `array::slice`

**Signature:** `array::slice(start, length, el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Slice a subarray

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `start` | string | Yes | |
| `length` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::slice() {
    local start="$1" len="$2"; shift 2
    local -a arr=("$@")
    printf '%s\n' "${arr[@]:$start:$len}"
}
```

