# `device::read::power::capacity`

**Signature:** `device::read::power::capacity(arg1)`

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
device::read::power::capacity() {
		local _bat="$1"
		cat "/sys/class/power_supply/${_bat}/capacity" 2>/dev/null || echo "unknown"
}
```

