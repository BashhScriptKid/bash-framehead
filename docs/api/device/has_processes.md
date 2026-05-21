# `device::has_processes`

**Signature:** `device::has_processes(arg1)`

**Module:** [`device`](../device.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if device has open file handles via lsof

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::has_processes() {
    runtime::has_command lsof || return 1
    lsof -t "$1" >/dev/null 2>&1
}
```

