# `device::read::usb::vendor_id`

**Signature:** `device::read::usb::vendor_id(arg1)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- USB METADATA ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::read::usb::vendor_id() {
		local _dev="$1"
		cat "/sys/bus/usb/devices/${_dev}/idVendor" 2>/dev/null || echo "unknown"
}
```

