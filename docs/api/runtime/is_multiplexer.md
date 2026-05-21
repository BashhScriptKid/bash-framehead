# `runtime::is_multiplexer`

**Signature:** `runtime::is_multiplexer()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::is_multiplexer() {
  [[ -n "$STY" ]] || [[ -n "$TMUX" ]]
}
```

