# `terminal::clear`

Clear entire screen

## Source

```bash
terminal::clear() {
    printf '\033[2J'
    terminal::cursor::home
}
```

## Module

[`terminal`](../terminal.md)
