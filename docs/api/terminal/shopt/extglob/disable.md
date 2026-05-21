# `terminal::shopt::extglob::disable`

**Signature:** `terminal::shopt::extglob::disable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::extglob::disable()      { shopt -u extglob      2>/dev/null; }
```

