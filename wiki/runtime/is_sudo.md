# `runtime::is_sudo`

_No description available._

## Source

```bash
runtime::is_sudo() {
  [[ -n "$SUDO_USER" ]]
}
```

## Module

[`runtime`](../runtime.md)
