# `process::is_running::name`

**Signature:** `process::is_running::name(name)`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if a process is running by name

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `name` | string | Yes | |

## Source

```bash
process::is_running::name() {
		pgrep -x "$1" >/dev/null 2>&1
}
```

