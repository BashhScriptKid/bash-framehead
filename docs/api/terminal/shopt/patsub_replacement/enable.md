# `terminal::shopt::patsub_replacement::enable`

**Signature:** `terminal::shopt::patsub_replacement::enable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::patsub_replacement::enable()  { shopt -s patsub_replacement 2>/dev/null; }  # & in ${var/pat/repl} = match
```

