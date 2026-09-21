# `device::read::thermal::temp`

**Signature:** `device::read::thermal::temp(arg1)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::read::thermal::temp() {
		local _zone="$1"
		local _temp
		_temp=$(cat "/sys/class/thermal/${_zone}/temp" 2>/dev/null) || { echo "unknown"; return 1; }
		echo $((_temp / 1000))
}
```

