# `runtime::noclobber_enabled`

**Signature:** `runtime::noclobber_enabled()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::noclobber_enabled() {
		[[ "$-" == *C* ]]
}
```

