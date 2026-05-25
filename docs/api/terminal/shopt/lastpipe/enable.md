# `terminal::shopt::lastpipe::enable`

**Signature:** `terminal::shopt::lastpipe::enable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::lastpipe::enable()       { shopt -s lastpipe       2>/dev/null; }  # last pipe in current shell
```

