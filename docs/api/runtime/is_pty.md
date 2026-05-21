# `runtime::is_pty`

**Signature:** `runtime::is_pty()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::is_pty() {
  # Check if we're in a pseudo-terminal
  [[ "$(tty)" =~ ^/dev/pts/[0-9]+ ]]
}
```

