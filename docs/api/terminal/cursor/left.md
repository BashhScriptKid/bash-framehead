# `terminal::cursor::left`

**Signature:** `terminal::cursor::left()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Move cursor left n cols


## Source

```bash
terminal::cursor::left() {
		printf '\033[%sD' "${1:-1}"
}
```

