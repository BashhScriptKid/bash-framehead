# `device::is_block`

**Signature:** `device::is_block(arg1)`

**Module:** [`device`](../device.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if path is a block device

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::is_block() {
    [[ -b "$1" ]]
}
```

