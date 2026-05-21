# `device::is_loop`

**Signature:** `device::is_loop(arg1)`

**Module:** [`device`](../device.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if device is a loop device

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::is_loop() {
    [[ "$1" == /dev/loop* ]]
}
```

