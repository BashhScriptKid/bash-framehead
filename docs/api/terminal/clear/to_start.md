# `terminal::clear::to_start`

**Signature:** `terminal::clear::to_start()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Clear from cursor to beginning of screen


## Source

```bash
terminal::clear::to_start() {
		printf '\033[1J'
}
```

