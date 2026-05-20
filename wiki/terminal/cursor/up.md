# `terminal::cursor::up`

Move cursor up n rows

## Source

```bash
terminal::cursor::up() {
    printf '\033[%sA' "${1:-1}"
}
```

## Module

[`terminal`](../terminal.md)
