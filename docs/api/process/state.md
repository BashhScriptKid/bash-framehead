# `process::state`

**Signature:** `process::state(pid)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get process state (R=running, S=sleeping, Z=zombie, etc.)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `pid` | integer | Yes | |

## Source

```bash
process::state() {
		local pid="$1"
		if [[ -f "/proc/$pid/status" ]]; then
				awk '/^State:/{print $2}' "/proc/$pid/status"
		else
				ps -o state= -p "$pid" 2>/dev/null
		fi
}
```

