# `terminal::screen::normal`

**Signature:** `terminal::screen::normal()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Return to normal screen buffer


## Source

```bash
terminal::screen::normal() {
    printf '\033[?1049l'
}
```

