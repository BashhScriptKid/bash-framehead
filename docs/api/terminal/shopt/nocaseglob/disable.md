# `terminal::shopt::nocaseglob::disable`

**Signature:** `terminal::shopt::nocaseglob::disable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::nocaseglob::disable()   { shopt -u nocaseglob   2>/dev/null; }
```

