# `terminal::shopt::list::disabled`

List all disabled shopt options

## Source

```bash
terminal::shopt::list::disabled() {
    shopt | awk '$2 == "off" {print $1}'
}
```

## Module

[`terminal`](../terminal.md)
