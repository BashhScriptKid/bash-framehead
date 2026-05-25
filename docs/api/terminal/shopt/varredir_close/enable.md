# `terminal::shopt::varredir_close::enable`

**Signature:** `terminal::shopt::varredir_close::enable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::varredir_close::enable()   { shopt -s varredir_close  2>/dev/null; }  # auto-close {fd} FDs on scope exit
```

