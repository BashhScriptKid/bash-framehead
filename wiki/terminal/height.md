# `terminal::height`

Get terminal height in rows

## Source

```bash
terminal::height() {
    tput lines 2>/dev/null || echo "24"
}
```

## Module

[`terminal`](../terminal.md)
