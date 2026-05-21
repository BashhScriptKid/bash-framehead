# `terminal::shopt::nocasematch::disable`

**Signature:** `terminal::shopt::nocasematch::disable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::nocasematch::disable()  { shopt -u nocasematch  2>/dev/null; }
```

