# `device::fb::capture`

**Signature:** `device::fb::capture()`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
device::fb::capture() {
		local _fb="${1:-fb0}"
		local _sysfs="/sys/class/graphics/${_fb}"
		local _size _width _height _bpp _bytespp
		_size=$(cat "$_sysfs/virtual_size" 2>/dev/null) || { echo "device::fb::capture: cannot read framebuffer size" >&2; return 1; }
		_width="${_size%%,*}"
		_height="${_size##*,}"
		_bpp=$(cat "$_sysfs/bits_per_pixel" 2>/dev/null) || _bpp=32
		_bytespp=$((_bpp / 8))
		local _pixels=$((_width * _height))
		local _bytes=$((_pixels * _bytespp))
		printf "P6\n%d %d\n255\n" "$_width" "$_height"
		dd if="/dev/${_fb}" bs=1 count="$_bytes" 2>/dev/null
}
```

