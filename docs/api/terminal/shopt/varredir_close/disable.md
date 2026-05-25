# `terminal::shopt::varredir_close::disable`

**Signature:** `terminal::shopt::varredir_close::disable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::varredir_close::disable()  { shopt -u varredir_close  2>/dev/null; }
```

