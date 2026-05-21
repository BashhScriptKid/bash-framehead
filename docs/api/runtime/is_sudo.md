# `runtime::is_sudo`

**Signature:** `runtime::is_sudo()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::is_sudo() {
  [[ -n "$SUDO_USER" ]]
}
```

