# `device::list::gpu`

**Signature:** `device::list::gpu()`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
device::list::gpu() {
		local _dir
		for _dir in /sys/class/drm/card[0-9]*; do
				[[ -d "$_dir" ]] || continue
				basename "$_dir"
		done
}
```

