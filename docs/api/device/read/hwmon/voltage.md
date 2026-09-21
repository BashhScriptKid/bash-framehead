# `device::read::hwmon::voltage`

**Signature:** `device::read::hwmon::voltage()`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
device::read::hwmon::voltage() {
		local _hwmon="${1:-hwmon0}"
		local _volt
		_volt=$(cat "/sys/class/hwmon/${_hwmon}/in0_input" 2>/dev/null) || { echo "unknown"; return 1; }
		echo "$_volt"
}
```

