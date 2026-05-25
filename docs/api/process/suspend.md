# `process::suspend`

**Signature:** `process::suspend(arg1)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Suspend a process (SIGSTOP)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
process::suspend() {
		kill -STOP "$1" 2>/dev/null
}
```

