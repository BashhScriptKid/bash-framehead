# `terminal::shopt::histappend::disable`

**Signature:** `terminal::shopt::histappend::disable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::histappend::disable()   { shopt -u histappend   2>/dev/null; }
```

