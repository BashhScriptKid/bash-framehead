# `terminal::shopt::dotglob::enable`

**Signature:** `terminal::shopt::dotglob::enable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::dotglob::enable()       { shopt -s dotglob      2>/dev/null; }  # globs match dotfiles
```

