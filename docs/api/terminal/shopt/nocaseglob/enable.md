# `terminal::shopt::nocaseglob::enable`

**Signature:** `terminal::shopt::nocaseglob::enable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::nocaseglob::enable()    { shopt -s nocaseglob   2>/dev/null; }  # case-insensitive glob
```

