# `device::is_device`

**Signature:** `device::is_device(arg1)`

**Module:** [`device`](../device.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if path is a character device

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::is_device() {
    [[ -c "$1" ]]
}
```

