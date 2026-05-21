# `fs::append`

**Signature:** `fs::append(arg1, arg2)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Append content to file

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
fs::append() {
    printf '%s' "$2" >> "$1"
}
```

