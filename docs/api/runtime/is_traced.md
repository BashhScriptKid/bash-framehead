# `runtime::is_traced`

**Signature:** `runtime::is_traced()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::is_traced() {
		[[ "$-" == *x* ]] || [[ -n "$BASH_XTRACEFD" ]]
}
```

