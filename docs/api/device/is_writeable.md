# `device::is_writeable`

**Signature:** `device::is_writeable(arg1)`

**Module:** [`device`](../device.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if device is writable

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::is_writeable() {
    [[ -w "$1" ]]
}
```

