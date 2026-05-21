# `runtime::is_login`

**Signature:** `runtime::is_login()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::is_login() {
  shopt -q login_shell
}
```

