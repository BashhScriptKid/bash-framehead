# `terminal::clear::to_end`

**Signature:** `terminal::clear::to_end()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Clear from cursor to end of screen


## Source

```bash
terminal::clear::to_end() {
    printf '\033[0J'
}
```

