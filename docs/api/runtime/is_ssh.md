# `runtime::is_ssh`

**Signature:** `runtime::is_ssh()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::is_ssh() {
	[[ -n "$SSH_CLIENT" ]] ||
	[[ -n "$SSH_TTY" ]] ||
	[[ -n "$SSH_CONNECTION" ]]
}
```

