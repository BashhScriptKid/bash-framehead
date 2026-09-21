# `device::read::gpu::vram`

**Signature:** `device::read::gpu::vram()`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
device::read::gpu::vram() {
		local _card="${1:-card0}"
		local _bytes
		_bytes=$(cat "/sys/class/drm/${_card}/device/mem_info_vram_total" 2>/dev/null) || { echo "unknown"; return 1; }
		if (( _bytes >= 1073741824 )); then
				printf '%.1fGB' "$((_bytes / 1073741824))"
		elif (( _bytes >= 1048576 )); then
				printf '%.0fMB' "$((_bytes / 1048576))"
		else
				echo "${_bytes}B"
		fi
}
```

