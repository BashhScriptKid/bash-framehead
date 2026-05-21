# `terminal::shopt::histappend::enable`

**Signature:** `terminal::shopt::histappend::enable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::histappend::enable()    { shopt -s histappend   2>/dev/null; }  # append to history
```

