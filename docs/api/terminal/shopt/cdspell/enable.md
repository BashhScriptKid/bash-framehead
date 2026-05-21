# `terminal::shopt::cdspell::enable`

**Signature:** `terminal::shopt::cdspell::enable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::cdspell::enable()       { shopt -s cdspell      2>/dev/null; }  # autocorrect cd typos
```

