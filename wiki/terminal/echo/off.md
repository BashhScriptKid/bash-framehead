# `terminal::echo::off`

Disable terminal echo (e.g. for password input)

## Source

```bash
terminal::echo::off() {
    stty -echo 2>/dev/null
}
```

## Module

[`terminal`](../terminal.md)
