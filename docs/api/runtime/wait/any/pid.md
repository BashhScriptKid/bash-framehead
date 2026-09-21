# `runtime::wait::any::pid`

**Signature:** `runtime::wait::any::pid(jobspec...)`

**Module:** [`runtime`](../../../runtime.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

Wait for any of the listed jobspecs, echo PID, return exit code.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `jobspec...` | string | — | |

## Source

```bash
runtime::wait::any::pid() {
		local _pid
		if runtime::features::has wait_n_p; then
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

