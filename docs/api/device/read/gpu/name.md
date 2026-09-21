# `device::read::gpu::name`

**Signature:** `device::read::gpu::name()`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

--- GPU / DRM ---


## Source

```bash
device::read::gpu::name() {
		local _card="${1:-card0}"
		cat "/sys/class/drm/${_card}/device/product_name" 2>/dev/null || \
				cat "/sys/class/drm/${_card}/device/uevent" 2>/dev/null | grep -oP 'PCI_ID=\K.*' || \
				echo "unknown"
}
```

