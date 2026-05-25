# `runtime::is_subshell`

**Signature:** `runtime::is_subshell()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::is_subshell() {
		[[ "$BASH_SUBSHELL" -gt 0 ]]
}
```

