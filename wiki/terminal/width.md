# `terminal::width`

Get terminal width in columns

## Source

```bash
terminal::width() {
    tput cols 2>/dev/null || echo "80"
}
```

## Module

[`terminal`](../terminal.md)
