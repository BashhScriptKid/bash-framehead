# `terminal::shopt::globskipdots::disable`

**Signature:** `terminal::shopt::globskipdots::disable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::globskipdots::disable()    { shopt -u globskipdots    2>/dev/null; }
```

