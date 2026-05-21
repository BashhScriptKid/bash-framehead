# `runtime::is_bash`

**Signature:** `runtime::is_bash()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::is_bash() {
  [[ -n "$BASH_VERSION" ]]
}
```

