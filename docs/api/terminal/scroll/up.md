# `terminal::scroll::up`

**Signature:** `terminal::scroll::up()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Scroll up n lines


## Source

```bash
terminal::scroll::up() {
    printf '\033[%sS' "${1:-1}"
}
```

