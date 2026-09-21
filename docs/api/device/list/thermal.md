# `device::list::thermal`

**Signature:** `device::list::thermal()`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
device::list::thermal() {
		local _dir
		for _dir in /sys/class/thermal/thermal_zone*; do
				[[ -d "$_dir" ]] || continue
				basename "$_dir"
		done
}
```

