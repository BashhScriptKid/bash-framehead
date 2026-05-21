# `terminal::is_tty`

**Signature:** `terminal::is_tty()`

**Module:** [`terminal`](../terminal.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if stdout is a terminal


## Source

```bash
terminal::is_tty() {
    [[ -t 1 ]]
}
```

