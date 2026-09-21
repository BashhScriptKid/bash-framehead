# `device::fb::resolution`

**Signature:** `device::fb::resolution()`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
device::fb::resolution() {
		local _fb="${1:-fb0}"
		local _size
		_size=$(cat "/sys/class/graphics/${_fb}/virtual_size" 2>/dev/null) || { echo "unknown"; return 1; }
		echo "${_size//,/x}"
}
```

