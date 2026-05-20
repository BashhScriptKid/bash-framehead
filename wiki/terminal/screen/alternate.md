# `terminal::screen::alternate`

Enter alternate screen buffer (like vim/less do)

## Source

```bash
terminal::screen::alternate() {
    printf '\033[?1049h'
}
```

## Module

[`terminal`](../terminal.md)
