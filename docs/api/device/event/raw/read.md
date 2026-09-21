# `device::event::raw::read`

**Signature:** `device::event::raw::read(arg1)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Read one raw event from device, return hex bytes

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::event::raw::read() {
		od -An -tx1 -N24 "/dev/input/$1" 2>/dev/null
}
```

