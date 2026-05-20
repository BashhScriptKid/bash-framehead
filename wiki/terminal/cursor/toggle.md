# `terminal::cursor::toggle`

_No description available._

## Source

```bash
terminal::cursor::toggle() {
    # Tracks state via a global flag
    if [[ "${_TERMINAL_CURSOR_HIDDEN:-0}" == "1" ]]; then
        terminal::cursor::show
        _TERMINAL_CURSOR_HIDDEN=0
    else
        terminal::cursor::hide
        _TERMINAL_CURSOR_HIDDEN=1
    fi
}
```

## Module

[`terminal`](../terminal.md)
