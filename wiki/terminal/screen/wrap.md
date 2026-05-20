# `terminal::screen::wrap`

Enter alternate screen, run a command, return to normal screen

## Usage

```bash
terminal::screen::wrap command [args...]
```

## Source

```bash
terminal::screen::wrap() {
    terminal::screen::alternate
    "$@"
    local ret=$?
    terminal::screen::normal
    return $ret
}
```

## Module

[`terminal`](../terminal.md)
