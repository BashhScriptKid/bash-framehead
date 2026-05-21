# `terminal::width`

**Signature:** `terminal::width()`

**Module:** [`terminal`](../terminal.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get terminal width in columns


## Source

```bash
terminal::width() {
    tput cols 2>/dev/null || echo "80"
}
```

