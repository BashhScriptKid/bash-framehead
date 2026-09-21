# `device::list::input`

**Signature:** `device::list::input(arg2)`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg2` | string | Yes | |

## Source

```bash
device::list::input() {
		if [[ -f /proc/bus/input/devices ]]; then
				awk -F= '/^N:/{gsub(/^[[:space:]]+/,"",$2); print $2}' /proc/bus/input/devices
		else
				echo ""
		fi
}
```

