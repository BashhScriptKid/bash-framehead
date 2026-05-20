# `runtime::is_pipe`

_No description available._

## Source

```bash
runtime::is_pipe() {
  # Check if stdin is a pipe
  [[ -p /dev/stdin ]] && return 0

  # Check if stdin is redirected from a file
  [[ ! -t 0 ]] && return 0

  # Only check jobs if we're not interactive
  if ! runtime::is_interactive && [[ -n "$(jobs -p)" ]]; then
    return 0
  fi

  return 1
}
```

## Module

[`runtime`](../runtime.md)
