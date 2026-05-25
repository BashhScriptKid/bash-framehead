# `process::pid`

**Signature:** `process::pid(name)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get PID(s) of a named process (one per line)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `name` | string | Yes | |

## Source

```bash
process::pid() {
		pgrep -x "$1" 2>/dev/null
}
```

