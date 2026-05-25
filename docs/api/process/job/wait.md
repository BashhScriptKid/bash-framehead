# `process::job::wait`

**Signature:** `process::job::wait(arg1)`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** exit code

## Description

Wait for a specific background job by PID

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
process::job::wait() {
		wait "$1" 2>/dev/null
		return $?
}
```

