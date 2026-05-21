# `runtime::is_x11`

**Signature:** `runtime::is_x11()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::is_x11()     { [[ -n "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; }
```

