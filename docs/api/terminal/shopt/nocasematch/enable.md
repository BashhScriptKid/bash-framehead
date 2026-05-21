# `terminal::shopt::nocasematch::enable`

**Signature:** `terminal::shopt::nocasematch::enable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::nocasematch::enable()   { shopt -s nocasematch  2>/dev/null; }  # case-insensitive [[ =~
```

