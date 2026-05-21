# `runtime::supports_color`

**Signature:** `runtime::supports_color()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::supports_color() {
  # Check if terminal supports color
  [[ -t 1 ]] && [[ "$TERM" != "dumb" ]] && {
    [[ -n "$COLORTERM" ]] ||
    [[ "$TERM" =~ ^(xterm|screen|vt100|linux|ansi) ]] || {
      local colors
      colors=$(tput colors 2>/dev/null)
      [[ -n "$colors" && "$colors" -ge 8 ]]
    }
  }
}
```

