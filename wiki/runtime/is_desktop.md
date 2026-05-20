# `runtime::is_desktop`

_No description available._

## Source

```bash
runtime::is_desktop() {
  [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]
}
```

## Module

[`runtime`](../runtime.md)
