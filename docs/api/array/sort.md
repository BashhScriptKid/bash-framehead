# `array::sort`

**Signature:** `array::sort(el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Sort elements alphabetically

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::sort() {
    printf '%s\n' "$@" | sort
}
```

