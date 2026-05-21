# `terminal::echo::off`

**Signature:** `terminal::echo::off()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Disable terminal echo (e.g. for password input)


## Source

```bash
terminal::echo::off() {
    stty -echo 2>/dev/null
}
```

