# `terminal::cursor::up`

**Signature:** `terminal::cursor::up()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Move cursor up n rows


## Source

```bash
terminal::cursor::up() {
		printf '\033[%sA' "${1:-1}"
}
```

