# `device::list::power`

**Signature:** `device::list::power()`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
device::list::power() {
		local _dir
		for _dir in /sys/class/power_supply/*/type; do
				[[ -f "$_dir" ]] || continue
				basename "$(dirname "$_dir")"
		done
}
```

