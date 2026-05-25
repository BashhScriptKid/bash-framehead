# `process::kill::graceful`

**Signature:** `process::kill::graceful(pid, [timeout_seconds])`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** exit code

## Description

Graceful kill — SIGTERM, wait, then SIGKILL if still running

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `pid` | integer | Yes | |
| `timeout_seconds` | integer | No | |

## Source

```bash
process::kill::graceful() {
		local pid="$1" timeout="${2:-5}"
		process::is_running "$pid" || return 0

		# SIGCONT first — a stopped process ignores SIGTERM
		kill -CONT "$pid" 2>/dev/null
		kill -TERM "$pid" 2>/dev/null

		local elapsed=0
		while (( elapsed < timeout )); do
				process::is_running "$pid" || return 0
				sleep 1
				(( elapsed++ ))
		done

		# Still running after timeout — force kill
		kill -KILL "$pid" 2>/dev/null
		local i
		for (( i = 0; i < 5; i++ )); do
				process::is_running "$pid" || return 0
				sleep 0.2
		done
		return 1
}
```

