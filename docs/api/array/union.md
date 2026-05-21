# `array::union`

**Signature:** `array::union(el1, el2, el2, el3)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Union — all unique elements from both arrays

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `el2` | string | Yes | |
| `el3` | string | Yes | |

## Source

```bash
array::union() {
    local -a a=($1) b=($2)
    array::unique "${a[@]}" "${b[@]}"
}
```

