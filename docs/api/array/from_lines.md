# `array::from_lines`

**Signature:** `array::from_lines(line1\nline2\nline3)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Build an array from lines of stdin or a string (newline-delimited)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `line1nline2nline3` | string | Yes | |

## Source

```bash
array::from_lines() {
    local IFS=$'\n'
    local -a parts=($1)
    printf '%s\n' "${parts[@]}"
}
```

