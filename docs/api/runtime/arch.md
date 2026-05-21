# `runtime::arch`

**Signature:** `runtime::arch()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

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

