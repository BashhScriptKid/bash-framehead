# `device::list::serial`

**Signature:** `device::list::serial()`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
device::list::serial() {
		local _dir
		for _dir in /sys/class/tty/ttyS* /sys/class/tty/ttyUSB* /sys/class/tty/ttyACM*; do
				[[ -d "$_dir" ]] || continue
				basename "$_dir"
		done
}
```

