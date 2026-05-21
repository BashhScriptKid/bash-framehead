# `terminal::clear::line_start`

**Signature:** `terminal::clear::line_start()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Clear from cursor to start of line


## Source

```bash
terminal::clear::line_start() {
    printf '\033[1K'
}
```

