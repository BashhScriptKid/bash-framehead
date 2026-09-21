# `device::list::usb`

**Signature:** `device::list::usb()`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
device::list::usb() {
		local _dir _id
		for _dir in /sys/bus/usb/devices/[0-9]*; do
				[[ -d "$_dir" ]] || continue
				_id=$(cat "$_dir/idVendor" 2>/dev/null) || continue
				basename "$_dir"
		done
}
```

