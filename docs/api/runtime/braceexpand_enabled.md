# `runtime::braceexpand_enabled`

**Signature:** `runtime::braceexpand_enabled()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::braceexpand_enabled() {
    [[ "$-" == *B* ]]
}
```

