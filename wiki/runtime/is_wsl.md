# `runtime::is_wsl`

_No description available._

## Source

```bash
runtime::is_wsl() {
  [[ -f /proc/version ]] && grep -qi "microsoft" /proc/version
}
```

## Module

[`runtime`](../runtime.md)
