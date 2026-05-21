# `terminal::cursor::down`

**Signature:** `terminal::cursor::down()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Move cursor down n rows


## Source

```bash
terminal::cursor::down() {
    printf '\033[%sB' "${1:-1}"
}
```

