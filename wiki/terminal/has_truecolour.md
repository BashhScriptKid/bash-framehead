# `terminal::has_truecolour`

Check if terminal supports true colour

## Source

```bash
terminal::has_truecolour() {
    [[ "$COLORTERM" == "truecolor" || "$COLORTERM" == "24bit" ]]
}
```

## Module

[`terminal`](../terminal.md)
