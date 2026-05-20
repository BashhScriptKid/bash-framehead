# `runtime::is_redirected`

_No description available._

## Source

```bash
runtime::is_redirected() {
  # Check if any std descriptor is redirected
  [[ ! -t 0 ]] || [[ ! -t 1 ]] || [[ ! -t 2 ]]
}
```

## Module

[`runtime`](../runtime.md)
