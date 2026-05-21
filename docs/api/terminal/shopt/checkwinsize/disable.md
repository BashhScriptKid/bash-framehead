# `terminal::shopt::checkwinsize::disable`

**Signature:** `terminal::shopt::checkwinsize::disable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::checkwinsize::disable() { shopt -u checkwinsize 2>/dev/null; }
```

