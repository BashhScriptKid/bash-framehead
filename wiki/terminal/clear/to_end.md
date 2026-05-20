# `terminal::clear::to_end`

Clear from cursor to end of screen

## Source

```bash
terminal::clear::to_end() {
    printf '\033[0J'
}
```

## Module

[`terminal`](../terminal.md)
