# `terminal::shopt::checkwinsize::enable`

**Signature:** `terminal::shopt::checkwinsize::enable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::checkwinsize::enable()  { shopt -s checkwinsize 2>/dev/null; }  # update LINES/COLUMNS
```

