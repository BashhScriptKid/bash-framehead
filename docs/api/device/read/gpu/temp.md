# `device::read::gpu::temp`

**Signature:** `device::read::gpu::temp()`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
device::read::gpu::temp() {
		local _card="${1:-card0}"
		local _temp
		_temp=$(cat "/sys/class/drm/${_card}/device/hwmon/hwmon*/temp1_input" 2>/dev/null) || { echo "unknown"; return 1; }
		echo $((_temp / 1000))
}
```

