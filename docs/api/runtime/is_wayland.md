# `runtime::is_wayland`

**Signature:** `runtime::is_wayland()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::is_wayland() { [[ -n "${WAYLAND_DISPLAY:-}" ]]; }
```

