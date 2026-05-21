# `runtime::is_sourced`

**Signature:** `runtime::is_sourced()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::is_sourced() {
  [[ "${BASH_SOURCE[0]}" != "${0}" ]]
}
```

