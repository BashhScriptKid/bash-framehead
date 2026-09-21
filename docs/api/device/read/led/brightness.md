# `device::read::led::brightness`

**Signature:** `device::read::led::brightness(arg1)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- LEDs ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::read::led::brightness() {
		local _led="$1"
		cat "/sys/class/leds/${_led}/brightness" 2>/dev/null || echo "unknown"
}
```

