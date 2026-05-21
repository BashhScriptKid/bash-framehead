# `runtime::os`

**Signature:** `runtime::os()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
runtime::os() {
  if runtime::is_wsl; then
    echo "wsl"
    return
  fi

  case "$(uname -s)" in
  Linux*) echo "linux" ;;
  Darwin*) echo "darwin" ;;
  CYGWIN*) echo "cygwin" ;;
  MINGW*) echo "mingw" ;;
  *) echo "unknown" ;;
  esac
}
```

