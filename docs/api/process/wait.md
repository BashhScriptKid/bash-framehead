# `process::wait`

**Signature:** `process::wait(pid, [timeout_seconds])`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code

## Description

Wait for a process to finish

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `pid` | integer | Yes | |
| `timeout_seconds` | integer | No | |

## Source

```bash
process::wait() {
		local pid="$1" timeout="${2:-}"
		if [[ -z "$timeout" ]]; then
				wait "$pid" 2>/dev/null
				return $?
		fi

		local elapsed=0
		while process::is_running "$pid"; do
				sleep 1
				(( elapsed++ ))
				(( elapsed >= timeout )) && return 1
		done
		return 0
}
```

