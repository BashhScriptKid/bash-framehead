# `runtime::kernel_version`

**Signature:** `runtime::kernel_version()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
runtime::kernel_version() {
  [[ $(runtime::os) == "linux" ]] || return 1
  # Number only, case of checks where you don't care about types
  local v
  v=$(uname -r)
  printf '%s\n' "${v%%-*}"
}
```

