# `process::kill`

**Signature:** `process::kill(arg1)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Terminate a process (SIGTERM)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
process::kill() {
		kill -TERM "$1" 2>/dev/null
}
```

