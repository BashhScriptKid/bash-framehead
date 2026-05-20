# `runtime::arch`

_No description available._

## Source

```bash
runtime::arch() {
  case "$(uname -m)" in
  x86_64) echo "amd64" ;;
  i386) echo "386" ;;
  armv7l) echo "armv7" ;;
  aarch64) echo "arm64" ;;
  *) echo "unknown" ;;
  esac
}
```

## Module

[`runtime`](../runtime.md)
