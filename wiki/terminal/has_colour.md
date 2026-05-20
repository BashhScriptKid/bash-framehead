# `terminal::has_colour`

Check if terminal supports colours

## Source

```bash
terminal::has_colour() {
    [[ -t 1 ]] && (( $(tput colors 2>/dev/null) >= 8 ))
}
```

## Module

[`terminal`](../terminal.md)
