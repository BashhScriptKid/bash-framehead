# `device::read::usb::manufacturer`

**Signature:** `device::read::usb::manufacturer(arg1)`

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
device::read::usb::manufacturer() {
		local _dev="$1"
		cat "/sys/bus/usb/devices/${_dev}/manufacturer" 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}
```

