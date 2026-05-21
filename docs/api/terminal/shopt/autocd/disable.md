# `terminal::shopt::autocd::disable`

**Signature:** `terminal::shopt::autocd::disable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::autocd::disable()       { shopt -u autocd       2>/dev/null; }
```

