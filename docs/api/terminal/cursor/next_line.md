# `terminal::cursor::next_line`

**Signature:** `terminal::cursor::next_line()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Move cursor to start of line n lines down


## Source

```bash
terminal::cursor::next_line() {
		printf '\033[%sE' "${1:-1}"
}
```

