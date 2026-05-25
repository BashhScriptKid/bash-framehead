# `runtime::is_root`

**Signature:** `runtime::is_root()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::is_root() {
	[[ $EUID -eq 0 ]]
}
```

