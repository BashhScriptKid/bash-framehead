# `runtime::is_desktop`

**Signature:** `runtime::is_desktop()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::is_desktop() {
	[ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]
}
```

