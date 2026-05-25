# `process::run_bg`

**Signature:** `process::run_bg(command, [args...])`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

--- BACKGROUND JOBS ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `command` | command | Yes | |
| `args...` | string | No | |

## Source

```bash
process::run_bg() {
		"$@" &
		echo $!
}
```

