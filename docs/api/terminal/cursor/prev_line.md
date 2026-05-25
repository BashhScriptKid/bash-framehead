# `terminal::cursor::prev_line`

**Signature:** `terminal::cursor::prev_line()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Move cursor to start of line n lines up


## Source

```bash
terminal::cursor::prev_line() {
		printf '\033[%sF' "${1:-1}"
}
```

