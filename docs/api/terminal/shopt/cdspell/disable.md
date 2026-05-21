# `terminal::shopt::cdspell::disable`

**Signature:** `terminal::shopt::cdspell::disable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::cdspell::disable()      { shopt -u cdspell      2>/dev/null; }
```

