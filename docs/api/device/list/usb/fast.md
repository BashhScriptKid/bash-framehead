# `device::list::usb::fast`

**Signature:** `device::list::usb::fast(result_var, arg1)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `arg1` | string | Yes | |

## Source

```bash
device::list::usb::fast() {
		local -n _ref="$1"
		local -a _out=()
		local _dir _id
		for _dir in /sys/bus/usb/devices/[0-9]*; do
				[[ -d "$_dir" ]] || continue
				_id=$(cat "$_dir/idVendor" 2>/dev/null) || continue
				_out+=("$(basename "$_dir")")
		done
		_ref=("${_out[@]}")
}
```

