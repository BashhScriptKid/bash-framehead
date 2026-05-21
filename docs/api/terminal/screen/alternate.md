# `terminal::screen::alternate`

**Signature:** `terminal::screen::alternate()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Enter alternate screen buffer (like vim/less do)


## Source

```bash
terminal::screen::alternate() {
    printf '\033[?1049h'
}
```

