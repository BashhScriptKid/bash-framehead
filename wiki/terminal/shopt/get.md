# `terminal::shopt::get`

Get current value of a shopt option ("on" or "off")

## Source

```bash
terminal::shopt::get() {
    shopt "$1" 2>/dev/null | awk '{print $2}'
}
```

## Module

[`terminal`](../terminal.md)
