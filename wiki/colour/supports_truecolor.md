# `colour::supports_truecolor`

Check if terminal supports true colour (24-bit)
Checks $COLORTERM env var — set by most modern terminals

## Source

```bash
colour::supports_truecolor() {
    [[ "$COLORTERM" == "truecolor" || "$COLORTERM" == "24bit" ]]
}
```

## Module

[`colour`](../colour.md)
