# `device::read::input::devices`

**Signature:** `device::read::input::devices(arg2)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

--- INPUT DEVICES ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg2` | string | Yes | |

## Source

```bash
device::read::input::devices() {
		if [[ -f /proc/bus/input/devices ]]; then
				awk -F= '/^N:/{name=$2} /^H:/{handlers=$2} /^B: EV/{ev=$2} /^$/{if(name)printf "%-40s handlers=%-20s ev=%s\n",name,handlers,ev; name=""; handlers=""; ev=""}' /proc/bus/input/devices
		else
				echo "unknown"
		fi
}
```

