# `terminal::has_truecolour`

**Signature:** `terminal::has_truecolour()`

**Module:** [`terminal`](../terminal.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if terminal supports true colour


## Source

```bash
terminal::has_truecolour() {
    [[ "$COLORTERM" == "truecolor" || "$COLORTERM" == "24bit" ]]
}
```

