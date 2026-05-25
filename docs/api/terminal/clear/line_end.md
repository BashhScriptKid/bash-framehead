# `terminal::clear::line_end`

**Signature:** `terminal::clear::line_end()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Clear from cursor to end of line


## Source

```bash
terminal::clear::line_end() {
		printf '\033[0K'
}
```

