# `fs::appendln`

**Signature:** `fs::appendln(arg1, arg2)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Append with newline

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
fs::appendln() {
		printf '%s\n' "$2" >> "$1"
}
```

