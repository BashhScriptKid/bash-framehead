# `terminal::shopt::inherit_errexit::disable`

**Signature:** `terminal::shopt::inherit_errexit::disable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::inherit_errexit::disable() { shopt -u inherit_errexit 2>/dev/null; }
```

