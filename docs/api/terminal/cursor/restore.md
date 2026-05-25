# `terminal::cursor::restore`

**Signature:** `terminal::cursor::restore()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Restore cursor to saved position


## Source

```bash
terminal::cursor::restore() {
		printf '\033[u'
}
```

