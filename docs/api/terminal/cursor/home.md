# `terminal::cursor::home`

**Signature:** `terminal::cursor::home()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Move cursor to top-left (home)


## Source

```bash
terminal::cursor::home() {
    printf '\033[H'
}
```

