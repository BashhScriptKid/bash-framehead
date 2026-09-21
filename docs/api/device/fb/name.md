# `device::fb::name`

**Signature:** `device::fb::name()`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- FRAMEBUFFER ---


## Source

```bash
device::fb::name() {
		local _fb="${1:-fb0}"
		cat "/sys/class/graphics/${_fb}/name" 2>/dev/null || echo "unknown"
}
```

