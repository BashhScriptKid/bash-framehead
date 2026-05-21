# `fs::writeln`

**Signature:** `fs::writeln(arg1, arg2)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Write with newline

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
fs::writeln() {
    printf '%s\n' "$2" > "$1"
}
```

