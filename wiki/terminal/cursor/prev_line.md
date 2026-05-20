# `terminal::cursor::prev_line`

Move cursor to start of line n lines up

## Source

```bash
terminal::cursor::prev_line() {
    printf '\033[%sF' "${1:-1}"
}
```

## Module

[`terminal`](../terminal.md)
