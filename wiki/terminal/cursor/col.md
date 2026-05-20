# `terminal::cursor::col`

Move cursor to column n on current line

## Source

```bash
terminal::cursor::col() {
    printf '\033[%sG' "${1:-1}"
}
```

## Module

[`terminal`](../terminal.md)
