# `terminal::shopt::dotglob::disable`

**Signature:** `terminal::shopt::dotglob::disable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::dotglob::disable()      { shopt -u dotglob      2>/dev/null; }
```

