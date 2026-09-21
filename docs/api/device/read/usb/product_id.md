# `device::read::usb::product_id`

**Signature:** `device::read::usb::product_id(arg1)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::read::usb::product_id() {
		local _dev="$1"
		cat "/sys/bus/usb/devices/${_dev}/idProduct" 2>/dev/null || echo "unknown"
}
```

