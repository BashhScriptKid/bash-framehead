# `colour::supports_truecolor`

**Signature:** `colour::supports_truecolor()`

**Module:** [`colour`](../colour.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if terminal supports true colour (24-bit)


## Source

```bash
colour::supports_truecolor() {
    [[ "$COLORTERM" == "truecolor" || "$COLORTERM" == "24bit" ]]
}
```

