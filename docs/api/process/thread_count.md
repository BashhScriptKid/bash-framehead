# `process::thread_count`

**Signature:** `process::thread_count(arg1, arg2)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get number of threads for a PID

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
process::thread_count() {
		if [[ -f "/proc/$1/status" ]]; then
				awk '/^Threads:/{print $2}' "/proc/$1/status"
		else
				ps -o nlwp= -p "$1" 2>/dev/null | tr -d ' '
		fi
}
```

