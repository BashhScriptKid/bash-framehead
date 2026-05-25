# `terminal::shopt::globasciiranges::disable`

**Signature:** `terminal::shopt::globasciiranges::disable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::globasciiranges::disable() { shopt -u globasciiranges 2>/dev/null; }
```

