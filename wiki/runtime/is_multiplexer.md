# `runtime::is_multiplexer`

_No description available._

## Source

```bash
runtime::is_multiplexer() {
  [[ -n "$STY" ]] || [[ -n "$TMUX" ]]
}
```

## Module

[`runtime`](../runtime.md)
