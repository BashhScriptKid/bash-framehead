# `terminal::shopt::inherit_errexit::enable`

**Signature:** `terminal::shopt::inherit_errexit::enable()`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
terminal::shopt::inherit_errexit::enable()  { shopt -s inherit_errexit 2>/dev/null; }  # subshells inherit -e
```

