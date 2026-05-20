# `terminal::cursor::right`

Move cursor right n cols

## Source

```bash
terminal::cursor::right() {
    printf '\033[%sC' "${1:-1}"
}
```

## Module

[`terminal`](../terminal.md)
