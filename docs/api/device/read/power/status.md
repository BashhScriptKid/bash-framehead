# `device::read::power::status`

**Signature:** `device::read::power::status(arg1)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- POWER SUPPLY ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::read::power::status() {
		local _bat="$1"
		cat "/sys/class/power_supply/${_bat}/status" 2>/dev/null || echo "unknown"
}
```

