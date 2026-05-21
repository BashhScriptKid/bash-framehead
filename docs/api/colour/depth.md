# `colour::depth`

**Signature:** `colour::depth()`

**Module:** [`colour`](../colour.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Return the number of colours the terminal supports


## Source

```bash
colour::depth() {
    tput colors 2>/dev/null || echo "0"
}
```

