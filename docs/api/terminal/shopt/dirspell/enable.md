# `terminal::shopt::dirspell::enable`

**Signature:** `terminal::shopt::dirspell::enable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::dirspell::enable()         { shopt -s dirspell       2>/dev/null; }  # autocorrect dir typos on tab
```

