# `terminal::cursor::down`

Move cursor down n rows

## Source

```bash
terminal::cursor::down() {
    printf '\033[%sB' "${1:-1}"
}
```

## Module

[`terminal`](../terminal.md)
