# `runtime::is_wsl`

**Signature:** `runtime::is_wsl()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::is_wsl() {
  [[ -f /proc/version ]] && grep -qi "microsoft" /proc/version
}
```

