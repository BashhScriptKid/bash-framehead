# `runtime::is_redirected`

**Signature:** `runtime::is_redirected()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::is_redirected() {
	# Check if any std descriptor is redirected
	[[ ! -t 0 ]] || [[ ! -t 1 ]] || [[ ! -t 2 ]]
}
```

