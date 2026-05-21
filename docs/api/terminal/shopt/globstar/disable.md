# `terminal::shopt::globstar::disable`

**Signature:** `terminal::shopt::globstar::disable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::globstar::disable()     { shopt -u globstar     2>/dev/null; }
```

