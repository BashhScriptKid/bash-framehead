# `process::exists`

**Signature:** `process::exists(<pid>)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if a PID exists.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<pid>` | string | Yes | |

## Source

```bash
process::exists() {
		kill -0 "$1" 2>/dev/null
}
```

