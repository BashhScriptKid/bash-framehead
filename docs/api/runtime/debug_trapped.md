# `runtime::debug_trapped`

**Signature:** `runtime::debug_trapped()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::debug_trapped() {
		[[ -n "$(trap -p DEBUG)" ]]
}
```

