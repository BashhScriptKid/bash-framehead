# `device::read::hwmon::fan`

**Signature:** `device::read::hwmon::fan()`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
device::read::hwmon::fan() {
		local _hwmon="${1:-hwmon0}"
		local _fan
		_fan=$(cat "/sys/class/hwmon/${_hwmon}/fan1_input" 2>/dev/null) || { echo "unknown"; return 1; }
		echo "$_fan"
}
```

