# `terminal::shopt::disable`

Disable a shopt option

## Source

```bash
terminal::shopt::disable() {
    shopt -u "$1" 2>/dev/null
}
```

## Module

[`terminal`](../terminal.md)
