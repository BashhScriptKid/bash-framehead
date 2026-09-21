# `device::fb::info`

**Signature:** `device::fb::info()`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
device::fb::info() {
		local _fb="${1:-fb0}"
		if runtime::has_command fbset; then
				fbset -i -fb "/dev/${_fb}" 2>/dev/null || echo "unknown"
		else
				echo "unknown"
		fi
}
```

