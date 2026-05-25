# `process::renice`

**Signature:** `process::renice(pid, value)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Change process priority (nice value, -20 to 19)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `pid` | integer | Yes | |
| `value` | string | Yes | |

## Source

```bash
process::renice() {
		renice -n "$2" -p "$1" 2>/dev/null
}
```

