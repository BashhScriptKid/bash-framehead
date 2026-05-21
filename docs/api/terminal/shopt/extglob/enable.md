# `terminal::shopt::extglob::enable`

**Signature:** `terminal::shopt::extglob::enable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::extglob::enable()       { shopt -s extglob      2>/dev/null; }  # extended patterns
```

