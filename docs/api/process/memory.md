# `process::memory`

**Signature:** `process::memory(pid)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get memory usage in KB for a PID

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `pid` | integer | Yes | |

## Source

```bash
process::memory() {
		if [[ -f "/proc/$1/status" ]]; then
				awk '/^VmRSS:/{print $2}' "/proc/$1/status"
		else
				ps -o rss= -p "$1" 2>/dev/null | tr -d ' '
		fi
}
```

