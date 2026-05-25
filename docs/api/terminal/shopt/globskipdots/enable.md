# `terminal::shopt::globskipdots::enable`

**Signature:** `terminal::shopt::globskipdots::enable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::globskipdots::enable()     { shopt -s globskipdots    2>/dev/null; }  # * never returns . or ..
```

