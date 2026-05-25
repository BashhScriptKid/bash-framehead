# `process::run_bg::timeout`

**Signature:** `process::run_bg::timeout(seconds, command, [args...])`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Run a command in the background with a timeout

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `seconds` | string | Yes | |
| `command` | command | Yes | |
| `args...` | string | No | |

## Source

```bash
process::run_bg::timeout() {
		local timeout="$1"; shift
		(
				"$@" &
				local pid=$!
				sleep "$timeout"
				process::kill::graceful "$pid"
		) &
		echo $!
}
```

