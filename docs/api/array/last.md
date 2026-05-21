# `array::last`

**Signature:** `array::last(el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Return last element

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::last() {
    eval echo "\${$#}"
}
```

