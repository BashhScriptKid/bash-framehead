# `device::is_readable`

**Signature:** `device::is_readable(arg1)`

**Module:** [`device`](../device.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if device is readable

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::is_readable() {
    [[ -r "$1" ]]
}
```

