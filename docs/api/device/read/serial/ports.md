# `device::read::serial::ports`

**Signature:** `device::read::serial::ports()`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

--- SERIAL PORTS ---


## Source

```bash
device::read::serial::ports() {
		local _dir _driver
		for _dir in /sys/class/tty/ttyS* /sys/class/tty/ttyUSB* /sys/class/tty/ttyACM*; do
				[[ -d "$_dir" ]] || continue
				_driver=$(readlink "$_dir/device/driver" 2>/dev/null | xargs basename 2>/dev/null) || _driver="unknown"
				printf '%s driver=%s\n' "$(basename "$_dir")" "$_driver"
		done
}
```

