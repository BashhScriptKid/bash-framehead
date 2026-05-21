# `terminal::is_tty::stderr`

**Signature:** `terminal::is_tty::stderr()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if stderr is a terminal


## Source

```bash
terminal::is_tty::stderr() {
    [[ -t 2 ]]
}
```

