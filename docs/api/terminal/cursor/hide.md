# `terminal::cursor::hide`

**Signature:** `terminal::cursor::hide()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
terminal::cursor::hide() {
    printf '\033[?25l'
}
```

