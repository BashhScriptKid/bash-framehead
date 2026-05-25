# `runtime::histexpand_enabled`

**Signature:** `runtime::histexpand_enabled()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::histexpand_enabled() {
		[[ "$-" == *H* ]]
}
```

