# `terminal::size`

**Signature:** `terminal::size()`

**Module:** [`terminal`](../terminal.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Get both as "cols rows"


## Source

```bash
terminal::size() {
    echo "$(terminal::width) $(terminal::height)"
}
```

