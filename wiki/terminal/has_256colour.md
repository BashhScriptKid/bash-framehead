# `terminal::has_256colour`

Check if terminal supports 256 colours

## Source

```bash
terminal::has_256colour() {
    [[ -t 1 ]] && (( $(tput colors 2>/dev/null) >= 256 ))
}
```

## Module

[`terminal`](../terminal.md)
