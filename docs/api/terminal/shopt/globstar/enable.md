# `terminal::shopt::globstar::enable`

**Signature:** `terminal::shopt::globstar::enable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Common shopt convenience toggles


## Source

```bash
terminal::shopt::globstar::enable()      { shopt -s globstar     2>/dev/null; }  # ** recursive glob
```

