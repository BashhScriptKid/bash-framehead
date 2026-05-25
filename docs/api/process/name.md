# `process::name`

**Signature:** `process::name(pid)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get process name from PID

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `pid` | integer | Yes | |

## Source

```bash
process::name() {
		local pid="${1:-$$}"
		if [[ -f "/proc/$pid/comm" ]]; then
				cat "/proc/$pid/comm"
		else
				ps -o comm= -p "$pid" 2>/dev/null
		fi
}
```

