# `device::fb::stride`

**Signature:** `device::fb::stride()`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
device::fb::stride() {
		local _fb="${1:-fb0}"
		cat "/sys/class/graphics/${_fb}/stride" 2>/dev/null || echo "unknown"
}
```

