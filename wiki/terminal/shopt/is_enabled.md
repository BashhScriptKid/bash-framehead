# `terminal::shopt::is_enabled`

Check if a shopt option is enabled

## Source

```bash
terminal::shopt::is_enabled() {
    shopt -q "$1" 2>/dev/null
}
```

## Module

[`terminal`](../terminal.md)
