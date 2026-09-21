# `device::list::hwmon`

**Signature:** `device::list::hwmon()`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
device::list::hwmon() {
		local _dir _name
		for _dir in /sys/class/hwmon/hwmon*; do
				[[ -d "$_dir" ]] || continue
				_name=$(cat "$_dir/name" 2>/dev/null) || _name="unknown"
				printf '%s (%s)\n' "$(basename "$_dir")" "$_name"
		done
}
```

