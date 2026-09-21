# `device::read::led::max_brightness`

**Signature:** `device::read::led::max_brightness(arg1)`

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
device::read::led::max_brightness() {
		local _led="$1"
		cat "/sys/class/leds/${_led}/max_brightness" 2>/dev/null || echo "unknown"
}
```

