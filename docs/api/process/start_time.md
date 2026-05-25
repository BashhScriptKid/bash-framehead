# `process::start_time`

**Signature:** `process::start_time(arg1)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get process start time (unix timestamp)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
process::start_time() {
		local pid="$1"
		if runtime::has_command ps; then
				ps -o lstart= -p "$pid" 2>/dev/null
		fi
}
```

