# `device::read::hwmon::temp`

**Signature:** `device::read::hwmon::temp()`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

--- HWMON ---


## Source

```bash
device::read::hwmon::temp() {
		local _hwmon="${1:-hwmon0}"
		local _temp
		_temp=$(cat "/sys/class/hwmon/${_hwmon}/temp1_input" 2>/dev/null) || { echo "unknown"; return 1; }
		echo $((_temp / 1000))
}
```

