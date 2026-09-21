# `device::read::usb::driver`

**Signature:** `device::read::usb::driver(arg1)`

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
device::read::usb::driver() {
		local _dev="$1"
		local _link
		_link=$(readlink "/sys/bus/usb/devices/${_dev}/driver" 2>/dev/null) || { echo "unknown"; return 1; }
		basename "$_link"
}
```

