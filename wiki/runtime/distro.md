# `runtime::distro`

_No description available._

## Source

```bash
runtime::distro() {
  if [[ -f /etc/os-release ]]; then
    (. /etc/os-release && echo "$ID")
  else
    echo "unknown"
  fi
}
```

## Module

[`runtime`](../runtime.md)
