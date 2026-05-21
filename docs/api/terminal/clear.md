# `terminal::clear`

**Signature:** `terminal::clear()`

**Module:** [`terminal`](../terminal.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Clear entire screen


## Source

```bash
terminal::clear() {
    printf '\033[2J'
    terminal::cursor::home
}
```

