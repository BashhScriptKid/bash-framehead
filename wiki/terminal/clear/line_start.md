# `terminal::clear::line_start`

Clear from cursor to start of line

## Source

```bash
terminal::clear::line_start() {
    printf '\033[1K'
}
```

## Module

[`terminal`](../terminal.md)
