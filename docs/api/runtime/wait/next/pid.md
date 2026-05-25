# `runtime::wait::next::pid`

**Signature:** `runtime::wait::next::pid()`

**Module:** [`runtime`](../../../runtime.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

Wait for next job, echo its PID, return its exit code.


## Source

```bash
runtime::wait::next::pid() {
		local _pid
		if _runtime::min_bash 5.1; then
				wait -n -p _pid "$@"
		else
				wait -n "$@"
				_pid=$!
		fi
		local _ret=$?
		echo "$_pid"
		return $_ret
}
```

