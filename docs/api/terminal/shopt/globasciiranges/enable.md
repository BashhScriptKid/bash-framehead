# `terminal::shopt::globasciiranges::enable`

**Signature:** `terminal::shopt::globasciiranges::enable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::globasciiranges::enable()  { shopt -s globasciiranges 2>/dev/null; }  # [a-z] = ASCII only
```

