# `runtime::is_tty`

**Signature:** `runtime::is_tty()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::is_tty() {
  # Check if we have a controlling terminal
  [[ -t 0 ]] && tty -s 2>/dev/null
}
```

