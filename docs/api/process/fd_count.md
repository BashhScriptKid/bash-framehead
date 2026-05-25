# `process::fd_count`

**Signature:** `process::fd_count(arg1)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get number of open file descriptors for a PID

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
process::fd_count() {
		ls "/proc/$1/fd" 2>/dev/null | wc -l
}
```

