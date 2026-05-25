# `runtime::pid_current`

**Signature:** `runtime::pid_current()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

SHELL PROCESS


## Source

```bash
runtime::pid_current() {
		echo "${BASHPID:-$$}"
}
```

