# `runtime::os`

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

## Module

[`runtime`](../runtime.md)
