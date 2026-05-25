# `terminal::shopt::dirspell::disable`

**Signature:** `terminal::shopt::dirspell::disable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::dirspell::disable()        { shopt -u dirspell       2>/dev/null; }
```

