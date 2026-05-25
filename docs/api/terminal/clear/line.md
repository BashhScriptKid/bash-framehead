# `terminal::clear::line`

**Signature:** `terminal::clear::line()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Clear current line


## Source

```bash
terminal::clear::line() {
		printf '\033[2K'
}
```

