# `runtime::is_tmux`

**Signature:** `runtime::is_tmux()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::is_tmux() {
  [[ -n "$TMUX" ]]
}
```

