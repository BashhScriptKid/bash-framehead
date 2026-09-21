# `device::input::find::name`

**Signature:** `device::input::find::name(arg1)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- INPUT DEVICE DISCOVERY ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::input::find::name() {
		local _pattern="$1"
		awk -v pat="$_pattern" '
		/^N:/{name=$0; sub(/^N: Name=/, "", name)}
		/^H:/{handlers=$0}
		/^$/{if(name ~ pat) {
			match(handlers, /event[0-9]+/)
			if (RSTART > 0) print substr(handlers, RSTART, RLENGTH)
		}}
		' /proc/bus/input/devices 2>/dev/null | head -1
}
```

