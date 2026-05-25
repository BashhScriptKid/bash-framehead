# `device::exists`

**Signature:** `device::exists(arg1)`

**Module:** [`device`](../device.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if device exists (block or character)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::exists() {
		[[ -b "$1" || -c "$1" ]]
}
```

