# `runtime::is_ssh`

_No description available._

## Source

```bash
runtime::is_ssh() {
  [[ -n "$SSH_CLIENT" ]] ||
  [[ -n "$SSH_TTY" ]] ||
  [[ -n "$SSH_CONNECTION" ]]
}
```

## Module

[`runtime`](../runtime.md)
