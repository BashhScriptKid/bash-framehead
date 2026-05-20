# `terminal::screen::alternate_exit`

_No description available._

## Source

```bash
terminal::screen::alternate_exit() {
    terminal::screen::normal
    trap - EXIT INT TERM
}
```

## Module

[`terminal`](../terminal.md)
