# `terminal::shopt::failglob::enable`

**Signature:** `terminal::shopt::failglob::enable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::failglob::enable()       { shopt -s failglob       2>/dev/null; }  # glob w/ no match → error
```

