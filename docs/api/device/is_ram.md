# `device::is_ram`

**Signature:** `device::is_ram(arg1)`

**Module:** [`device`](../device.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if device is a RAM disk

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::is_ram() {
		[[ "$1" == /dev/ram* || "$1" == /dev/zram* ]]
}
```

