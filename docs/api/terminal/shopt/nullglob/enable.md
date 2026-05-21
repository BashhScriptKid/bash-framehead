# `terminal::shopt::nullglob::enable`

**Signature:** `terminal::shopt::nullglob::enable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::nullglob::enable()      { shopt -s nullglob     2>/dev/null; }  # failed globs → empty
```

