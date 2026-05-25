# `terminal::cursor::save`

**Signature:** `terminal::cursor::save()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Save cursor position


## Source

```bash
terminal::cursor::save() {
		printf '\033[s'
}
```

