# `device::list::led`

**Signature:** `device::list::led()`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
device::list::led() {
		local _dir
		for _dir in /sys/class/leds/*; do
				[[ -d "$_dir" ]] || continue
				basename "$_dir"
		done
}
```

