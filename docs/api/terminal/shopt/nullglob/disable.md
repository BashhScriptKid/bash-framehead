# `terminal::shopt::nullglob::disable`

**Signature:** `terminal::shopt::nullglob::disable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::nullglob::disable()     { shopt -u nullglob     2>/dev/null; }
```

