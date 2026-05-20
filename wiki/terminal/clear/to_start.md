# `terminal::clear::to_start`

Clear from cursor to beginning of screen

## Source

```bash
terminal::clear::to_start() {
    printf '\033[1J'
}
```

## Module

[`terminal`](../terminal.md)
