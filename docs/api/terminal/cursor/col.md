# `terminal::cursor::col`

**Signature:** `terminal::cursor::col()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Move cursor to column n on current line


## Source

```bash
terminal::cursor::col() {
		printf '\033[%sG' "${1:-1}"
}
```

