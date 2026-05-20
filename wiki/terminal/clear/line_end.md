# `terminal::clear::line_end`

Clear from cursor to end of line

## Source

```bash
terminal::clear::line_end() {
    printf '\033[0K'
}
```

## Module

[`terminal`](../terminal.md)
