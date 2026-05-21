# `terminal::cursor::right`

**Signature:** `terminal::cursor::right()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Move cursor right n cols


## Source

```bash
terminal::cursor::right() {
    printf '\033[%sC' "${1:-1}"
}
```

