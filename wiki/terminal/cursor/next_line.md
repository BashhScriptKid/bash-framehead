# `terminal::cursor::next_line`

Move cursor to start of line n lines down

## Source

```bash
terminal::cursor::next_line() {
    printf '\033[%sE' "${1:-1}"
}
```

## Module

[`terminal`](../terminal.md)
