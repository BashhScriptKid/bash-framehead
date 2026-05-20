# `terminal::screen::alternate_enter`

_No description available._

## Source

```bash
terminal::screen::alternate_enter() {
    terminal::screen::alternate
    terminal::cursor::home
    terminal::clear
    trap 'terminal::screen::normal' EXIT INT TERM
}
```

## Module

[`terminal`](../terminal.md)
